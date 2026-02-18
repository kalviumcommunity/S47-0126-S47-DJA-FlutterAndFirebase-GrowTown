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
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('alerts')
                      .where('shopkeeperId',
                          isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                      .where('resolved', isEqualTo: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.size ?? 0;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none),
                          onPressed: () {
                            Navigator.pushNamed(context, '/alerts');
                          },
                        ),
                        if (count > 0)
                          Positioned(
                            right: 10,
                            top: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                count > 99 ? '99+' : '$count',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
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

                  _sideItem(context, Icons.dashboard, "Dashboard", true,
                      onTap: () {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  }),
                  _sideItem(context, Icons.people, "Customers", false,
                      onTap: () {
                    Navigator.pushNamed(context, '/customers');
                  }),
                  _sideItem(context, Icons.bar_chart, "Analytics", false,
                      onTap: () {
                    Navigator.pushNamed(context, '/analytics');
                  }),
                  _sideItem(context, Icons.location_on, "Shops Map", false,
                      onTap: () {
                    Navigator.pushNamed(context, '/shopsMap');
                  }),

                  // ✅ Profile Form
                  _sideItem(context, Icons.assignment, "Profile Form", false,
                      onTap: () {
                    Navigator.pushNamed(context, '/profileDetailsForm');
                  }),

                  // ✅ My Notes
                  _sideItem(context, Icons.note_alt_outlined, "My Notes", false,
                      onTap: () {
                    Navigator.pushNamed(context, '/myNotes');
                  }),

                  const Spacer(),

                  _sideItem(context, Icons.logout, "Logout", false,
                      onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/auth');
                    }
                  }),
                ],
              ),
            ),

          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.all(isMobile ? 16 : (isTablet ? 20 : 24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

                    _buildStats(isMobile),

                    const SizedBox(height: 24),

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

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2F3A8F),
        onPressed: () {
          Navigator.pushNamed(context, "/addCustomer");
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Drawer updated the same way (both items included)
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF2F3A8F),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("ClientDash",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              _sideItem(context, Icons.dashboard, "Dashboard", true,
                  onTap: () {
                Navigator.pushReplacementNamed(context, '/dashboard');
              }),
              _sideItem(context, Icons.people, "Customers", false,
                  onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/customers');
              }),
              _sideItem(context, Icons.bar_chart, "Analytics", false,
                  onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/analytics');
              }),
              _sideItem(context, Icons.location_on, "Shops Map", false,
                  onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/shopsMap');
              }),

              // ✅ Profile Form
              _sideItem(context, Icons.assignment, "Profile Form", false,
                  onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profileDetailsForm');
              }),

              // ✅ My Notes
              _sideItem(context, Icons.note_alt_outlined, "My Notes", false,
                  onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/myNotes');
              }),

              const Spacer(),

              _sideItem(context, Icons.logout, "Logout", false,
                  onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/auth');
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
