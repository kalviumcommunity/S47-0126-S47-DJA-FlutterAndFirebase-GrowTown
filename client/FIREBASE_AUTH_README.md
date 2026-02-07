# GrowTown - Firebase Email & Password Authentication

## 📱 Project Overview

GrowTown is a Flutter application that implements Firebase Email & Password Authentication to provide secure user registration and login functionality. This implementation allows users to create accounts, sign in, and access protected features of the application.

---

## 🔐 Authentication Features

- ✅ **User Signup** with email and password
- ✅ **User Login** with credential validation
- ✅ **Authentication State Management** (auto-redirect based on login status)
- ✅ **Logout Functionality** with session management
- ✅ **Error Handling** with user-friendly messages
- ✅ **Form Validation** for email and password fields
- ✅ **Firebase Integration** with real-time user verification

---

## 🚀 Setup Instructions

### 1. Enable Email & Password Authentication in Firebase Console

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Navigate to **Authentication** → **Sign-in method**
3. Click on **Email/Password**
4. Enable the toggle switch
5. Click **Save**

This configuration allows your app to perform signup and login operations through Firebase Auth APIs.

---

### 2. Add Firebase Auth Dependency

The `firebase_auth` package has been added to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0  # ✅ Firebase Authentication
```

Install the packages:

```bash
flutter pub get
```

---

### 3. Firebase Initialization

Firebase is initialized in `main.dart` before the app starts:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

---

## 📝 Implementation Details

### Authentication UI Components

#### Login Screen (`login_screen.dart`)
- Email TextField with validation
- Password TextField with show/hide toggle
- Login button with loading indicator
- Navigation to signup screen
- Error handling with SnackBar messages

#### Signup Screen (`create_account_screen.dart`)
- Full Name TextField
- Email TextField with validation
- Password TextField (minimum 6 characters)
- Confirm Password with matching validation
- Signup button with loading indicator
- Navigation back to login screen

---

## 🔧 Code Snippets

### User Signup Implementation

```dart
Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  try {
    // Firebase Email/Password Signup
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    // Update display name (optional)
    await userCredential.user?.updateDisplayName(_nameController.text.trim());

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacementNamed(context, '/dashboard');
  } on FirebaseAuthException catch (e) {
    String errorMessage = 'Signup failed';
    if (e.code == 'weak-password') {
      errorMessage = 'Password is too weak';
    } else if (e.code == 'email-already-in-use') {
      errorMessage = 'An account already exists with this email';
    } else if (e.code == 'invalid-email') {
      errorMessage = 'Invalid email address';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

---

### User Login Implementation

```dart
Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  try {
    // Firebase Email/Password Login
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login Successful!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacementNamed(context, '/dashboard');
  } on FirebaseAuthException catch (e) {
    String errorMessage = 'Login failed';
    if (e.code == 'user-not-found') {
      errorMessage = 'No user found with this email';
    } else if (e.code == 'wrong-password') {
      errorMessage = 'Incorrect password';
    } else if (e.code == 'invalid-email') {
      errorMessage = 'Invalid email address';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

---

### Authentication State Management

The app uses a `StreamBuilder` to listen to authentication state changes:

```dart
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is logged in
        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen();
        }

        // User is not logged in
        return const LoginScreen();
      },
    );
  }
}
```

---

### Logout Implementation

```dart
// In dashboard_screen.dart
_sideItem(
  context,
  Icons.logout,
  "Logout",
  false,
  onTap: () async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  },
),
```

---

## 📸 Screenshots

### 1. Authentication UI
*[Add screenshot of your login screen here]*

### 2. Signup Screen
*[Add screenshot of your signup screen here]*

### 3. Firebase Console - Users Table
*[Add screenshot of Firebase Console showing registered users]*

To capture Firebase Console screenshot:
1. Go to Firebase Console → Authentication → Users
2. You should see registered users with their email addresses
3. Take a screenshot showing the users table

### 4. Successful Login
*[Add screenshot showing successful login with dashboard]*

---

## ✅ Testing Checklist

- [x] Signup creates a new user account
- [x] New users appear in Firebase Console
- [x] Login works with valid credentials
- [x] Login fails with incorrect password (shows error)
- [x] Login fails with non-existent email (shows error)
- [x] Email validation prevents invalid formats
- [x] Password must be at least 6 characters
- [x] Logout functionality clears the session
- [x] AuthStateChanges redirects users appropriately

---

## 🎯 How to Test the Application

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the Application
```bash
flutter run
```

### 3. Test Signup Flow
1. Open the app
2. Navigate to "Sign Up" screen
3. Enter:
   - Full Name: `Test User`
   - Email: `testuser@example.com`
   - Password: `password123`
   - Confirm Password: `password123`
4. Tap "Create Account"
5. Verify account creation in Firebase Console

### 4. Test Login Flow
1. Navigate to Login screen
2. Enter the email and password from signup
3. Tap "Login"
4. Verify you're redirected to Dashboard

### 5. Verify User in Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Go to Authentication → Users
3. You should see your test user listed

### 6. Test Logout
1. In the Dashboard, click "Logout" in the sidebar
2. Verify you're redirected to Login screen

---

## 🔍 Error Handling

The app handles various Firebase authentication errors:

| Error Code | User-Friendly Message |
|-----------|----------------------|
| `weak-password` | Password is too weak |
| `email-already-in-use` | An account already exists with this email |
| `invalid-email` | Invalid email address |
| `user-not-found` | No user found with this email |
| `wrong-password` | Incorrect password |
| `user-disabled` | This account has been disabled |

---

## 💡 Reflection

### Why Firebase Auth is Useful

1. **Security**: Firebase handles password hashing, encryption, and secure storage automatically
2. **Scalability**: Built to handle millions of users without infrastructure management
3. **Integration**: Seamless integration with other Firebase services (Firestore, Storage, etc.)
4. **Cross-Platform**: Same authentication works across iOS, Android, and Web
5. **NO Backend Required**: No need to build and maintain your own authentication server
6. **Built-in Features**: Email verification, password reset, and multi-factor authentication ready to use

### Challenges Faced During Implementation

1. **Error Handling**: Understanding different FirebaseAuthException error codes
   - **Solution**: Created a comprehensive error mapping system for user-friendly messages

2. **State Management**: Managing authentication state across the app
   - **Solution**: Implemented AuthWrapper with StreamBuilder for real-time state listening

3. **Navigation Flow**: Preventing users from going back to login after authentication
   - **Solution**: Used `Navigator.pushReplacementNamed` to replace navigation stack

4. **Form Validation**: Ensuring data quality before Firebase requests
   - **Solution**: Implemented Flutter's built-in Form validation with custom validators

5. **Async Operations**: Handling loading states during network requests
   - **Solution**: Added loading indicators and proper async/await patterns

### Lessons Learned

- Always validate user input before making API calls
- Provide clear feedback for both success and error cases
- Use `mounted` checks before updating UI after async operations
- Firebase Auth errors should be translated to user-friendly messages
- Authentication state should be managed at the app level, not screen level

---

## 📦 Project Structure

```
lib/
├── main.dart                          # App entry point with Firebase initialization
├── firebase_options.dart              # Auto-generated Firebase config
├── screens/
│   ├── auth_wrapper.dart             # Authentication state manager
│   ├── login_screen.dart             # Login UI with Firebase Auth
│   ├── create_account_screen.dart    # Signup UI with Firebase Auth
│   ├── dashboard_screen.dart         # Protected screen with logout
│   └── ...
└── widgets/
    └── ...
```

---

## 🎬 Video Demo

*[Record a 1-2 minute video demonstration showing:]*
- Signup flow (creating a new account)
- Login flow (signing in with credentials)
- Firebase Console verification (showing user in Users table)
- Logout functionality
- Brief code walkthrough of authentication logic

**Upload to:** Google Drive / Loom / YouTube (unlisted)  
**Access:** Set to "Anyone with the link"  
**Video Link:** [Add your video link here]

---

## 📚 Additional Resources

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/auth/overview)
- [Firebase Console](https://console.firebase.google.com/)

---

## 👥 Team Information

**Team Name:** [Your Team Name]  
**Sprint:** Sprint-2  
**Feature:** Firebase Email & Password Authentication

---

## 🚀 Submission

### Pull Request
- **Branch:** `feat/firebase-auth`
- **Commit Message:** `feat: implemented Firebase email-password authentication`
- **PR Title:** `[Sprint-2] Firebase Email & Password Authentication – [TeamName]`

### PR Description Template
```markdown
## Summary
Implemented Firebase Email & Password Authentication with complete signup, login, and logout functionality.

## Features Implemented
- ✅ User signup with email and password
- ✅ User login with credential validation
- ✅ Authentication state management
- ✅ Logout functionality
- ✅ Error handling with user-friendly messages
- ✅ Form validation

## Screenshots
[Add screenshots here]

## Firebase Console Verification
[Add screenshot of users in Firebase Console]

## Testing
All authentication flows have been tested:
- Signup creates users successfully
- Login validates credentials correctly
- Error messages display appropriately
- Logout clears session properly

## Video Demo
[Add video link here]

## Reflection
[Add your reflection about the implementation process]
```

---

## ✨ Next Steps

- [ ] Add email verification
- [ ] Implement password reset functionality
- [ ] Add social authentication (Google, Facebook)
- [ ] Implement profile management
- [ ] Add multi-factor authentication
- [ ] Store additional user data in Firestore

---

**Built with ❤️ using Flutter & Firebase**
