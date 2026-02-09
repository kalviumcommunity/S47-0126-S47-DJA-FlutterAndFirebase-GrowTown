import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
<<<<<<< Updated upstream
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/responsive');
            },
            icon: const Icon(Icons.grid_view),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Customer List Will Appear Here',
          style: TextStyle(fontSize: 16),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addCustomer');
        },
        child: const Icon(Icons.add),
=======
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

                  _sideItem(
                    context,
                    Icons.logout,
                    "Logout",
                    false,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
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
                padding: EdgeInsets.all(isMobile ? 16 : 24),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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

                    // ===== Dashboard Cards =====
                    isMobile
                        ? _buildMobileStatsGrid()
                        : Row(
                            children: [
                              _statCard("Total Customers", "150", Colors.blue,
                                  isMobile),
                              _statCard(
                                  "Active", "98", Colors.green, isMobile),
                              _statCard(
                                  "Inactive", "52", Colors.orange, isMobile),
                              _statCard("Top Points", "200", Colors.purple,
                                  isMobile),
                            ],
                          ),

                    const SizedBox(height: 24),

                    // ===== Customers Section =====
                    Container(
                      height: isMobile ? 400 : 500,
                      padding: const EdgeInsets.all(16),
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

      // ================= Animated FAB =================
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

              _sideItem(context, Icons.dashboard, "Dashboard", true),
              _sideItem(context, Icons.people, "Customers", false),
              _sideItem(context, Icons.bar_chart, "Analytics", false),
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
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= Mobile Stats Grid =================
  Widget _buildMobileStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            _statCard("Total Customers", "150", Colors.blue, true),
            const SizedBox(width: 8),
            _statCard("Active", "98", Colors.green, true),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _statCard("Inactive", "52", Colors.orange, true),
            const SizedBox(width: 8),
            _statCard("Top Points", "200", Colors.purple, true),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
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
>>>>>>> Stashed changes
      ),
    );
  }
}
