import 'package:cloud_firestore/cloud_firestore.dart';

/// A service class that provides real-time Firestore listeners
/// for collections and documents with snapshot streaming support.
class FirestoreRealtimeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Listens to a specific collection and returns a stream of snapshots
  /// 
  /// Example:
  /// ```dart
  /// Stream<QuerySnapshot> postsStream = FirestoreRealtimeService()
  ///   .getCollectionStream('posts');
  /// ```
  /// 
  /// The stream triggers when:
  /// - A new document is added to the collection
  /// - An existing document is edited
  /// - A document is deleted
  /// 
  /// Parameters:
  ///   - collectionPath: Path to the Firestore collection
  /// 
  /// Returns: A Stream<QuerySnapshot> that emits collection snapshots
  Stream<QuerySnapshot> getCollectionStream(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots();
  }

  /// Listens to a specific document and returns a stream of snapshots
  /// 
  /// Example:
  /// ```dart
  /// Stream<DocumentSnapshot> userStream = FirestoreRealtimeService()
  ///   .getDocumentStream('users', userId);
  /// ```
  /// 
  /// The stream triggers when:
  /// - A field in the document is updated
  /// - Server timestamps change
  /// - Nested fields are modified
  /// 
  /// Parameters:
  ///   - collectionPath: Path to the Firestore collection
  ///   - docId: Document ID to listen to
  /// 
  /// Returns: A Stream<DocumentSnapshot> that emits document snapshots
  Stream<DocumentSnapshot> getDocumentStream(
    String collectionPath,
    String docId,
  ) {
    return _firestore.collection(collectionPath).doc(docId).snapshots();
  }

  /// Listens to a collection with custom query filters and returns a stream
  /// 
  /// Example:
  /// ```dart
  /// Stream<QuerySnapshot> activePostsStream = FirestoreRealtimeService()
  ///   .getFilteredCollectionStream('posts', 'status', '==', 'published');
  /// ```
  /// 
  /// Parameters:
  ///   - collectionPath: Path to the Firestore collection
  ///   - field: Field name to filter on
  ///   - operator: Comparison operator ('==', '<', '<=', '>', '>=', '!=', 'array-contains', 'in')
  ///   - value: Value to compare against
  /// 
  /// Returns: A Stream<QuerySnapshot> of filtered results
  Stream<QuerySnapshot> getFilteredCollectionStream(
    String collectionPath,
    String field,
    String operator,
    dynamic value,
  ) {
    Query query = _firestore.collection(collectionPath);

    switch (operator) {
      case '==':
        query = query.where(field, isEqualTo: value);
        break;
      case '<':
        query = query.where(field, isLessThan: value);
        break;
      case '<=':
        query = query.where(field, isLessThanOrEqualTo: value);
        break;
      case '>':
        query = query.where(field, isGreaterThan: value);
        break;
      case '>=':
        query = query.where(field, isGreaterThanOrEqualTo: value);
        break;
      case '!=':
        query = query.where(field, isNotEqualTo: value);
        break;
      case 'array-contains':
        query = query.where(field, arrayContains: value);
        break;
      case 'in':
        query = query.where(field, whereIn: value);
        break;
      default:
        throw ArgumentError('Invalid operator: $operator');
    }

    return query.snapshots();
  }

  /// Listens to a collection with ordering
  /// 
  /// Parameters:
  ///   - collectionPath: Path to the Firestore collection
  ///   - orderByField: Field to order by
  ///   - descending: Whether to sort in descending order (default: false)
  /// 
  /// Returns: A Stream<QuerySnapshot> of ordered results
  Stream<QuerySnapshot> getOrderedCollectionStream(
    String collectionPath,
    String orderByField, {
    bool descending = false,
  }) {
    return _firestore
        .collection(collectionPath)
        .orderBy(orderByField, descending: descending)
        .snapshots();
  }

  /// Listens to a collection with both filtering and ordering
  /// 
  /// Parameters:
  ///   - collectionPath: Path to the Firestore collection
  ///   - field: Field name to filter on
  ///   - operator: Comparison operator
  ///   - value: Value to compare against
  ///   - orderByField: Field to order by
  ///   - descending: Whether to sort in descending order
  /// 
  /// Returns: A Stream<QuerySnapshot> of filtered and ordered results
  Stream<QuerySnapshot> getFilteredAndOrderedCollectionStream(
    String collectionPath,
    String field,
    String operator,
    dynamic value,
    String orderByField, {
    bool descending = false,
  }) {
    Query query = _firestore.collection(collectionPath);

    // Apply filter
    switch (operator) {
      case '==':
        query = query.where(field, isEqualTo: value);
        break;
      case '<':
        query = query.where(field, isLessThan: value);
        break;
      case '<=':
        query = query.where(field, isLessThanOrEqualTo: value);
        break;
      case '>':
        query = query.where(field, isGreaterThan: value);
        break;
      case '>=':
        query = query.where(field, isGreaterThanOrEqualTo: value);
        break;
      case '!=':
        query = query.where(field, isNotEqualTo: value);
        break;
      case 'array-contains':
        query = query.where(field, arrayContains: value);
        break;
      case 'in':
        query = query.where(field, whereIn: value);
        break;
      default:
        throw ArgumentError('Invalid operator: $operator');
    }

    // Apply ordering
    query = query.orderBy(orderByField, descending: descending);

    return query.snapshots();
  }

  /// Get a snapshot of the entire collection at once (non-reactive)
  /// Useful when you only need current data, not real-time updates
  Future<QuerySnapshot> getCollectionOnce(String collectionPath) {
    return _firestore.collection(collectionPath).get();
  }

  /// Get a snapshot of a specific document at once (non-reactive)
  Future<DocumentSnapshot> getDocumentOnce(
    String collectionPath,
    String docId,
  ) {
    return _firestore.collection(collectionPath).doc(docId).get();
  }
}
