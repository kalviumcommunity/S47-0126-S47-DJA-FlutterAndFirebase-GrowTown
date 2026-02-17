import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';
import '../services/notes_service.dart';
import 'add_edit_note_screen.dart';

/// Screen that displays the authenticated user's notes in real time
/// using a StreamBuilder on the Firestore `/users/{uid}/items` collection.
class MyNotesScreen extends StatelessWidget {
  const MyNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotesService notesService = NotesService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notesService.getNotesStream(),
        builder: (context, snapshot) {
          // ── Loading state ───────────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error state ─────────────────────────────────────────────────
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          // ── Empty state ─────────────────────────────────────────────────
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.note_add_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No notes yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to create your first note',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          // ── Notes list ──────────────────────────────────────────────────
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final note = Note.fromFirestore(docs[index]);
              return _NoteCard(
                note: note,
                onTap: () => _openEditScreen(context, note),
                onDelete: () => _confirmDelete(context, notesService, note),
              );
            },
          );
        },
      ),

      // ── FAB to create a new note ─────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddScreen(context),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ── Navigation helpers ────────────────────────────────────────────────

  void _openAddScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditNoteScreen()),
    );
  }

  void _openEditScreen(BuildContext context, Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditNoteScreen(
          noteId: note.id,
          initialTitle: note.title,
          initialContent: note.content,
        ),
      ),
    );
  }

  // ── Delete confirmation ───────────────────────────────────────────────

  void _confirmDelete(
      BuildContext context, NotesService service, Note note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await service.deleteNote(note.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note deleted')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Note card widget
// ═══════════════════════════════════════════════════════════════════════════════

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title row + delete button ───────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Delete note',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ── Content preview ─────────────────────────────────────────
              if (note.content.isNotEmpty)
                Text(
                  note.content,
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black54, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),

              // ── Timestamp ───────────────────────────────────────────────
              Text(
                'Updated ${_formatDate(note.updatedAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
