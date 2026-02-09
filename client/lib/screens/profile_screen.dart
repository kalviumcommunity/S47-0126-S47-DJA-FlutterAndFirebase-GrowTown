// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _editFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Future<void> _showEditDialog() async {
    _nameController.text = currentUser?.displayName ?? '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: _editFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'Enter your name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 12),
              const Text(
                'Note: Email cannot be changed',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_editFormKey.currentState!.validate()) {
                Navigator.of(context).pop();
                await _updateProfile(_nameController.text.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile(String newName) async {
    setState(() => _isLoading = true);

    try {
      await currentUser?.updateDisplayName(newName);
      await currentUser?.reload();
      
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;
    final isTablet = size.width > 600;
    final isMobile = size.width < 800;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(
          child: Text('No user logged in'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE6F4F1),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF1F8F88),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 800 : double.infinity,
                    ),
                    child: Column(
                      children: [
                        // Profile Header Card
                        Container(
                          padding: EdgeInsets.all(isMobile ? 20 : 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Avatar
                              Container(
                                width: isSmall ? 80 : (isMobile ? 90 : 100),
                                height: isSmall ? 80 : (isMobile ? 90 : 100),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF1F8F88), Color(0xFF2FB8AA)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1F8F88).withValues(alpha: 0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _getInitials(
                                      currentUser!.displayName ?? 
                                      currentUser!.email ?? 'User'
                                    ),
                                    style: TextStyle(
                                      fontSize: isSmall ? 30 : (isMobile ? 32 : 36),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: isMobile ? 16 : 20),

                              // Name
                              Text(
                                currentUser!.displayName ?? 'User',
                                style: TextStyle(
                                  fontSize: isSmall ? 20 : (isMobile ? 22 : 24),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1F8F88),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),

                              // Email
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: isSmall ? 14 : 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      currentUser!.email ?? 'No email',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: isSmall ? 13 : 14,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: isMobile ? 16 : 20),

                              // Edit Profile Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _showEditDialog,
                                  icon: Icon(Icons.edit, size: isSmall ? 18 : 20),
                                  label: Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      fontSize: isSmall ? 14 : 16,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1F8F88),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      vertical: isSmall ? 12 : 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isMobile ? 16 : 20),

                        // Account Information Card
                        Container(
                          padding: EdgeInsets.all(isMobile ? 16 : 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Account Information',
                                style: TextStyle(
                                  fontSize: isSmall ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1F8F88),
                                ),
                              ),
                              SizedBox(height: isMobile ? 12 : 16),

                              _infoRow(
                                icon: Icons.fingerprint,
                                label: 'User ID',
                                value: '${currentUser!.uid.substring(0, isSmall ? 15 : 20)}...',
                                isSmall: isSmall,
                              ),

                              const Divider(height: 24),

                              _infoRow(
                                icon: Icons.calendar_today,
                                label: 'Account Created',
                                value: _formatDate(currentUser!.metadata.creationTime),
                                isSmall: isSmall,
                              ),

                              const Divider(height: 24),

                              _infoRow(
                                icon: Icons.access_time,
                                label: 'Last Sign In',
                                value: _formatDate(currentUser!.metadata.lastSignInTime),
                                isSmall: isSmall,
                              ),

                              const Divider(height: 24),

                              _infoRow(
                                icon: currentUser!.emailVerified
                                    ? Icons.verified_user
                                    : Icons.warning_amber_rounded,
                                label: 'Email Verification',
                                value: currentUser!.emailVerified
                                    ? 'Verified'
                                    : 'Not Verified',
                                valueColor: currentUser!.emailVerified
                                    ? Colors.green
                                    : Colors.orange,
                                isSmall: isSmall,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isMobile ? 16 : 20),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _confirmLogout,
                            icon: Icon(Icons.logout, size: isSmall ? 18 : 20),
                            label: Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: isSmall ? 14 : 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: isSmall ? 12 : 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  String _getInitials(String name) {
    List<String> names = name.trim().split(' ');
    if (names.isEmpty) return 'U';
    if (names.length == 1) return names[0][0].toUpperCase();
    return (names[0][0] + names[names.length - 1][0]).toUpperCase();
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    required bool isSmall,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isSmall ? 6 : 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1F8F88).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: isSmall ? 18 : 20,
            color: const Color(0xFF1F8F88),
          ),
        ),
        SizedBox(width: isSmall ? 10 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isSmall ? 11 : 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isSmall ? 13 : 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
