const admin = require("firebase-admin");
const OpenAI = require("openai");
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");

// v2 imports
const { onCall } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");

admin.initializeApp();
const db = admin.firestore();

// Secret (v2)
const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

// GEO DISTANCE
function haversineKm(lat1, lng1, lat2, lng2) {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;

  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLng / 2) ** 2;

  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

// json parse

function safeJsonParseFromModel(content) {
  let raw = (content || "").trim();

  if (!raw) {
    throw new Error("OpenAI returned empty response");
  }

  if (raw.startsWith("```")) {
    raw = raw.replace(/```json/g, "").replace(/```/g, "").trim();
  }

  try {
    return JSON.parse(raw);
  } catch (e) {
    console.error("❌ OpenAI RAW RESPONSE:\n", raw);
    throw new Error("Failed to parse OpenAI JSON output");
  }
}

// main func
exports.rankHelpRequest = onCall(
  {
    secrets: [OPENAI_API_KEY],
    timeoutSeconds: 60,
    memory: "512MiB",
  },
  async (request) => {
    const { auth, data } = request;

    // Auth
    if (!auth) {
      throw new Error("Authentication required");
    }

    const requestId = data && data.requestId;
    if (!requestId) {
      throw new Error("requestId is required");
    }

    const reqRef = db.collection("help_requests").doc(requestId);

    await db.runTransaction(async (tx) => {
      const snap = await tx.get(reqRef);
      if (!snap.exists) {
        throw new Error("Request not found");
      }

      const req = snap.data();
      if (req.userId !== auth.uid) {
        throw new Error("Permission denied");
      }

      if (req.status !== "open") {
        throw new Error("Request already processed");
      }

      tx.update(reqRef, { status: "processing" });
    });

    const reqSnap = await reqRef.get();
    const requestData = reqSnap.data();

    const usersSnap = await db
      .collection("users")
      .where("isVolunteer", "==", true)
      .where("VolunteerStatus", "==", "approved")
      .get();

    // Fetch each volunteer's form
    const volunteerEntries = await Promise.all(
      usersSnap.docs.map(async (doc) => {
        const u = doc.data();
        const loc = u.location;
        if (!loc || loc.lat == null || loc.lng == null) return null;

        let dist = 9999;
        if (
          requestData.location &&
          requestData.location.lat != null &&
          requestData.location.lng != null
        ) {
          dist = haversineKm(
            Number(requestData.location.lat),
            Number(requestData.location.lng),
            Number(loc.lat),
            Number(loc.lng)
          );
        }

        const formsSnap = await db
          .collection("users")
          .doc(doc.id)
          .collection("volunteer_forms")
          .orderBy("timestamp", "desc")
          .limit(1)
          .get();
        const form = formsSnap.empty ? {} : formsSnap.docs[0].data();

        return {
          volunteerId: doc.id,
          distanceKm: Math.round(dist * 100) / 100,
          profile: {
            username: u.username || null,
            skills: form.skills || null,
            experience: form.experience || null,
            education: form.education || null,
            motivation: form.motivation || null,
          },
        };
      })
    );

    const volunteers = volunteerEntries.filter(Boolean);

    if (volunteers.length === 0) {
      await reqRef.update({
        status: "no_volunteers",
        currentVolunteerId: null,
        currentVolunteerIndex: 0,
      });
      return { ok: true, rankedCount: 0 };
    }

    // OpenAI
    const openai = new OpenAI({
      apiKey: OPENAI_API_KEY.value(),
    });

const prompt = `
You are an emergency-response volunteer matching system.

You MUST return ONLY valid JSON.
Do NOT include markdown.
Do NOT include explanations outside JSON.
Do NOT include extra text.

Your task:
Rank volunteers from BEST to WORST for this specific help request.

Ranking priorities (in order of importance):
1) Medical / emergency relevance to the requester
2) Practical skills and real-world experience
3) Distance in kilometers (closer is better, but NEVER override skill or safety)
4) Reliability indicators if present (notes, experience, consistency)

Requester:
${JSON.stringify(requestData.resume || {}, null, 2)}

Volunteers:
${JSON.stringify(volunteers, null, 2)}

You MUST return EXACTLY this JSON format:
[
  {
    "volunteerId": "string",
    "score": 0.0,
    "distanceKm": 0.0,
    "reason": "short explanation of why this volunteer is ranked here"
  }
]
`;

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      temperature: 0,
      messages: [{ role: "user", content: prompt }],
    });

    const ranked = safeJsonParseFromModel(
      completion.choices[0].message.content
    );

    await db.collection("volunteers").doc(requestId).set({
      requestId,
      ranked,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await reqRef.update({
      status: "awaiting_volunteer",
      currentVolunteerId: ranked[0].volunteerId,
      currentVolunteerIndex: 0,
    });

    return { ok: true, rankedCount: ranked.length };
  }
);

// reject function

exports.rejectHelpRequest = onCall(async (request) => {
  const { auth, data } = request;

  if (!auth) {
    throw new Error("Authentication required");
  }

  const { requestId } = data || {};
  if (!requestId) {
    throw new Error("requestId is required");
  }

  const userId = auth.uid;

  const requestRef = db.collection("help_requests").doc(requestId);
  const rankedRef = db.collection("volunteers").doc(requestId);

  await db.runTransaction(async (tx) => {
    const reqSnap = await tx.get(requestRef);
    const rankedSnap = await tx.get(rankedRef);

    if (!reqSnap.exists || !rankedSnap.exists) {
      throw new Error("Request not found");
    }

    const requestData = reqSnap.data();
    const ranked = rankedSnap.data().ranked || [];

    if (requestData.status !== "awaiting_volunteer") {
      throw new Error("Request is not awaiting a volunteer");
    }

    if (requestData.currentVolunteerId !== userId) {
      throw new Error("You are not the assigned volunteer");
    }

    const nextIndex = (requestData.currentVolunteerIndex ?? 0) + 1;

    if (nextIndex >= ranked.length) {
      tx.update(requestRef, {
        status: "no_volunteers",
        currentVolunteerId: null,
        currentVolunteerIndex: nextIndex,
        lastResponse: "rejected",
        lastResponderId: userId,
        lastRespondedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return;
    }

    const nextVolunteerId = ranked[nextIndex].volunteerId;

    tx.update(requestRef, {
      currentVolunteerId: nextVolunteerId,
      currentVolunteerIndex: nextIndex,
      lastResponse: "rejected",
      lastResponderId: userId,
      lastRespondedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return { ok: true };
});

// push notification function

exports.notifyAssignedVolunteer = onDocumentUpdated(
    {
      document: "help_requests/{requestId}",
      region: "us-central1",
    },
    async (event) => {
    
    const beforeSnap = event.data?.before;
    const afterSnap = event.data?.after;

    if (!beforeSnap?.exists || !afterSnap?.exists) {
      return;
    }

    const before = beforeSnap.data();
    const after = afterSnap.data();

    if (
      before.currentVolunteerId === after.currentVolunteerId ||
      !after.currentVolunteerId ||
      after.status !== "awaiting_volunteer"
    ) {
      return;
    }

    const volunteerId = after.currentVolunteerId;
    const requestId = event.params.requestId;

    const volunteerSnap = await db.collection("users").doc(volunteerId).get();
    if (!volunteerSnap.exists) {
      console.log("Volunteer user not found:", volunteerId);
      return;
    }

    const volunteerData = volunteerSnap.data() || {};
    const fcmToken = volunteerData.fcmToken;

    if (!fcmToken) {
      console.log("No FCM token for volunteer:", volunteerId);
      return;
    }

    const payload = {
      token: fcmToken,
      notification: {
        title: "Emergency Assistance Needed",
        body: "A nearby user requires immediate help. Tap to respond.",
      },
      data: {
        type: "HELP_REQUEST",
        requestId: requestId,
      },
      android: {
        priority: "high",
        notification: {
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    };

    try {
      await admin.messaging().send(payload);
      console.log("Push notification sent to volunteer:", volunteerId);
    } catch (error) {
      console.error("Failed to send push notification:", error);
    }
  }
);
