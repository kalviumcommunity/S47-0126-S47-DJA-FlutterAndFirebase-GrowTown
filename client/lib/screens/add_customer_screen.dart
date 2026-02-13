import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pointsController = TextEditingController();
  String _status = 'active';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final points = int.tryParse(_pointsController.text.trim()) ?? 0;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to save customer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('customers').add({
        'name': name,
        'phone': phone,
        'points': points,
        'status': _status,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': uid,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save customer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;
    final isTablet = size.width > 600;
    final isMobile = size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Add Customer'),
        backgroundColor: const Color(0xFF2F3A8F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 600 : double.infinity,
              ),
              child: Container(
                padding: EdgeInsets.all(isMobile ? 20 : 32),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Information',
                        style: TextStyle(
                          fontSize: isSmall ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2F3A8F),
                        ),
                      ),
                      SizedBox(height: isMobile ? 20 : 24),

                      // Customer Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Customer Name',
                          hintText: 'Enter customer name',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter customer name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: isMobile ? 16 : 20),

                      // Phone Number
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'Enter 10-digit phone number',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                        ),
                        validator: (value) {
                          final raw = (value ?? '').trim();
                          if (raw.isEmpty) {
                            return 'Please enter phone number';
                          }
                          if (raw.length != 10) {
                            return 'Phone number must be exactly 10 digits';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: isMobile ? 16 : 20),

                      // Points (0 - 1000)
                      TextFormField(
                        controller: _pointsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Points',
                          hintText: 'Enter starting points',
                          prefixIcon: const Icon(Icons.stars_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                        ),
                        validator: (value) {
                          final raw = (value ?? '').trim();
                          if (raw.isEmpty) return 'Please enter points';
                          final parsed = int.tryParse(raw);
                          if (parsed == null) return 'Points must be a number';
                          if (parsed < 0) return 'Points cannot be negative';
                          if (parsed > 1000)
                            return 'Points cannot be more than 1000';
                          return null;
                        },
                      ),
                      SizedBox(height: isMobile ? 16 : 20),

                      // Status
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          prefixIcon: const Icon(Icons.verified_user_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'active', child: Text('active')),
                          DropdownMenuItem(
                              value: 'inactive', child: Text('inactive')),
                        ],
                        onChanged: (v) =>
                            setState(() => _status = v ?? 'active'),
                      ),
                      SizedBox(height: isMobile ? 24 : 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: isSmall ? 48 : 54,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveCustomer,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            _isSaving ? 'Saving...' : 'Save Customer',
                            style: TextStyle(
                              fontSize: isSmall ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F3A8F),
                            foregroundColor: Colors.white,
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
        ),
      ),
    );
  }
}
