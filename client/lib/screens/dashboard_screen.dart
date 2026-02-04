import 'package:flutter/material.dart';
import 'package:client/widgets/customer_list.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      body: Row(
        children: [
          // ================= Sidebar =================
          Container(
            width: 240,
            color: const Color(0xFF2F3A8F),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ClientDash",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                _sideItem(context, Icons.dashboard, "Dashboard", true),
                _sideItem(context, Icons.people, "Customers", false),
                _sideItem(context, Icons.bar_chart, "Analytics", false),
                _sideItem(context, Icons.settings, "Settings", false),

                const Spacer(),

                _sideItem(context, Icons.logout, "Logout", false),
              ],
            ),
          ),

          // ================= Main Content =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== Top Bar =====
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              icon: Icon(Icons.search),
                              hintText: "Search customers...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.person),
                        onPressed: () {
                          Navigator.pushNamed(context, "/profile");
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ===== Dashboard Cards =====
                  Row(
                    children: [
                      _statCard("Total Customers", "150", Colors.blue),
                      _statCard("Active", "98", Colors.green),
                      _statCard("Inactive", "52", Colors.orange),
                      _statCard("Top Points", "200", Colors.purple),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ===== Customers Section =====
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const CustomerList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ================= Animated FAB =================
      floatingActionButton: StatefulBuilder(
        builder: (context, setState) {
          bool pressed = false;

          return GestureDetector(
            onTapDown: (_) {
              setState(() => pressed = true);
            },
            onTapUp: (_) {
              setState(() => pressed = false);
              Navigator.pushNamed(context, "/addCustomer");
            },
            onTapCancel: () {
              setState(() => pressed = false);
            },
            child: AnimatedScale(
              scale: pressed ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF2F3A8F),
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= Animated Sidebar Item =================
  Widget _sideItem(
    BuildContext context,
    IconData icon,
    String title,
    bool active,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active ? Colors.white24 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {},
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // ================= Animated Stat Card =================
  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color)),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
