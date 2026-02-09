# Persistent User Sessions Implementation

## Project Overview
**GrowTown** - Customer Management System with Firebase Authentication

This document explains the implementation of **persistent user sessions** in the GrowTown Flutter application using Firebase Authentication. Persistent sessions ensure that logged-in users remain authenticated even after closing or restarting the app, providing a seamless and professional mobile experience.

---

## Table of Contents
1. [What are Persistent Sessions?](#what-are-persistent-sessions)
2. [Implementation Details](#implementation-details)
3. [Code Implementation](#code-implementation)
4. [Auto-Login Flow](#auto-login-flow)
5. [Logout Flow](#logout-flow)
6. [Testing Results](#testing-results)
7. [Screenshots](#screenshots)
8. [Reflection](#reflection)

---

## What are Persistent Sessions?

Persistent sessions allow users to remain logged in across app restarts without requiring them to enter credentials repeatedly. Firebase Authentication handles this automatically by:

- **Storing secure authentication tokens** on the device
- **Automatically refreshing tokens** in the background
- **Providing real-time auth state updates** via streams
- **Managing session security** without manual token storage

### Key Benefits
- ✅ **Improved User Experience**: Users don't need to log in every time
- ✅ **Seamless Navigation**: App opens directly to the home screen for logged-in users
- ✅ **Security**: Firebase manages token encryption and refresh automatically
- ✅ **Real-time Updates**: Auth changes reflect immediately across the app

---

## Implementation Details

### Architecture Pattern
The app uses the **AuthWrapper** pattern with **StreamBuilder** to listen to Firebase authentication state changes globally.

### Flow Diagram
```
App Launch
    ↓
Splash Screen (2 seconds)
    ↓
AuthWrapper (checks auth state)
    ↓
    ├─→ ConnectionState.waiting → Loading Screen
    ├─→ User logged in → Dashboard Screen (Auto-Login)
    └─→ No user → Login Screen
```

### Key Components

#### 1. **AuthWrapper** (`lib/screens/auth_wrapper.dart`)
Central authentication state manager that listens to Firebase auth changes.

#### 2. **Splash Screen** (`lib/screens/splash_screen.dart`)
Initial loading screen that transitions to AuthWrapper after 2 seconds.

#### 3. **Main App** (`lib/main.dart`)
Configured to use splash screen as initial route, which then navigates to AuthWrapper.

#### 4. **Logout Implementation**
Multiple logout points (Dashboard sidebar, Profile screen) all navigate to AuthWrapper after sign out.

---

## Code Implementation

### 1. AuthWrapper with StreamBuilder

**File**: `lib/screens/auth_wrapper.dart`

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

/// AuthWrapper listens to authentication state changes and
/// redirects users to the appropriate screen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to authentication state changes
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1F8F88), Color(0xFF2FB8AA)],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // User is logged in - auto-login to dashboard
        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen();
        }

        // User is not logged in - show login screen
        return const LoginScreen();
      },
    );
  }
}
```

### 2. Splash Screen Navigation

**File**: `lib/screens/splash_screen.dart`

```dart
@override
void initState() {
  super.initState();
  // Show splash for 2 seconds then navigate to AuthWrapper
  // AuthWrapper will handle routing to correct screen based on login state
  Future.delayed(const Duration(seconds: 2), () {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  });
}
```

### 3. Main App Configuration

**File**: `lib/main.dart`

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(...),
      initialRoute: '/splash',  // Start with splash screen
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/auth': (context) => const AuthWrapper(),  // Auth state manager
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        // ... other routes
      },
    );
  }
}
```

### 4. Logout Implementation

#### Profile Screen Logout
**File**: `lib/screens/profile_screen.dart`

```dart
Future<void> _confirmLogout() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Logout'),
        ),
      ],
    ),
  );

  if (confirm == true) {
    await FirebaseAuth.instance.signOut();
    // No need to manually navigate - AuthWrapper will detect signOut
    // and automatically redirect to LoginScreen
    if (!mounted) return;
    // Navigate to AuthWrapper which will handle routing
    Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
  }
}
```

#### Dashboard Sidebar Logout
**File**: `lib/screens/dashboard_screen.dart`

```dart
_sideItem(
  context,
  Icons.logout,
  "Logout",
  false,
  onTap: () async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  },
),
```

---

## Auto-Login Flow

### How It Works

1. **User logs in successfully** via Login Screen
2. Firebase stores authentication token securely on device
3. **User closes the app completely**
4. **User reopens the app**
5. App shows Splash Screen (2 seconds)
6. Navigates to AuthWrapper
7. **AuthWrapper checks auth state**:
   - `FirebaseAuth.instance.authStateChanges()` returns current user
8. **User is automatically redirected to Dashboard** (Auto-Login Success!)

### Code Flow
```dart
StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    // Auto-login happens here
    if (snapshot.hasData && snapshot.data != null) {
      return const DashboardScreen();  // ← User goes here automatically
    }
    return const LoginScreen();
  },
)
```

### Testing Auto-Login
1. ✅ Login with valid credentials
2. ✅ Navigate to Dashboard
3. ✅ Close app completely (force stop on Android, swipe away on iOS)
4. ✅ Reopen app
5. ✅ **Result**: App skips Login Screen and goes directly to Dashboard

---

## Logout Flow

### How It Works

1. **User clicks Logout** (from Dashboard or Profile)
2. **Confirmation dialog** appears
3. User confirms logout
4. `FirebaseAuth.instance.signOut()` is called
5. Firebase removes authentication token
6. **AuthWrapper detects state change** via `authStateChanges()` stream
7. **User is automatically redirected to Login Screen**

### Code Flow
```dart
// Step 1-3: User confirms logout
await FirebaseAuth.instance.signOut();  // Step 4: Sign out

// Step 5: Navigate to AuthWrapper
Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);

// Step 6-7: AuthWrapper automatically shows LoginScreen
if (snapshot.hasData && snapshot.data != null) {
  return const DashboardScreen();
} else {
  return const LoginScreen();  // ← User goes here after logout
}
```

### Testing Logout
1. ✅ Login to app
2. ✅ Navigate to Profile or Dashboard
3. ✅ Click Logout button
4. ✅ Confirm logout in dialog
5. ✅ **Result**: User is redirected to Login Screen
6. ✅ Close and reopen app
7. ✅ **Result**: Login Screen appears (not Dashboard)

---

## Testing Results

### Test Case 1: Auto-Login After Restart
| Step | Action | Expected Result | Actual Result | Status |
|------|--------|----------------|---------------|--------|
| 1 | Login with valid credentials | Navigate to Dashboard | ✅ Navigated to Dashboard | ✅ PASS |
| 2 | Close app completely | App terminates | ✅ App closed | ✅ PASS |
| 3 | Reopen app | Show Splash → Auto-login to Dashboard | ✅ Dashboard shown without login | ✅ PASS |
| 4 | Check user info in Profile | Display logged-in user details | ✅ User details displayed | ✅ PASS |

### Test Case 2: Logout Persistence
| Step | Action | Expected Result | Actual Result | Status |
|------|--------|----------------|---------------|--------|
| 1 | Login to app | Navigate to Dashboard | ✅ Navigated to Dashboard | ✅ PASS |
| 2 | Click Logout from Profile | Show confirmation dialog | ✅ Dialog shown | ✅ PASS |
| 3 | Confirm logout | Redirect to Login Screen | ✅ Login Screen shown | ✅ PASS |
| 4 | Close app | App terminates | ✅ App closed | ✅ PASS |
| 5 | Reopen app | Show Splash → Login Screen (not Dashboard) | ✅ Login Screen shown | ✅ PASS |

### Test Case 3: Loading State Visibility
| Step | Action | Expected Result | Actual Result | Status |
|------|--------|----------------|---------------|--------|
| 1 | Open app on slow network | Show loading indicator while checking auth | ✅ Loading screen visible | ✅ PASS |
| 2 | Auth check completes | Navigate to appropriate screen | ✅ Correct screen shown | ✅ PASS |

### Test Case 4: Multiple Logout Points
| Step | Action | Expected Result | Actual Result | Status |
|------|--------|----------------|---------------|--------|
| 1 | Logout from Dashboard sidebar | Redirect to Login Screen | ✅ Login Screen shown | ✅ PASS |
| 2 | Login again and logout from Profile | Redirect to Login Screen | ✅ Login Screen shown | ✅ PASS |
| 3 | Both logout methods clear session | No auto-login after restart | ✅ Session cleared | ✅ PASS |

### Test Case 5: Session Continuity
| Step | Action | Expected Result | Actual Result | Status |
|------|--------|----------------|---------------|--------|
| 1 | Login and navigate through app | Session persists across screens | ✅ Session maintained | ✅ PASS |
| 2 | Background app for extended time | Session remains active | ✅ Auto-resumed on return | ✅ PASS |
| 3 | Force restart device | Session persists after reboot | ✅ Auto-login after reboot | ✅ PASS |

---

## Screenshots

### 1. Login Screen (Not Authenticated)
**State**: User not logged in, viewing login screen

![Login Screen](screenshots/login_screen.png)

*Users see this screen when not authenticated or after logout*

---

### 2. Dashboard Screen (After Login)
**State**: User successfully logged in, viewing dashboard

![Dashboard After Login](screenshots/dashboard_before_restart.png)

*Main dashboard showing customer statistics and list*

---

### 3. Loading State (Auth Check)
**State**: App checking authentication status

![Loading Screen](screenshots/loading_auth_check.png)

*Brief loading screen while Firebase checks auth state*

---

### 4. Dashboard Screen (After Restart - Auto-Login)
**State**: User reopened app, automatically logged in

![Dashboard After Restart](screenshots/dashboard_after_restart.png)

*Same dashboard appears without requiring login - Auto-Login Success!*

---

### 5. Profile Screen (Logged In)
**State**: Viewing user profile with logout option

![Profile Screen](screenshots/profile_screen.png)

*User profile showing account details and logout button*

---

### 6. Logout Confirmation Dialog
**State**: User clicked logout, confirming action

![Logout Dialog](screenshots/logout_confirmation.png)

*Confirmation dialog to prevent accidental logout*

---

### 7. Login Screen (After Logout)
**State**: User logged out, session cleared

![Login After Logout](screenshots/login_after_logout.png)

*Login screen shown after logout - session properly cleared*

---

## Reflection

### Why Persistent Sessions Improve UX

1. **Reduced Friction**: Users don't need to repeatedly enter credentials
2. **Modern App Experience**: Matches behavior of popular apps (social media, banking)
3. **Time Saving**: Instant access to app features without authentication delay
4. **Professional Feel**: Shows attention to user experience and convenience
5. **Increased Engagement**: Lower barrier to entry encourages more frequent app use

### How Firebase Simplifies Session Management

#### Without Firebase (Manual Implementation)
```dart
// ❌ Manual approach requires:
- Storing tokens in SharedPreferences/SecureStorage
- Implementing token refresh logic
- Handling token expiration manually
- Writing encryption/decryption code
- Managing auth state manually across app
- Implementing token validation on every screen
```

#### With Firebase (Automatic)
```dart
// ✅ Firebase handles automatically:
- Secure token storage (encrypted)
- Automatic token refresh
- Cross-platform consistency
- Real-time auth state updates via streams
- Built-in security best practices
```

**Code Comparison**:

**Manual Approach** (50+ lines):
```dart
// Manual session management
class SessionManager {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiryKey = 'token_expiry';
  
  Future<void> saveToken(String token, String refreshToken, DateTime expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_expiryKey, expiry.toIso8601String());
  }
  
  Future<bool> isValidSession() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString(_expiryKey);
    if (expiryStr == null) return false;
    final expiry = DateTime.parse(expiryStr);
    if (DateTime.now().isAfter(expiry)) {
      await refreshToken(); // Must implement
    }
    return true;
  }
  
  // ... more manual code for refresh, validation, etc.
}
```

**Firebase Approach** (3 lines):
```dart
// Firebase automatic session management
StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) => snapshot.hasData ? Home() : Login(),
)
```

### Key Advantages of Firebase Auth

| Feature | Manual Implementation | Firebase Auth |
|---------|----------------------|---------------|
| Token Storage | Must implement with SharedPreferences/SecureStorage | ✅ Automatic & Encrypted |
| Token Refresh | Must implement refresh logic & API calls | ✅ Automatic background refresh |
| Cross-Platform | Different implementation per platform | ✅ Consistent across iOS/Android/Web |
| Security | Must implement encryption & best practices | ✅ Built-in security standards |
| Real-time Updates | Must implement polling or manual checks | ✅ Stream-based automatic updates |
| Development Time | Days to weeks | ✅ Minutes to hours |
| Maintenance | Ongoing code maintenance required | ✅ Maintained by Firebase team |
| Testing Complexity | Must test token expiry, refresh, storage | ✅ Already tested by Firebase |

### Limitations and Challenges Faced

#### 1. **Initial Route Handling**
**Challenge**: Coordinating between Splash Screen and AuthWrapper

**Solution**: 
- Splash Screen shows for 2 seconds (branding)
- Then navigates to AuthWrapper
- AuthWrapper handles all auth logic

#### 2. **Multiple Logout Points**
**Challenge**: Dashboard and Profile both have logout functionality

**Solution**:
- Both navigate to `/auth` route after `signOut()`
- AuthWrapper automatically shows LoginScreen
- Consistent behavior across logout points

#### 3. **Loading State Flickering**
**Challenge**: Brief loading state visible during auth check

**Solution**:
- Implemented branded loading screen with gradient
- Shows CircularProgressIndicator with app colors
- Smooth transition between states

#### 4. **Navigation Stack Management**
**Challenge**: Preventing back navigation to authenticated screens after logout

**Solution**:
```dart
Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
// Removes all previous routes from stack
```

#### 5. **Testing Across App Restarts**
**Challenge**: Verifying persistent sessions requires full app restart

**Solution**:
- Used Android Studio "Stop" button (not hot reload)
- Tested on both Android emulator and physical device
- Verified behavior across different network conditions

### Best Practices Implemented

1. **Separation of Concerns**: AuthWrapper handles only authentication logic
2. **Consistent Routing**: All auth-related navigation goes through AuthWrapper
3. **User Feedback**: Loading states and branded screens during transitions
4. **Error Handling**: Mounted checks before navigation in async functions
5. **Security**: No manual token storage - rely on Firebase security
6. **Code Maintainability**: Single source of truth for auth state

### Future Enhancements

1. **Biometric Authentication**: Add fingerprint/face ID for quick login
2. **Remember Me Option**: Optional immediate login bypass
3. **Session Timeout**: Auto-logout after extended inactivity
4. **Multi-Device Sessions**: Track and manage sessions across devices
5. **Offline Support**: Enhanced offline capabilities with Firebase persistence

---

## Conclusion

The implementation of persistent user sessions using Firebase Authentication significantly improves the GrowTown app's user experience. By leveraging Firebase's automatic session management with `authStateChanges()` streams, we achieved:

✅ **Automatic login** across app restarts  
✅ **Seamless logout** with proper session clearing  
✅ **Clean architecture** with centralized auth logic  
✅ **Minimal code** compared to manual implementation  
✅ **Professional UX** matching modern app standards  

Firebase Authentication's built-in session management eliminates the complexity of manual token storage, refresh logic, and security concerns while providing a robust, tested solution that works consistently across platforms.

---

## Implementation Checklist

- [x] Implemented AuthWrapper with StreamBuilder
- [x] Connected authStateChanges() stream to UI
- [x] Configured app routing with Splash → AuthWrapper → Login/Dashboard
- [x] Updated logout functionality in Dashboard and Profile
- [x] Tested auto-login after app restart
- [x] Tested logout persistence after app restart
- [x] Verified session state changes reflect immediately
- [x] Added branded loading screen for auth checks
- [x] Documented implementation with code examples
- [x] Created test cases and verified results
- [x] Captured screenshots of all states
- [x] Reflected on benefits, challenges, and solutions

---

## Additional Resources

- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Flutter StreamBuilder Documentation](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html)
- [Firebase Auth State Management](https://firebase.google.com/docs/auth/flutter/manage-users)

---

**Date**: February 9, 2026  
**Project**: GrowTown - Customer Management System  
**Framework**: Flutter with Firebase Authentication  
**Status**: ✅ Implementation Complete & Tested
