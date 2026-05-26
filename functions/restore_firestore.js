const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Firestore batch limit is 500 operations
const BATCH_SIZE = 400;
let pending = [];
let totalWritten = 0;

async function flushBatch() {
  if (pending.length === 0) return;
  const batch = db.batch();
  for (const { ref, data } of pending) {
    batch.set(ref, data);
  }
  await batch.commit();
  totalWritten += pending.length;
  pending = [];
}

async function restoreCollection(parentRef, collectionId, docs) {
  for (const [docId, docValue] of Object.entries(docs)) {
    const docRef = parentRef
      ? parentRef.collection(collectionId).doc(docId)
      : db.collection(collectionId).doc(docId);

    pending.push({ ref: docRef, data: docValue._data });

    if (pending.length >= BATCH_SIZE) {
      await flushBatch();
    }

    // Recurse into subcollections
    for (const [subId, subDocs] of Object.entries(
      docValue._subcollections || {}
    )) {
      await restoreCollection(docRef, subId, subDocs);
    }
  }
}

async function run() {
  const backupDir = path.join(__dirname, "..", "backups");
  const files = fs
    .readdirSync(backupDir)
    .filter((f) => f.startsWith("backup_") && f.endsWith(".json"))
    .sort();

  if (files.length === 0) {
    console.error("No backup files found in backups/");
    process.exit(1);
  }

  // Use the file passed as argument, or default to the latest backup
  const target = process.argv[2]
    ? path.resolve(process.argv[2])
    : path.join(backupDir, files[files.length - 1]);

  if (!fs.existsSync(target)) {
    console.error(`File not found: ${target}`);
    process.exit(1);
  }

  console.log(`Restoring from: ${path.basename(target)}`);
  console.log("WARNING: This will overwrite existing documents. Ctrl+C to abort.");
  await new Promise((r) => setTimeout(r, 3000));

  const backup = JSON.parse(fs.readFileSync(target, "utf8"));

  for (const [collectionId, docs] of Object.entries(backup)) {
    console.log(`  Restoring: ${collectionId}`);
    await restoreCollection(null, collectionId, docs);
  }

  await flushBatch();
  console.log(`Done. ${totalWritten} documents restored.`);
}

run().catch((err) => {
  console.error("Restore failed:", err.message);
  process.exit(1);
});
