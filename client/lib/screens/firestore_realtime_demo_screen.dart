import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_realtime_service.dart';
import 'realtime_collection_screen.dart';
import 'realtime_document_screen.dart';

/// Demo screen showcasing real-time Firestore synchronization
/// This screen allows you to navigate to collection and document listeners
class FirestoreRealtimeDemoScreen extends StatefulWidget {
  const FirestoreRealtimeDemoScreen({Key? key}) : super(key: key);

  @override
  State<FirestoreRealtimeDemoScreen> createState() =>
      _FirestoreRealtimeDemoScreenState();
}

class _FirestoreRealtimeDemoScreenState
    extends State<FirestoreRealtimeDemoScreen> {
  final _service = FirestoreRealtimeService();
  final TextEditingController _collectionController = TextEditingController();
  final TextEditingController _docIdController = TextEditingController();
  List<String> _availableCollections = [];
  bool _loadingCollections = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableCollections();
  }

  /// Load available collections from Firestore
  Future<void> _loadAvailableCollections() async {
    setState(() => _loadingCollections = true);
    try {
      final collections = await FirebaseFirestore.instance
          .collection('_metadata')
          .doc('collections')
          .get()
          .catchError((_) => null);

      // Fallback: use common collection names as examples
      setState(() {
        _availableCollections = [
          'posts',
          'users',
          'comments',
          'products',
          'orders',
          'customers',
          'messages',
        ];
      });
    } catch (e) {
      print('Error loading collections: $e');
    } finally {
      setState(() => _loadingCollections = false);
    }
  }

  @override
  void dispose() {
    _collectionController.dispose();
    _docIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Real-Time Demo'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Card(
              color: Colors.blue[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.blue[200]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Real-Time Firestore Listeners',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Navigate to a collection or document to see real-time updates. Any changes made in Firestore Console will appear instantly without refreshing.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[800],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Collection listener section
            _buildSection(
              title: 'View Collection (Real-Time)',
              icon: Icons.collections,
              child: Column(
                children: [
                  TextField(
                    controller: _collectionController,
                    decoration: InputDecoration(
                      hintText: 'Enter collection name',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: _collectionController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _collectionController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  if (_availableCollections.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Common collections:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableCollections
                              .map((collection) => FilterChip(
                                    label: Text(collection),
                                    onSelected: (_) {
                                      _collectionController.text = collection;
                                      setState(() {});
                                    },
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _collectionController.text.isEmpty
                          ? null
                          : _navigateToCollection,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('View Collection'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Document listener section
            _buildSection(
              title: 'View Document (Real-Time)',
              icon: Icons.description,
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Collection name',
                      prefixIcon: const Icon(Icons.folder),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) =>
                        _docIdController.text.split('/')[0] == value
                            ? null
                            : setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Document ID',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => _docIdController.text = value,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _collectionController.text.isEmpty ||
                              _docIdController.text.isEmpty
                          ? null
                          : _navigateToDocument,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('View Document'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // How it works section
            _buildSection(
              title: 'How Real-Time Listeners Work',
              icon: Icons.lightbulb_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureRow(
                    icon: Icons.cloud_queue,
                    title: 'Collection Listener',
                    description:
                        'Listens to all documents in a collection. Updates when docs are added, modified, or deleted.',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureRow(
                    icon: Icons.document_scanner,
                    title: 'Document Listener',
                    description:
                        'Listens to a specific document. Updates when any field changes.',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureRow(
                    icon: Icons.sync,
                    title: 'Real-Time Sync',
                    description:
                        'Changes in Firestore appear in your app instantly without manual refresh.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a section with title and content
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ],
    );
  }

  /// Build a feature row
  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue[700], size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Navigate to collection listener screen
  void _navigateToCollection() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RealtimeCollectionScreen(
          collectionName: _collectionController.text,
          title: _collectionController.text,
        ),
      ),
    );
  }

  /// Navigate to document listener screen
  void _navigateToDocument() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RealtimeDocumentScreen(
          collectionName: _collectionController.text,
          docId: _docIdController.text,
          title: '${_collectionController.text} / ${_docIdController.text}',
        ),
      ),
    );
  }
}
