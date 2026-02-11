import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_realtime_service.dart';

/// Example screen demonstrating real-time collection listening
/// This screen automatically updates when documents are added, edited, or deleted
class RealtimeCollectionScreen extends StatefulWidget {
  final String collectionName;
  final String title;

  const RealtimeCollectionScreen({
    Key? key,
    required this.collectionName,
    required this.title,
  }) : super(key: key);

  @override
  State<RealtimeCollectionScreen> createState() =>
      _RealtimeCollectionScreenState();
}

class _RealtimeCollectionScreenState extends State<RealtimeCollectionScreen> {
  final _service = FirestoreRealtimeService();
  late Stream<QuerySnapshot> _collectionStream;

  @override
  void initState() {
    super.initState();
    _collectionStream = _service.getCollectionStream(widget.collectionName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _collectionStream,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // Empty state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${widget.collectionName} yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          // Display list of documents
          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    data['name'] ?? data['title'] ?? 'Untitled',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        data['description'] ?? data['content'] ?? 'No description',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Doc ID: ${doc.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  trailing: _buildStatusIndicator(data),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Builds a visual indicator for document status
  Widget _buildStatusIndicator(Map<String, dynamic> data) {
    if (data['status'] == 'published') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Published',
          style: TextStyle(
            color: Colors.green[700],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (data['status'] == 'draft') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Draft',
          style: TextStyle(
            color: Colors.orange[700],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
