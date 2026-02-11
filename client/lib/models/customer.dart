import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  /// Firestore document ID (empty for local/sample customers).
  final String id;
  final String name;
  final int points;
  final String phone;
  final String status; // 'active' or 'inactive'

  Customer({
    this.id = '',
    required this.name,
    required this.points,
    required this.phone,
    required this.status,
  });

  /// Create a [Customer] from a generic Map (e.g. Firestore document data).
  factory Customer.fromMap(Map<String, dynamic>? data) {
    final map = data ?? <String, dynamic>{};

    return Customer(
      name: (map['name'] as String?)?.trim().isNotEmpty == true
          ? (map['name'] as String).trim()
          : 'Unknown',
      points: (map['points'] is num) ? (map['points'] as num).toInt() : 0,
      phone: (map['phone'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'inactive',
    );
  }

  /// Create a [Customer] directly from a Firestore document snapshot.
  factory Customer.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Customer(
      id: doc.id,
      name: (data['name'] as String?)?.trim().isNotEmpty == true
          ? (data['name'] as String).trim()
          : 'Unknown',
      points: (data['points'] is num) ? (data['points'] as num).toInt() : 0,
      phone: (data['phone'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'active',
    );
  }
}
