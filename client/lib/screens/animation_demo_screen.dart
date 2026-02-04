import 'package:flutter/material.dart';

class AnimationDemoScreen extends StatefulWidget {
  const AnimationDemoScreen({super.key});

  @override
  State<AnimationDemoScreen> createState() => _AnimationDemoScreenState();
}

class _AnimationDemoScreenState extends State<AnimationDemoScreen> {
  bool toggled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Implicit Animation')),
      body: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          width: toggled ? 200 : 120,
          height: toggled ? 120 : 200,
          color: toggled ? Colors.teal : Colors.orange,
          alignment: Alignment.center,
          child: const Text(
            'Tap Button',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            toggled = !toggled;
          });
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
