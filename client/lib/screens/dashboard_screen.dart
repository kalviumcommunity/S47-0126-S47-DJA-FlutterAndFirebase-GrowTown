import 'package:flutter/material.dart';
import 'package:client/widgets/customer_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    final isTablet = screenWidth >= 800 && screenWidth < 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: isMobile
          ? AppBar(
              title: const Text("ClientDash"),
              backgroundColor: const Color(0xFF2F3A8F),
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.pushNamed(context, "/profile");
                  },
                ),
              ],
            )
          : null,
      drawer: isMobile ? _buildDrawer(context) : null,
      body: Row(
        children: [
          // ================= Sidebar (Desktop only) =================
          if (!isMobile)
            Container(
              width: isTablet ? 200 : 240,
              color: const Color(0xFF2F3A8F),
              padding: EdgeInsets.all(isTablet ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ClientDash",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 20 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  _sideItem(
                    context,
                    Icons.dashboard,
                    "Dashboard",
                    true,
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                  ),
                  _sideItem(
                    context,
                    Icons.people,
                    "Customers",
                    false,
                    onTap: () {
                      Navigator.pushNamed(context, '/customers');
                    },
                  ),
                  _sideItem(
                    context,
                    Icons.bar_chart,
                    "Analytics",
                    false,
                    onTap: () {
                      Navigator.pushNamed(context, '/analytics');
                    },
                  ),
                  _sideItem(context, Icons.settings, "Settings", false),

                  const Spacer(),

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
                ],
              ),
            ),

          // ================= Main Content =================
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 20 : 24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== Top Bar (Desktop only) =====
                    if (!isMobile)
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

                    if (!isMobile) const SizedBox(height: 24),

                    // ===== Dashboard Cards (live from Firestore) =====
                    _buildStats(isMobile),

                    const SizedBox(height: 24),

                    // ===== Customers Section =====
                    Container(
                      height: isMobile ? 400 : (isTablet ? 450 : 500),
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const CustomerList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ================= FAB =================
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2F3A8F),
        onPressed: () {
          Navigator.pushNamed(context, "/addCustomer");
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ================= Mobile Drawer =================
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF2F3A8F),
      child: SafeArea(
        child: Padding(
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

              _sideItem(
                context,
                Icons.dashboard,
                "Dashboard",
                true,
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
              ),
              _sideItem(
                context,
                Icons.people,
                "Customers",
                false,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/customers');
                },
              ),
              _sideItem(
                context,
                Icons.bar_chart,
                "Analytics",
                false,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/analytics');
                },
              ),
              _sideItem(context, Icons.settings, "Settings", false),

              const Spacer(),

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
            ],
          ),
        ),
      ),
    );
  }

  // ================= Stats from Firestore =================
  Widget _buildStats(bool isMobile) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('customers').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Text(
            'Failed to load stats',
            style: TextStyle(color: Colors.red),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        int total = docs.length;
        int active = 0;
        int topPoints = 0;

        for (final doc in docs) {
          final data = doc.data();
          final status = (data['status'] as String?) ?? 'inactive';
          if (status == 'active') active++;

          final points =
              (data['points'] is num) ? (data['points'] as num).toInt() : 0;
          if (points > topPoints) topPoints = points;
        }

        final inactive = total - active;

        if (isMobile) {
          return _buildMobileStatsGrid(
            total: total,
            active: active,
            inactive: inactive,
            topPoints: topPoints,
          );
        }

        return Row(
          children: [
            _statCard("Total Customers", "$total", Colors.blue, isMobile),
            _statCard("Active", "$active", Colors.green, isMobile),
            _statCard("Inactive", "$inactive", Colors.orange, isMobile),
            _statCard("Top Points", "$topPoints", Colors.purple, isMobile),
          ],
        );
      },
    );
  }

  // ================= Mobile Stats Grid =================
  Widget _buildMobileStatsGrid({
    required int total,
    required int active,
    required int inactive,
    required int topPoints,
  }) {
    return Column(
      children: [
        Row(
          children: [
            _statCard("Total Customers", "$total", Colors.blue, true),
            const SizedBox(width: 8),
            _statCard("Active", "$active", Colors.green, true),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _statCard("Inactive", "$inactive", Colors.orange, true),
            const SizedBox(width: 8),
            _statCard("Top Points", "$topPoints", Colors.purple, true),
          ],
        ),
      ],
    );
  }

  // ================= Animated Sidebar Item =================
  Widget _sideItem(
    BuildContext context,
    IconData icon,
    String title,
    bool active, {
    VoidCallback? onTap,
  }) {
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
        onTap: onTap ?? () {},
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
  Widget _statCard(String title, String value, Color color, bool isMobile) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: isMobile ? 0 : 16),
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
            SizedBox(height: isMobile ? 6 : 10),
            Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 20 : 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
