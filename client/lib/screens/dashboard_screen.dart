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
              title: const Text(
                "ClientDash",
                style: TextStyle(
                    color: Color(0xFF2F3A8F),
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
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
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.notifications_none_rounded,
                                color: Colors.black87),
                            onPressed: () {
                              Navigator.pushNamed(context, '/alerts');
                            },
                          ),
                        ),
                        if (count > 0)
                          Positioned(
                            right: 12,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                count > 99 ? '99+' : '$count',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.person_outline_rounded,
                          color: Colors.black87),
                      onPressed: () {
                        Navigator.pushNamed(context, "/profile");
                      },
                    ),
                  ),
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
                    if (!isMobile) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const TextField(
                                decoration: InputDecoration(
                                  icon: Icon(Icons.search, color: Colors.grey),
                                  hintText: "Search customers globally...",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Overview",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2F3A8F),
                              ),
                            ),
                            Text(
                              "Here is your daily summary",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

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
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'User';
    final name = user?.displayName ?? 'Welcome';
    final avatarColor = const Color(0xFF2F3A8F);

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drawer Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF2F3A8F), const Color(0xFF5C6BC0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(
                    email.isNotEmpty ? email[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: avatarColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Drawer Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _drawerItem(context, Icons.dashboard_rounded, "Dashboard", true,
                    onTap: () {
                  Navigator.pop(context); // Close drawer
                  // Already on dashboard, no-op or refresh
                }),
                _drawerItem(context, Icons.people_alt_rounded, "Customers", false,
                    onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/customers');
                }),
                _drawerItem(context, Icons.bar_chart_rounded, "Analytics", false,
                    onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/analytics');
                }),
                _drawerItem(context, Icons.map_rounded, "Shops Map", false,
                    onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/shopsMap');
                }),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Divider(height: 1),
                ),

                _drawerItem(context, Icons.person_rounded, "My Profile", false,
                    onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profileDetailsForm');
                }),
                _drawerItem(context, Icons.note_alt_rounded, "My Notes", false,
                    onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/myNotes');
                }),
              ],
            ),
          ),

          // Logout Footer
          Padding(
            padding: const EdgeInsets.all(24),
            child: _drawerItem(
              context,
              Icons.logout_rounded,
              "Logout",
              false,
              isLogout: true,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/auth');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String label,
      bool selected, {VoidCallback? onTap, bool isLogout = false}) {
    final color = isLogout ? Colors.red.shade400 : const Color(0xFF2F3A8F);
    final bgColor = selected ? const Color(0xFFEEF2FF) : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: selected ? const Color(0xFF2F3A8F) : (isLogout ? color : Colors.grey.shade600), size: 22),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF2F3A8F) : (isLogout ? color : Colors.grey.shade800),
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        hoverColor: const Color(0xFFF4F6FA),
      ),
    );
  }

  Widget _sideItem(BuildContext context, IconData icon, String label,
      bool selected, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: selected ? Colors.white : Colors.white70),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white70,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedTileColor: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: onTap,
    );
  }

  Widget _buildStats(bool isMobile) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('customers')
          .where('createdBy', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final totalCount = docs.length;

        // Count customers with status == 'active'
        final activeCount = docs.where((doc) {
          final data = doc.data();
          return (data['status'] as String?) == 'active';
        }).length;

        // Count customers created this month
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final newThisMonth = docs.where((doc) {
          final data = doc.data();
          final createdAt = data['createdAt'];
          if (createdAt == null) return false;
          final date = (createdAt as Timestamp).toDate();
          return date.isAfter(startOfMonth) ||
              date.isAtSameMomentAs(startOfMonth);
        }).length;

        return LayoutBuilder(
          builder: (context, constraints) {
            // Calculate width for 2 columns on mobile, or fixed on desktop
            final double cardWidth = isMobile
                ? (constraints.maxWidth - 16) / 2
                : 220;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _statCard(
                  "Total Customers",
                  "$totalCount",
                  Icons.people_alt_outlined,
                  [const Color(0xFF2F3A8F), const Color(0xFF5C6BC0)],
                  cardWidth,
                ),
                _statCard(
                  "Active",
                  "$activeCount",
                  Icons.check_circle_outline,
                  [const Color(0xFF00B894), const Color(0xFF55EFC4)],
                  cardWidth,
                ),
                _statCard(
                  "New This Month",
                  "$newThisMonth",
                  Icons.trending_up,
                  [const Color(0xFFFDCB6E), const Color(0xFFFFEAA7)],
                  cardWidth,
                  isDarkText: true,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _statCard(String title, String value, IconData icon,
      List<Color> colors, double width,
      {bool isDarkText = false}) {
    final textColor = isDarkText ? const Color(0xFF2D3436) : Colors.white;
    final iconColor =
        isDarkText ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.2);

    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: textColor, size: 20),
              ),
              if (isDarkText)
                Icon(Icons.arrow_forward_ios,
                    color: Colors.black.withOpacity(0.1), size: 14)
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
