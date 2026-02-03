import 'package:flutter/material.dart';
import 'package:client/models/customer.dart';
import 'package:client/widgets/customer_card.dart';

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

  @override
  void initState() {
    super.initState();
    _allCustomers = widget.initialCustomers ?? _sampleCustomers();
  }

  List<Customer> _sampleCustomers() => [
    Customer(
      name: 'Asha Sharma',
      points: 120,
      phone: '9876543210',
      status: 'active',
    ),
    Customer(
      name: 'Ravi Kumar',
      points: 45,
      phone: '9876501234',
      status: 'active',
    ),
    Customer(
      name: 'Nikita Jain',
      points: 78,
      phone: '9876512345',
      status: 'inactive',
    ),
    Customer(
      name: 'Suresh Patil',
      points: 200,
      phone: '9876523456',
      status: 'active',
    ),
    Customer(
      name: 'Meena Rao',
      points: 15,
      phone: '9876534567',
      status: 'inactive',
    ),
    Customer(
      name: 'Tarun Mehta',
      points: 95,
      phone: '9876541234',
      status: 'active',
    ),
    Customer(
      name: 'Priya Singh',
      points: 60,
      phone: '9876549876',
      status: 'active',
    ),
    Customer(
      name: 'Vikram Das',
      points: 10,
      phone: '9876551111',
      status: 'inactive',
    ),
  ];

  List<Customer> get _filtered {
    final q = _searchQuery.toLowerCase();
    return _allCustomers.where((c) {
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

  int get _totalCustomers => _allCustomers.length;
  double get _averagePoints => _allCustomers.isEmpty
      ? 0
      : _allCustomers.map((c) => c.points).reduce((a, b) => a + b) /
            _allCustomers.length;
  Customer? get _topCustomer => _allCustomers.isEmpty
      ? null
      : (_allCustomers..sort((a, b) => b.points.compareTo(a.points))).first;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search by name or phone',
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _filter,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(
                      value: 'Points > 50',
                      child: Text('Points > 50'),
                    ),
                    DropdownMenuItem(
                      value: 'Points > 100',
                      child: Text('Points > 100'),
                    ),
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(
                      value: 'Inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _filter = v ?? 'All'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total customers: $_totalCustomers',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Avg points: ${_averagePoints.toStringAsFixed(1)}',
                        style: TextStyle(color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (_topCustomer != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Top'),
                      Text(
                        _topCustomer!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${_topCustomer!.points} pts',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _filtered.isEmpty
              ? const Center(child: Text('No customers match your filters'))
              : ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final c = _filtered[index];
                    return CustomerCard(
                      customer: c,
                      onTap: () => ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Open ${c.name}'))),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
