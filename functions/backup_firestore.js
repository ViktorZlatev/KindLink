const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function exportCollection(ref) {
  const snapshot = await ref.get();
  const result = {};

  for (const doc of snapshot.docs) {
    result[doc.id] = { _data: doc.data(), _subcollections: {} };

    const subcollections = await doc.ref.listCollections();
    for (const sub of subcollections) {
      result[doc.id]._subcollections[sub.id] = await exportCollection(sub);
    }
  }

  return result;
}

async function run() {
  console.log("Starting Firestore backup...");

  const collections = await db.listCollections();
  const backup = {};

  for (const col of collections) {
    console.log(`  Exporting: ${col.id}`);
    backup[col.id] = await exportCollection(col);
  }

  const timestamp = new Date()
    .toISOString()
    .replace(/T/, "_")
    .replace(/:/g, "-")
    .replace(/\..+/, "");

  const outDir = path.join(__dirname, "..", "backups");
  fs.mkdirSync(outDir, { recursive: true });

  const outFile = path.join(outDir, `backup_${timestamp}.json`);
  fs.writeFileSync(outFile, JSON.stringify(backup, null, 2));

  console.log(`Done. Saved to: ${outFile}`);
}

run().catch((err) => {
  console.error("Backup failed:", err.message);
  process.exit(1);
});
