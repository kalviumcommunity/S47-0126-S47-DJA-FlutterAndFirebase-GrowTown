import 'package:flutter/material.dart';
import '../services/notes_service.dart';

/// A screen for creating or editing a note.
///
/// - **Create mode**: Pass no arguments → shows empty form.
/// - **Edit mode**: Pass [noteId], [initialTitle], and [initialContent].
class AddEditNoteScreen extends StatefulWidget {
  final String? noteId;
  final String? initialTitle;
  final String? initialContent;

  const AddEditNoteScreen({
    super.key,
    this.noteId,
    this.initialTitle,
    this.initialContent,
  });

  /// Returns `true` when editing an existing note.
  bool get isEditing => noteId != null;

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final NotesService _notesService = NotesService();

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _contentController =
        TextEditingController(text: widget.initialContent ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // ── Save handler ──────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();

      if (widget.isEditing) {
        await _notesService.updateNote(
          noteId: widget.noteId!,
          title: title,
          content: content,
        );
      } else {
        await _notesService.addNote(title: title, content: content);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(widget.isEditing ? 'Note updated' : 'Note created'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Note' : 'New Note'),
        centerTitle: true,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Save',
              onPressed: _save,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Title field ────────────────────────────────────────────
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter note title',
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Content field ──────────────────────────────────────────
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Write your note here…',
                  alignLabelWithHint: true,
                ),
                maxLines: 12,
                minLines: 5,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // ── Save button ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: Icon(widget.isEditing ? Icons.save : Icons.add),
                  label: Text(widget.isEditing ? 'Update Note' : 'Create Note'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
