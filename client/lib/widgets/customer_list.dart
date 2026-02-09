import 'package:flutter/material.dart';
import 'package:client/models/customer.dart';

class CustomerList extends StatefulWidget {
  final List<Customer>? initialCustomers;
  const CustomerList({super.key, this.initialCustomers});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  late List<Customer> _allCustomers;
  String _searchQuery = '';
  String _filter = 'All';
  bool _isGrid = false;

  @override
  void initState() {
    super.initState();
    _allCustomers = widget.initialCustomers ?? _sampleCustomers();
  }

  List<Customer> _sampleCustomers() => [
        Customer(name: 'Asha Sharma', points: 120, phone: '9876543210', status: 'active'),
        Customer(name: 'Ravi Kumar', points: 45, phone: '9876501234', status: 'active'),
        Customer(name: 'Nikita Jain', points: 78, phone: '9876512345', status: 'inactive'),
        Customer(name: 'Suresh Patil', points: 200, phone: '9876523456', status: 'active'),
        Customer(name: 'Meena Rao', points: 15, phone: '9876534567', status: 'inactive'),
        Customer(name: 'Tarun Mehta', points: 95, phone: '9876541234', status: 'active'),
        Customer(name: 'Priya Singh', points: 60, phone: '9876549876', status: 'active'),
        Customer(name: 'Vikram Das', points: 10, phone: '9876551111', status: 'inactive'),
      ];

  List<Customer> get _filtered {
    final q = _searchQuery.toLowerCase();
    return _allCustomers.where((c) {
      final matchesQuery = c.name.toLowerCase().contains(q) || c.phone.contains(q);
      if (!matchesQuery) return false;
      if (_filter == 'All') return true;
      if (_filter == 'Points > 50') return c.points > 50;
      if (_filter == 'Points > 100') return c.points > 100;
      if (_filter == 'Active') return c.status == 'active';
      if (_filter == 'Inactive') return c.status == 'inactive';
      return true;
    }).toList();
  }

  int get _totalCustomers => _allCustomers.length;
  double get _averagePoints =>
      _allCustomers.isEmpty ? 0 : _allCustomers.map((c) => c.points).reduce((a, b) => a + b) / _allCustomers.length;
  Customer? get _topCustomer =>
      _allCustomers.isEmpty ? null : (_allCustomers..sort((a, b) => b.points.compareTo(a.points))).first;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔍 Search + Filter + View Toggle
        Row(
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
              ],
              onChanged: (v) => setState(() => _filter = v!),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(Icons.view_list, color: !_isGrid ? Colors.blue : Colors.grey),
              onPressed: () => setState(() => _isGrid = false),
            ),
            IconButton(
              icon: Icon(Icons.grid_view, color: _isGrid ? Colors.blue : Colors.grey),
              onPressed: () => setState(() => _isGrid = true),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 📊 Stats
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF4F6FA), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Text("Total: $_totalCustomers"),
              const Spacer(),
              Text("Avg: ${_averagePoints.toStringAsFixed(1)}"),
              const Spacer(),
              if (_topCustomer != null) Text("Top: ${_topCustomer!.name}"),
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
          child: _filtered.isEmpty
              ? const Center(child: Text("No customers found"))
              : _isGrid
                  ? GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        return _gridCustomerCard(_filtered[index]);
                      },
                    )
                  : ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final c = _filtered[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Expanded(child: Text(c.name)),
                              Expanded(child: Text(c.phone)),
                              Expanded(child: Text("${c.points}")),
                              Expanded(
                                child: Chip(
                                  label: Text(c.status),
                                  backgroundColor:
                                      c.status == 'active' ? Colors.green[100] : Colors.grey[300],
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
  }

  // 🧩 Grid Card UI
  Widget _gridCustomerCard(Customer c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF4F6FA), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(c.name[0], style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 10),
          Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(c.phone, style: const TextStyle(color: Colors.black54)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${c.points} pts"),
              Chip(
                label: Text(c.status),
                backgroundColor: c.status == 'active' ? Colors.green[100] : Colors.grey[300],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
