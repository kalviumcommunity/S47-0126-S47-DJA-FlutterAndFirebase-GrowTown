import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;
    final isTablet = size.width > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/bg-splash.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'GrowTown',
                style: TextStyle(
                  fontSize: isTablet ? 48 : (isSmall ? 32 : 40),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmall ? 8 : 12),
              Text(
                'Customer Management System',
                style: TextStyle(
                  fontSize: isTablet ? 20 : (isSmall ? 14 : 16),
                  color: Colors.white70,
                  shadows: [
                    Shadow(
                      blurRadius: 8.0,
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmall ? 20 : 30),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
