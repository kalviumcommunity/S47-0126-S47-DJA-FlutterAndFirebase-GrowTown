import 'package:flutter/material.dart';

/// MAIN DEMO SCREEN
class StatelessStatefulDemo extends StatelessWidget {
  const StatelessStatefulDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stateless vs Stateful Demo'),
        centerTitle: true,
      ),
      body: const Center(
        child: DemoBody(),
      ),
    );
  }
}

/// STATEFUL WIDGET (INTERACTIVE PART)
class DemoBody extends StatefulWidget {
  const DemoBody({super.key});

  @override
  State<DemoBody> createState() => _DemoBodyState();
}

class _DemoBodyState extends State<DemoBody> {
  int counter = 0;

  void incrementCounter() {
    setState(() {
      counter++;
      debugPrint('Counter updated to $counter');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // STATELESS TEXT (STATIC)
        const Text(
          'Interactive Counter App',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        // STATEFUL TEXT (DYNAMIC)
        Text(
          'Counter Value: $counter',
          style: const TextStyle(fontSize: 18),
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink, 
          foregroundColor: Colors.white,   
          ),
          onPressed: incrementCounter,
          child: const Text('Increase Counter'),
        ),
      ],
    );
  }
}
