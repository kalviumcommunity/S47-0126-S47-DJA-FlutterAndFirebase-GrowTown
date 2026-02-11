import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: const Color(0xFF2F3A8F),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF4F6FA),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: const Text(
            'Analytics - Coming soon',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F3A8F),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

