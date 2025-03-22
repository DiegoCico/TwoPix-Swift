import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();
const bucket = admin.storage().bucket();

export const deleteOldChatMessages = onSchedule(
  {schedule: "every 24 hours"},
  async (): Promise<void> => {
    const now = admin.firestore.Timestamp.now();
    const oneWeekAgo = admin.firestore.Timestamp.fromMillis(
      now.toMillis() - 7 * 24 * 60 * 60 * 1000
    );
    const chatQuerySnapshot = await db.collectionGroup("chats")
      .where("timestamp", "<", oneWeekAgo)
      .get();
    const batch = db.batch();
    chatQuerySnapshot.forEach((doc) => {
      batch.delete(doc.ref);
    });
    await batch.commit();
    logger.info(
      "Deleted " + chatQuerySnapshot.size +
      " chat messages older than one week"
    );
    return;
  }
);

export const deleteOldPhotos = onSchedule(
  {schedule: "every 24 hours"},
  async (): Promise<void> => {
    const now = admin.firestore.Timestamp.now();
    const oneMonthAgo = admin.firestore.Timestamp.fromMillis(
      now.toMillis() - 30 * 24 * 60 * 60 * 1000
    );
    const photosQuerySnapshot = await db.collection("photos")
      .where("timestamp", "<", oneMonthAgo)
      .get();
    const deletionPromises: Promise<void>[] = [];
    photosQuerySnapshot.forEach((doc) => {
      const filePath = "images/" + doc.id + ".jpg";
      deletionPromises.push(
        bucket.file(filePath)
          .delete()
          .then((): void => undefined)
          .catch((err) => {
            logger.error("Error deleting file " + filePath + ": " + err);
          })
      );
      deletionPromises.push(
        doc.ref.delete().then((): void => undefined)
      );
    });
    await Promise.all(deletionPromises);
    logger.info(
      "Deleted " + photosQuerySnapshot.size +
      " photos and their metadata older than one month"
    );
    return;
  }
);
