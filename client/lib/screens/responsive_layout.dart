import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Layout Demo'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 📱 Mobile layout
          if (constraints.maxWidth < 600) {
            return Center(
              child: Container(
                width: screenWidth * 0.85,
                height: screenHeight * 0.25,
                color: Colors.tealAccent,
                child: const Center(
                  child: Text(
                    'Mobile View',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }

          // 💻 Tablet layout
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: screenWidth * 0.3,
                height: screenHeight * 0.3,
                color: Colors.orangeAccent,
                child: const Center(
                  child: Text(
                    'Tablet Left Panel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                width: screenWidth * 0.3,
                height: screenHeight * 0.3,
                color: Colors.tealAccent,
                child: const Center(
                  child: Text(
                    'Tablet Right Panel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

