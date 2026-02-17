import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service class that provides full CRUD operations for notes
/// stored under `/users/{uid}/items/` in Cloud Firestore.
///
/// All operations are scoped to the currently authenticated user's UID.
class NotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns the Firestore collection reference for the current user's items.
  CollectionReference _userItemsCollection() {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).collection('items');
  }

  // ---------------------------------------------------------------------------
  // READ — Real-time stream of notes ordered by creation date (newest first)
  // ---------------------------------------------------------------------------

  /// Returns a real-time stream of the current user's notes.
  /// Used with `StreamBuilder` in the UI for live updates.
  Stream<QuerySnapshot> getNotesStream() {
    return _userItemsCollection()
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ---------------------------------------------------------------------------
  // CREATE — Add a new note
  // ---------------------------------------------------------------------------

  /// Creates a new note document under `/users/{uid}/items/{auto-id}`.
  Future<DocumentReference> addNote({
    required String title,
    required String content,
  }) {
    return _userItemsCollection().add({
      'title': title,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------------------------------------------------------------------
  // UPDATE — Edit an existing note
  // ---------------------------------------------------------------------------

  /// Updates the title and content of an existing note.
  Future<void> updateNote({
    required String noteId,
    required String title,
    required String content,
  }) {
    return _userItemsCollection().doc(noteId).update({
      'title': title,
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------------------------------------------------------------------
  // DELETE — Remove a note
  // ---------------------------------------------------------------------------

  /// Deletes a note document by its ID.
  Future<void> deleteNote(String noteId) {
    return _userItemsCollection().doc(noteId).delete();
  }
}
