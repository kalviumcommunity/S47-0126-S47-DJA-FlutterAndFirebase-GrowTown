/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {setGlobalOptions} from "firebase-functions";
import {onCall} from "firebase-functions/v2/https";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";

// Initialize Firebase Admin SDK
initializeApp();

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

/**
 * CALLABLE CLOUD FUNCTION
 * Greets a user by name
 * Called directly from the Flutter app
 */
export const greetUser = onCall(async (request) => {
  const data = request.data;
  const name = data.name || "Guest User";

  logger.info("Greeting function called", {name, uid: request.auth?.uid});

  try {
    const greeting = {
      message: `Hello, ${name}! Welcome to GrowTown!`,
      timestamp: new Date().toISOString(),
      userId: request.auth?.uid || "anonymous",
    };

    // Log the greeting for demonstration
    logger.log("Greeting generated:", greeting);

    return greeting;
  } catch (error) {
    logger.error("Error in greetUser function:", error);
    throw new Error("Failed to generate greeting");
  }
});

/**
 * FIRESTORE TRIGGERED CLOUD FUNCTION
 * Triggers automatically when a new user document is created
 * Creates a welcome message document
 */
export const onUserCreated = onDocumentCreated(
  "users/{userId}",
  async (event) => {
    const userId = event.params.userId;
    const userData = event.data?.data();

    logger.info("New user document created", {
      userId,
      email: userData?.email || "unknown",
    });

    try {
      const db = getFirestore();
      const userRef = db.collection("users").doc(userId);

      // Create a welcome message in the user's subcollection
      const welcomeRef = userRef.collection("notifications").doc("welcome");
      await welcomeRef.set({
        type: "welcome",
        title: "Welcome to GrowTown!",
        message: `Welcome, ${userData?.displayName || "Guest"}! Your account has been created successfully.`,
        createdAt: new Date(),
        read: false,
      });

      // Update user document with metadata
      await userRef.update({
        accountCreatedAt: new Date(),
        status: "active",
      });

      logger.log("Welcome message created and user metadata updated", {userId});
      return null;
    } catch (error) {
      logger.error("Error in onUserCreated function:", error);
      throw error;
    }
  }
);
