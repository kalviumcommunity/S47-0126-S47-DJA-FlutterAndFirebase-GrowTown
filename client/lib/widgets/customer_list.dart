import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:client/models/customer.dart';

class CustomerList extends StatefulWidget {
  /// Optional: still allows injecting a static list for testing,
  /// but normally data comes from Firestore.
  final List<Customer>? initialCustomers;
  const CustomerList({super.key, this.initialCustomers});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  String _searchQuery = '';
  String _filter = 'All';
  bool _isGrid = false;
  final int _highValueThreshold = 500;
  final int _highValueLimit = 10;

  List<Customer> _applyFilters(List<Customer> allCustomers) {
    final q = _searchQuery.toLowerCase();
    return allCustomers.where((c) {
      final matchesQuery =
          c.name.toLowerCase().contains(q) || c.phone.contains(q);
      if (!matchesQuery) return false;
      if (_filter == 'All') return true;
      if (_filter == 'Points > 50') return c.points > 50;
      if (_filter == 'Points > 100') return c.points > 100;
      if (_filter == 'Active') return c.status == 'active';
      if (_filter == 'Inactive') return c.status == 'inactive';
      return true;
    }).toList();
  }

  int _totalCustomers(List<Customer> allCustomers) => allCustomers.length;

  double _averagePoints(List<Customer> allCustomers) {
    if (allCustomers.isEmpty) return 0;
    final total =
        allCustomers.map((c) => c.points).fold<int>(0, (a, b) => a + b);
    return total / allCustomers.length;
  }

  Customer? _topCustomer(List<Customer> allCustomers) {
    if (allCustomers.isEmpty) return null;
    final sorted = [...allCustomers]
      ..sort((a, b) => b.points.compareTo(a.points));
    return sorted.first;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1100;
    final int gridColumns = isMobile ? 1 : (isTablet ? 2 : 3);

    // Choose base Firestore query: either all customers or "high value"
    final uid = FirebaseAuth.instance.currentUser?.uid;
    Query<Map<String, dynamic>> baseQuery =
        FirebaseFirestore.instance.collection('customers');
    if (uid != null && uid.isNotEmpty) {
      baseQuery = baseQuery.where('createdBy', isEqualTo: uid);
    }

    if (_filter == 'High value') {
      baseQuery = baseQuery
          .where('points', isGreaterThanOrEqualTo: _highValueThreshold)
          .orderBy('points', descending: true)
          .limit(_highValueLimit);
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: baseQuery.snapshots(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load customers\n${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        // Map Firestore docs -> Customer models
        final docs = snapshot.data?.docs ?? [];
        List<Customer> allCustomers;

        if (docs.isEmpty && widget.initialCustomers != null) {
          // Fallback: use injected sample list if Firestore is empty
          allCustomers = widget.initialCustomers!;
        } else {
          allCustomers = docs.map(Customer.fromDoc).toList();
        }

        final filtered = _applyFilters(allCustomers);
        final total = _totalCustomers(allCustomers);
        final avgPoints = _averagePoints(allCustomers);
        final top = _topCustomer(allCustomers);

        return Column(
          children: [
            // 🔍 Search + Filter + View Toggle
            if (isMobile) ...[
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 20),
                  hintText: "Search by name or phone",
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: const Color(0xFFF4F6FA),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filter,
                          isExpanded: true,
                          icon: const Icon(Icons.filter_list, size: 20),
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All')),
                            DropdownMenuItem(value: 'Points > 50', child: Text('Points > 50')),
                            DropdownMenuItem(value: 'Points > 100', child: Text('Points > 100')),
                            DropdownMenuItem(value: 'Active', child: Text('Active')),
                            DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                            DropdownMenuItem(value: 'High value', child: Text('High value (top)')),
                          ],
                          onChanged: (v) => setState(() => _filter = v!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: !_isGrid ? const Color(0xFF2F3A8F) : const Color(0xFFF4F6FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.view_list, size: 20,
                          color: !_isGrid ? Colors.white : Colors.grey),
                      onPressed: () => setState(() => _isGrid = false),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: _isGrid ? const Color(0xFF2F3A8F) : const Color(0xFFF4F6FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.grid_view, size: 20,
                          color: _isGrid ? Colors.white : Colors.grey),
                      onPressed: () => setState(() => _isGrid = true),
                    ),
                  ),
                ],
              ),
            ] else ...[              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: "Search by name or phone",
                        filled: true,
                        fillColor: const Color(0xFFF4F6FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _filter,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'Points > 50', child: Text('Points > 50')),
                      DropdownMenuItem(value: 'Points > 100', child: Text('Points > 100')),
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                      DropdownMenuItem(value: 'High value', child: Text('High value (top)')),
                    ],
                    onChanged: (v) => setState(() => _filter = v!),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Icon(Icons.view_list,
                        color: !_isGrid ? Colors.blue : Colors.grey),
                    onPressed: () => setState(() => _isGrid = false),
                  ),
                  IconButton(
                    icon: Icon(Icons.grid_view,
                        color: _isGrid ? Colors.blue : Colors.grey),
                    onPressed: () => setState(() => _isGrid = true),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // 📊 Stats
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text("Total: $total"),
                  const Spacer(),
                  Text("Avg: ${avgPoints.toStringAsFixed(1)}"),
                  const Spacer(),
                  if (top != null) Text("Top: ${top.name}"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🧾 Table header (only for list view)
            if (!_isGrid)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: const Color(0xFFF4F6FA),
                child: const Row(
                  children: [
                    Expanded(child: Text("Name")),
                    Expanded(child: Text("Phone")),
                    Expanded(child: Text("Points")),
                    Expanded(child: Text("Status")),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // 🧩 Grid or List
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text("No customers found"))
                  : _isGrid
                      ? GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridColumns,
                            crossAxisSpacing: isMobile ? 12 : 16,
                            mainAxisSpacing: isMobile ? 12 : 16,
                            childAspectRatio: isMobile ? 1.15 : 1.3,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return _gridCustomerCard(filtered[index]);
                          },
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final c = filtered[index];
                            final canEdit = c.id.isNotEmpty;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(child: Text(c.name, overflow: TextOverflow.ellipsis)),
                                  Expanded(child: Text(c.phone, overflow: TextOverflow.ellipsis)),
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: IconButton(
                                              icon: const Icon(Icons.remove, size: 16),
                                              padding: EdgeInsets.zero,
                                              tooltip: 'Decrease points',
                                              onPressed: canEdit && c.points > 0
                                                  ? () => _updatePoints(c, -1)
                                                  : null,
                                            ),
                                          ),
                                          Text('${c.points}'),
                                          SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: IconButton(
                                              icon: const Icon(Icons.add, size: 16),
                                              padding: EdgeInsets.zero,
                                              tooltip: 'Increase points',
                                              onPressed: canEdit && c.points < 1000
                                                  ? () => _updatePoints(c, 1)
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Chip(
                                            label: Text(c.status, style: const TextStyle(fontSize: 12)),
                                            backgroundColor: c.status == 'active'
                                                ? Colors.green[100]
                                                : Colors.grey[300],
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            padding: EdgeInsets.zero,
                                          ),
                                          SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: IconButton(
                                              icon: const Icon(Icons.edit, size: 16),
                                              padding: EdgeInsets.zero,
                                              tooltip: 'Edit points',
                                              onPressed: canEdit
                                                  ? () => _editPoints(context, c)
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  // 🧩 Grid Card UI
  Widget _gridCustomerCard(Customer c) {
    final canEdit = c.id.isNotEmpty;
    final isActive = c.status == 'active';
    // Generate a color from the customer name for the avatar
    final avatarColors = [
      const Color(0xFF2F3A8F),
      const Color(0xFF6C5CE7),
      const Color(0xFF00B894),
      const Color(0xFFE17055),
      const Color(0xFF0984E3),
      const Color(0xFFFD79A8),
    ];
    final colorIndex = c.name.isNotEmpty ? c.name.codeUnitAt(0) % avatarColors.length : 0;
    final avatarColor = avatarColors[colorIndex];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section with gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [avatarColor, avatarColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  child: Text(
                    c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 12, color: Colors.white70),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              c.phone,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Middle: Points + Status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFE8F5E9) : const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? Icons.circle : Icons.circle_outlined,
                          size: 8,
                          color: isActive ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Points row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EDFF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${c.points} pts',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF2F3A8F),
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 18),
                          padding: EdgeInsets.zero,
                          color: Colors.red.shade300,
                          tooltip: 'Decrease points',
                          onPressed: canEdit && c.points > 0
                              ? () => _updatePoints(c, -1)
                              : null,
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          padding: EdgeInsets.zero,
                          color: Colors.green.shade400,
                          tooltip: 'Increase points',
                          onPressed: canEdit && c.points < 1000
                              ? () => _updatePoints(c, 1)
                              : null,
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          padding: EdgeInsets.zero,
                          color: Colors.blueGrey,
                          tooltip: 'Edit points',
                          onPressed: canEdit
                              ? () => _editPoints(context, c)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePoints(Customer customer, int delta) async {
    if (customer.id.isEmpty) return;
    final newValue = customer.points + delta;
    if (newValue < 0 || newValue > 1000) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Points must stay between 0 and 1000'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(customer.id)
          .update({'points': newValue});
      await _maybeCreateMilestoneAlert(customer, newValue);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update points: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editPoints(BuildContext context, Customer customer) async {
    if (customer.id.isEmpty) return;
    final controller = TextEditingController(text: customer.points.toString());
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit points'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Points',
              ),
              validator: (value) {
                final raw = (value ?? '').trim();
                if (raw.isEmpty) return 'Please enter points';
                final parsed = int.tryParse(raw);
                if (parsed == null) return 'Points must be a number';
                if (parsed < 0 || parsed > 1000) {
                  return 'Points must be between 0 and 1000';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(ctx).pop(true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final raw = controller.text.trim();
    final parsed = int.tryParse(raw) ?? customer.points;

    try {
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(customer.id)
          .update({'points': parsed});
      await _maybeCreateMilestoneAlert(customer, parsed);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update points: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _maybeCreateMilestoneAlert(
      Customer customer, int newPoints) async {
    if (customer.id.isEmpty) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    // Milestones: 100, 200, ..., 1000
    const milestones = [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000];
    if (!milestones.contains(newPoints)) return;

    try {
      // Avoid duplicate unresolved alerts for same customer + milestone
      final existing = await FirebaseFirestore.instance
          .collection('alerts')
          .where('customerId', isEqualTo: customer.id)
          .where('shopkeeperId', isEqualTo: uid)
          .where('milestone', isEqualTo: newPoints)
          .where('resolved', isEqualTo: false)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) return;

      await FirebaseFirestore.instance.collection('alerts').add({
        'shopkeeperId': uid,
        'customerId': customer.id,
        'customerName': customer.name,
        'milestone': newPoints,
        'pointsAtTime': newPoints,
        'resolved': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create alert: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
