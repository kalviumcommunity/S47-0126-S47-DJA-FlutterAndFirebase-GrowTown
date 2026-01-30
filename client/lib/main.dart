import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_customer_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/responsive_layout.dart';
import 'screens/scrollable_views.dart'; // ✅ NEW IMPORT

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/addCustomer': (context) => const AddCustomerScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/responsive': (context) => const ResponsiveLayout(),
        '/scrollable': (context) => const ScrollableViews(), // ✅ NEW ROUTE
      },
    );
  }
}
