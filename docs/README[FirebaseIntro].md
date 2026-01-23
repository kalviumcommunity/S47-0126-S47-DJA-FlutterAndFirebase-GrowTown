# Firebase Integration: Authentication & Firestore

## Project Overview
This Flutter project demonstrates the integration of Firebase Authentication and Cloud Firestore. The app allows users to sign up, log in securely, and store or retrieve data in real time from the cloud. This implementation converts a static Flutter application into a dynamic, cloud-connected mobile app.

---

## Features Implemented
- Email and password authentication using Firebase Authentication
- User signup, login, and logout
- Cloud Firestore integration
- CRUD operations on Firestore data
- Real-time data updates using StreamBuilder
- Data persistence verified through Firebase Console

---

## Tech Stack Used
- Flutter
- Firebase Authentication
- Cloud Firestore
- FlutterFire CLI

---

## Firebase Setup Instructions

### Step 1: Create Firebase Project
Create a new Firebase project using the Firebase Console and add your Flutter Android and/or iOS app to the project.

### Step 2: Add Configuration Files
Add google-services.json inside the android/app/ directory.
Add GoogleService-Info.plist inside the ios/Runner/ directory.

### Step 3: Configure Firebase Using FlutterFire CLI
Run the flutterfire configure command to link the Firebase project with the Flutter app.

### Step 4: Add Dependencies
Add the following dependencies in pubspec.yaml:
firebase_core version ^3.0.0  
firebase_auth version ^5.0.0  
cloud_firestore version ^5.0.0  

### Step 5: Initialize Firebase
Firebase is initialized in the main.dart file before running the app using Firebase.initializeApp().

---

## Firebase Authentication Implementation

An auth_service.dart file is created under lib/services/ to handle authentication logic.

The signup function creates a new user using email and password through Firebase Authentication.
The login function authenticates an existing user.
The logout function signs the user out of the application.

After successful login, the user is navigated to a home or dashboard screen that displays a welcome message.

---

## UI Screens
- signup_screen.dart for registering new users
- login_screen.dart for authenticating existing users
- home/dashboard screen shown after successful login

---

## Cloud Firestore Integration

A firestore_service.dart file is created under lib/services/ to manage database operations.

Firestore operations implemented:
- Create: Add user-specific data to a Firestore collection
- Read: Retrieve data in real time
- Update: Modify existing Firestore records
- Delete: Remove records from Firestore

Firestore data is displayed in the app using StreamBuilder so updates appear instantly without refreshing.

---

## Testing and Validation
The following scenarios were tested successfully:
- New user signup
- User login with valid credentials
- Adding data to Firestore
- Updating existing Firestore data
- Deleting Firestore records
- Verifying Authentication users and Firestore entries in Firebase Console

---

## Screenshots
The following screenshots are included in the repository:
- Signup screen
- Login screen
- Firestore data displayed in the app
- Firebase Console showing Authentication users
- Firebase Console showing Firestore database entries

---

## Reflection

### Challenges Faced
The main challenge was configuring Firebase correctly and ensuring all dependencies were compatible with the Flutter version. Handling asynchronous Firebase authentication and Firestore operations also required careful implementation to avoid errors.

### Learnings
Firebase simplifies backend development by providing ready-made authentication and real-time database services. Integrating Firebase with Flutter helped me understand how cloud services enable scalable, real-time, and secure mobile applications with minimal backend effort.

---

