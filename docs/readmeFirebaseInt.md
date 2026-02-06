# Firebase Email & Password Authentication (Flutter)

## Project Overview
This project demonstrates secure user authentication in a Flutter application using **Firebase Authentication (Email & Password)**.  
Users can create new accounts, log in with existing credentials, and Firebase automatically manages authentication and user sessions.

This authentication setup will be used as a foundation for future features like Firestore and Cloud Functions.

---

## Features Implemented
- User Signup using Email & Password
- User Login using Email & Password
- Firebase Console automatically updates registered users
- Error handling for invalid credentials
- Simple and clean authentication UI

---

## Firebase Authentication Setup

### Steps to Enable Email/Password Authentication
1. Open **Firebase Console**
2. Select your Firebase project
3. Go to **Authentication**
4. Click **Sign-in method**
5. Enable **Email/Password**
6. Click **Save**

---

## Dependencies Used

```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0


After adding dependencies, run:

flutter pub get

Firebase Initialization

Firebase is initialized in main.dart using firebase_options.dart:

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

Authentication UI

The authentication screen includes:

Email TextField

Password TextField

Login / Signup button

Toggle between Login and Signup

Signup Code Snippet
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);

Login Code Snippet
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

User Feedback (Snackbar)
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Login Successful')),
);

Screenshots
Authentication Screen

Firebase Console – Users

Login Success

Testing & Verification

The following scenarios were tested:

Signup with new email works correctly

Login with valid credentials succeeds

Login with incorrect credentials shows error

New users appear in Firebase Console

Reflection
Why Firebase Authentication is Useful

Firebase Authentication is secure, reliable, and easy to integrate. It removes the need to create and manage a backend for authentication and handles user sessions automatically.

Challenges Faced

Correct Firebase setup and initialization

Handling authentication errors properly

Managing login and signup states in the UI

Git & Submission Details
Commit Message
feat: implemented Firebase email-password authentication

Pull Request Title
[Sprint-2] Firebase Email & Password Authentication – TeamName

Pull Request Includes

Authentication implementation summary

Screenshots

Reflection

Video demo link

Video Demo

A short video demonstrates:

User Signup

User Login

Firebase Console showing registered users

Video Link: (Add your Drive / Loom / YouTube link here)

Conclusion

This task successfully implements Firebase Email & Password Authentication in Flutter. The app securely handles user login and signup while maintaining smooth performance and scalability for future Firebase features.