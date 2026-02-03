import 'package:flutter/material.dart';
import 'package:client/models/customer.dart';

class ResponsiveLayout extends StatefulWidget {
  const ResponsiveLayout({super.key});

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  final List<Customer> _allCustomers = [
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

  String _searchQuery = '';
  String _filter = 'All';

  List<Customer> get _filtered {
    var list = _allCustomers.where((c) {
      final q = _searchQuery.toLowerCase();
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
    return list;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isLarge = screenWidth >= 600;

    Widget header = Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'GrowTown — Customers',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );

    Widget searchBar = Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search by name or phone',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: _filter,
          items: const [
            DropdownMenuItem(value: 'All', child: Text('All')),
            DropdownMenuItem(value: 'Points > 50', child: Text('Points > 50')),
            DropdownMenuItem(
              value: 'Points > 100',
              child: Text('Points > 100'),
            ),
            DropdownMenuItem(value: 'Active', child: Text('Active')),
            DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
          ],
          onChanged: (v) => setState(() => _filter = v ?? 'All'),
        ),
      ],
    );

    Widget dashboardSummary = Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Total customers: $_totalCustomers'),
            Text('Avg points: ${_averagePoints.toStringAsFixed(1)}'),
            if (_topCustomer != null)
              Text(
                'Top customer: ${_topCustomer!.name} (${_topCustomer!.points} pts)',
              ),
          ],
        ),
      ),
    );

    Widget customerCard(Customer c) {
      return Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Points: ${c.points}'),
              Text('Phone: ${c.phone}'),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(c.status),
                    backgroundColor: c.status == 'active'
                        ? Colors.green[100]
                        : Colors.grey[300],
                  ),
                  IconButton(
                    onPressed: () {
                      // placeholder: open customer details
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Open ${c.name}')));
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget leftPanel = Column(
      children: [
        searchBar,
        const SizedBox(height: 10),
        Expanded(
          child: isLarge
              ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (screenWidth ~/ 300).clamp(2, 4),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) =>
                      customerCard(_filtered[index]),
                )
              : ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      customerCard(_filtered[index]),
                ),
        ),
      ],
    );

    Widget rightPanel = Column(
      children: [
        dashboardSummary,
        const SizedBox(height: 10),
        Expanded(
          child: Card(
            elevation: 1,
            child: Center(
              child: Text(
                'Use the search box to filter customers\nand change filters to test responsive behavior.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );

    Widget footer = Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Text('Footer Section')),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Responsive Layout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            header,
            const SizedBox(height: 12),
            Expanded(
              child: isLarge
                  ? Row(
                      children: [
                        Expanded(flex: 3, child: leftPanel),
                        const SizedBox(width: 12),
                        Expanded(flex: 1, child: rightPanel),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(flex: 3, child: leftPanel),
                        const SizedBox(height: 12),
                        SizedBox(height: 260, child: rightPanel),
                      ],
                    ),
            ),
            const SizedBox(height: 12),
            footer,
          ],
        ),
      ),
    );
  }
}
