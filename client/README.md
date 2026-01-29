# GrowTown – Multi-Screen Navigation in Flutter

## Project Description
GrowTown is a simple customer loyalty mobile application designed for small businesses in Tier-2 and Tier-3 towns. This task focuses on implementing multi-screen navigation in Flutter using the Navigator widget and named routes. The app demonstrates smooth screen transitions and a scalable navigation structure that will later support Firebase authentication and Firestore integration.

---

## Navigation Flow Overview
The app uses Flutter’s stack-based navigation model. Screens are navigated using named routes configured in `main.dart`.

### Screens Implemented
- Splash Screen
- Login Screen
- Dashboard Screen
- Add Customer Screen
- Profile Screen

### Navigation Flow
Splash → Login → Dashboard  
Dashboard → Add Customer → Back  
Dashboard → Profile → Logout → Login

---

## Route Configuration (`main.dart`)

```dart
MaterialApp(
  debugShowCheckedModeBanner: false,
  initialRoute: '/splash',
  routes: {
    '/splash': (context) => const SplashScreen(),
    '/login': (context) => const LoginScreen(),
    '/dashboard': (context) => const DashboardScreen(),
    '/addCustomer': (context) => const AddCustomerScreen(),
    '/profile': (context) => const ProfileScreen(),
  },
);
