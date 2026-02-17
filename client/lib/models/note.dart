import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for a user's personal note stored in Firestore
/// at `/users/{uid}/items/{itemId}`.
class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [Note] from a Firestore document snapshot.
  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts this [Note] to a Firestore-compatible map for creating a new doc.
  Map<String, dynamic> toFirestoreCreate() {
    return {
      'title': title,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Converts this [Note] to a Firestore-compatible map for updating an existing doc.
  static Map<String, dynamic> toFirestoreUpdate({
    required String title,
    required String content,
  }) {
    return {
      'title': title,
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
