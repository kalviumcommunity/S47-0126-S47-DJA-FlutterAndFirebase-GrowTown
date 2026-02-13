# Cloud Functions Integration - GrowTown

## Overview

This document explains the implementation of Google Cloud Functions in the GrowTown Flutter application. We have implemented both **Callable Cloud Functions** (manually triggered from the app) and **Firestore-triggered Cloud Functions** (automatically triggered by database changes).

## What are Cloud Functions?

Cloud Functions allow you to run backend logic without managing any servers. They are:
- **Event-driven**: Automatically triggered by Firebase events
- **Scalable**: Firebase handles scaling automatically
- **Cost-effective**: You only pay for what you use
- **Serverless**: No server management required

## Implementation

### 1. Callable Cloud Function: `greetUser`

**Purpose**: Generates personalized greetings for users by name

**Location**: [client/functions/src/index.ts](../functions/src/index.ts#L33)

**Function Code**:
```typescript
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

    logger.log("Greeting generated:", greeting);
    return greeting;
  } catch (error) {
    logger.error("Error in greetUser function:", error);
    throw new Error("Failed to generate greeting");
  }
});
```

**How it works**:
- Called directly from the Flutter app via HTTP
- Receives a user's name as input
- Returns a personalized greeting message with timestamp
- Logs all interactions to Firebase Console

**Benefits**:
- Real-time response from backend
- User authentication validation
- Error handling and logging
- No server infrastructure needed

### 2. Firestore-Triggered Function: `onUserCreated`

**Purpose**: Automatically creates welcome messages and updates user metadata when a new user document is created

**Location**: [client/functions/src/index.ts#L58](../functions/src/index.ts#L58)

**Function Code**:
```typescript
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
```

**How it works**:
- Automatically triggers when a new user document is created in Firestore
- Creates a welcome notification document
- Updates user metadata (creation time and status)
- Logs all operations for monitoring

**Benefits**:
- Automatic onboarding process
- No manual intervention needed
- Ensures data consistency
- Complete audit trail through logs

## Flutter Integration

### Cloud Functions Service

**Location**: [client/lib/services/cloud_functions_service.dart](../lib/services/cloud_functions_service.dart)

This service provides a clean interface to call Cloud Functions:

```dart
// Simple greeting call
final message = await CloudFunctionsService.greetUser('Alex');

// Full greeting response
final response = await CloudFunctionsService.getFullGreeting('Alex');
print(response['message']);
print(response['timestamp']);
print(response['userId']);
```

### Cloud Functions Demo Screen

**Location**: [client/lib/screens/cloud_functions_screen.dart](../lib/screens/cloud_functions_screen.dart)

A complete UI for testing the callable Cloud Function:
- Input field for user name
- Call button to trigger the function
- Response display with details
- Error handling
- Loading states

**Route**: `/cloudFunctions` (added to [main.dart](../lib/main.dart))

## Setup Instructions

### Prerequisites
- Firebase project with Cloud Functions enabled
- Flutter SDK configured
- Node.js 20+ installed

### 1. Install Dependencies

**Flutter**:
```bash
cd client
flutter pub add cloud_functions
flutter pub get
```

**Cloud Functions**:
```bash
cd client/functions
npm install
```

### 2. Build Cloud Functions

```bash
cd client/functions
npm run build
```

Compiled functions are in the `lib/` directory.

### 3. Deploy Cloud Functions

```bash
cd client/functions
firebase deploy --only functions
```

### 4. Configure Firestore Rules

Ensure your Firestore rules allow the functions to write to the database:

```
match /users/{userId} {
  allow read: if request.auth.uid == userId;
  allow create: if request.auth.uid == userId;
  allow update: if request.auth.uid == userId;
  allow write: if request.service.admin == true;
}
```

### 5. Test in Flutter App

1. Run the Flutter app
2. Navigate to the Cloud Functions demo screen (route: `/cloudFunctions`)
3. Enter your name and click "Call Cloud Function"
4. Observe the response

## Verification & Monitoring

### Firebase Console Logs

Check function execution logs:
1. Go to **Firebase Console** → **Functions** → **Logs**
2. Filter by function name:
   - `greetUser` - for callable function
   - `onUserCreated` - for Firestore trigger
3. View:
   - Execution temperature and duration
   - Input data received
   - Output/response data
   - Any errors encountered

### Example Log Entry for `greetUser`:
```
Timestamp: 2:45:30 PM
Message: Greeting generated: { message: "Hello, Alex! Welcome to GrowTown!", timestamp: "2026-02-13T14:45:30Z", userId: "user123" }
Severity: DEFAULT
```

### Example Log Entry for `onUserCreated`:
```
Timestamp: 3:20:15 PM
Message: Welcome message created and user metadata updated
Severity: DEFAULT
```

## Why Use Serverless Functions?

### 1. **Backend Logic Without Servers**
- No need to manage EC2 instances, load balancers, or infrastructure
- Focus on business logic, not DevOps

### 2. **Automatic Scaling**
- Handles traffic spikes automatically
- No manual scaling configuration needed

### 3. **Cost Effective**
- Pay only for actual execution time
- Free tier includes 2M function invocations/month

### 4. **Security**
- Runs in Google's secure infrastructure
- Built-in authentication validation
- Environment variables for secrets

### 5. **Integration with Firebase**
- Direct access to Firestore, Realtime Database, Storage
- No API gateway complexity
- Native event triggers

## Use Cases Implemented

### 1. Callable Function Use Case
**Scenario**: User welcome message customization
- User enters their name in the app
- App calls `greetUser` Cloud Function
- Function generates personalized message
- Response displayed immediately to user

**Benefits**: 
- Offloads processing to backend
- Can add complex business logic later
- Maintains user engagement with instant response

### 2. Firestore Trigger Use Case
**Scenario**: New user onboarding automation
- New user account created via Firebase Auth
- User document created in Firestore
- Cloud Function automatically triggers
- Welcome notification created
- User metadata updated

**Benefits**:
- Fully automated onboarding
- No manual intervention
- Ensures all new users get welcome message
- Maintains data consistency

## Common Issues & Solutions

### Issue 1: Function Timeout
**Problem**: Function takes too long to execute
**Solution**: 
- Optimize Firestore queries
- Use batch operations
- Increase timeout in function configuration

### Issue 2: Permissions Error
**Problem**: Function cannot write to Firestore
**Solution**:
- Update Firestore security rules
- Ensure service account has proper permissions
- Check function region configuration

### Issue 3: Cold Start Latency
**Problem**: First function call is slow
**Solution**:
- Expected behavior for serverless
- Subsequent calls are faster
- Use min instances for production

## Architecture Diagram

```
┌─────────────────────┐
│   Flutter App       │
│   (GrowTown)        │
└──────────┬──────────┘
           │
           │ HTTP Request
           │ (greetUser)
           ↓
┌──────────────────────────┐
│  callable Cloud Function │
│  (greetUser)             │
│  - Process request       │
│  - Generate greeting     │
│  - Return response       │
└──────────┬───────────────┘
           │
           │ HTTP Response
           ↓
┌──────────────────────────┐
│  Flutter App             │
│  Display greeting        │
└──────────────────────────┘


User Registration Flow:
┌──────────────────┐
│  Firebase Auth   │
│  Create User     │
└────────┬─────────┘
         │
         ↓
┌──────────────────────┐
│   Firestore          │
│  Create user doc     │
└────────┬─────────────┘
         │ Triggers
         ↓
┌──────────────────────────┐
│  Firestore Trigger       │
│  onUserCreated           │
│  - Create notification   │
│  - Update metadata       │
└──────────────────────────┘
```

## Dependencies

**Flutter Package**:
```yaml
cloud_functions: ^5.0.0
firebase_core: ^3.0.0
firebase_auth: ^5.0.0
```

**Cloud Functions (Node.js)**:
```json
{
  "firebase-functions": "^7.0.0",
  "firebase-admin": "^13.6.0"
}
```

## Next Steps

### Enhancement Ideas
1. **Email Notifications**: Send welcome email via Cloud Function
2. **Data Validation**: Validate user input before Firestore write
3. **Analytics**: Track function usage and performance
4. **Scheduled Tasks**: Run cleanup functions on schedule
5. **Integration with Third-party APIs**: Call external services

### Production Considerations
1. Enable function monitoring and alerting
2. Set up error reporting
3. Implement function versioning
4. Add comprehensive logging
5. Set rate limiting and quotas

## References

- [Firebase Cloud Functions Documentation](https://firebase.google.com/docs/functions)
- [Cloud Functions for Firebase - Best Practices](https://firebase.google.com/docs/functions/bestpractices/retries)
- [Flutter cloud_functions Package](https://pub.dev/packages/cloud_functions)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)

---

**Implementation Date**: February 13, 2026
**Team**: GrowTown Development Squad
**Status**: ✅ Complete and Tested
