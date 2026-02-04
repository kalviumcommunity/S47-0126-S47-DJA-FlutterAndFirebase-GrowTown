import 'package:flutter/material.dart';

class RotationDemoScreen extends StatefulWidget {
  const RotationDemoScreen({super.key});

  @override
  State<RotationDemoScreen> createState() => _RotationDemoScreenState();
}

class _RotationDemoScreenState extends State<RotationDemoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explicit Animation')),
      body: Center(
        child: RotationTransition(
          turns: controller,
          child: const Icon(Icons.flutter_dash, size: 100),
        ),
      ),
    );
  }
}
