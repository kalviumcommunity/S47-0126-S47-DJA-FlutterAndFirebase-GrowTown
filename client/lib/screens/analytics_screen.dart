import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Daily';
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87),
          onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
        ),
        title: const Text(
          "Leaderboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.search, color: Colors.black87),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customers')
            .where('createdBy', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Data Found"));
          }

          List<UserData> users = _processUsers(snapshot.data!.docs);
          final top3 = users.take(3).toList();
          final rest = users.length > 3 ? users.sublist(3) : [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTabs(),
                const SizedBox(height: 24),

                // 🔥 Top 3 with Crown
                if (top3.isNotEmpty) _buildTopThree(top3),

                const SizedBox(height: 28),
                _buildHeader(),
                const SizedBox(height: 12),

                // Leaderboard List
                ...rest.asMap().entries.map((entry) {
                  final rank = entry.key + 4;
                  final user = entry.value;
                  return _buildRankCard(user, rank);
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= CAPSULE TABS =================
  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _tabItem("Daily"),
          _tabItem("Monthly"),
          _tabItem("All time"),
        ],
      ),
    );
  }

  Widget _tabItem(String title) {
    final isSelected = _selectedPeriod == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6C4DFF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ================= TOP 3 SECTION =================
  Widget _buildTopThree(List<UserData> top3) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (top3.length > 1)
          _topUser(top3[1], 2, false),
        _topUser(top3[0], 1, true), // 👑 Crown for #1
        if (top3.length > 2)
          _topUser(top3[2], 3, false),
      ],
    );
  }

  Widget _topUser(UserData user, int rank, bool isWinner) {
    return Column(
      children: [
        // 👑 Crown instead of medal
        if (isWinner)
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 36,
            ),
          ),

        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF6C4DFF), Color(0xFF9B8CFF)],
                ),
              ),
              child: CircleAvatar(
                radius: isWinner ? 42 : 34,
                backgroundImage: user.avatarUrl != null &&
                        user.avatarUrl!.isNotEmpty
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                backgroundColor: Colors.grey.shade200,
                child: user.avatarUrl == null ||
                        user.avatarUrl!.isEmpty
                    ? Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: -6,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF6C4DFF),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "$rank",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          user.name,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_fire_department,
                color: Colors.orange, size: 14),
            const SizedBox(width: 4),
            Text(
              "${user.points} points",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: const [
          SizedBox(
            width: 40,
            child: Text("Rank",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(
            child: Text("Player",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Text("Points",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }

  // ================= RANK CARD =================
  Widget _buildRankCard(UserData user, int rank) {
    final isYou = user.id == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C4DFF), Color(0xFF9B8CFF)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              "$rank",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundImage: user.avatarUrl != null &&
                    user.avatarUrl!.isNotEmpty
                ? NetworkImage(user.avatarUrl!)
                : null,
            backgroundColor: Colors.white,
            child: user.avatarUrl == null ||
                    user.avatarUrl!.isEmpty
                ? Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                        color: Color(0xFF6C4DFF),
                        fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isYou ? "${user.name} (You)" : user.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15),
            ),
          ),
          Text(
            "${user.points} points",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ================= DATA =================
  List<UserData> _processUsers(List<QueryDocumentSnapshot> docs) {
    List<UserData> users = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return UserData(
        id: doc.id,
        name: data['name'] ?? 'Unknown',
        points: (data['points'] ?? 0).toInt(),
        avatarUrl: data['avatarUrl'],
      );
    }).toList();

    users.sort((a, b) => b.points.compareTo(a.points));
    return users;
  }
}

class UserData {
  final String id;
  final String name;
  final int points;
  final String? avatarUrl;

  UserData({
    required this.id,
    required this.name,
    required this.points,
    this.avatarUrl,
  });
}
