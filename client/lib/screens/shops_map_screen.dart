import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ShopsMapScreen extends StatefulWidget {
  const ShopsMapScreen({super.key});

  @override
  State<ShopsMapScreen> createState() => _ShopsMapScreenState();
}

class _ShopsMapScreenState extends State<ShopsMapScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  LatLng? _pendingLocation;
  String _selectedTileProvider = 'OpenStreetMap';
  bool _isSetLocationMode = false;
  bool _isSaving = false;

  static const LatLng _initialCenter = LatLng(28.6139, 77.2090); // Delhi, India
  static const double _initialZoom = 10.0;

  // Free Map Tile Providers (No API key required for basic usage)
  final Map<String, Map<String, dynamic>> _tileProviders = {
    'OpenStreetMap': {
      'url': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      'maxZoom': 19,
      'attribution': '© OpenStreetMap contributors',
    },
    'OpenTopoMap': {
      'url': 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
      'maxZoom': 17,
      'attribution': '© OpenTopoMap contributors',
    },
    'Humanitarian': {
      'url': 'https://tile-{s}.openstreetmap.fr/hot/{z}/{x}/{y}.png',
      'maxZoom': 19,
      'subdomains': ['a', 'b'],
      'attribution': '© OpenStreetMap contributors, Humanitarian style',
    },
    'CyclOSM': {
      'url': 'https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png',
      'maxZoom': 20,
      'subdomains': ['a', 'b', 'c'],
      'attribution': '© CyclOSM, OpenStreetMap contributors',
    },
  };

  @override
  void initState() {
    super.initState();
    _subscribeShops();
  }

  void _subscribeShops() {
    FirebaseFirestore.instance.collection('shops').snapshots().listen((snap) {
      final markers = snap.docs.map((doc) {
        final data = doc.data();
        final gp = data['location'] as GeoPoint?;
        if (gp == null) return null;
        
        final isMe = doc.id == FirebaseAuth.instance.currentUser?.uid;
        final shopName = (data['name'] as String?) ?? 'Shop';
        
        return Marker(
          point: LatLng(gp.latitude, gp.longitude),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              _showShopInfo(shopName, isMe);
            },
            child: Icon(
              Icons.location_on,
              size: 40,
              color: isMe ? Colors.blue : Colors.red,
            ),
          ),
        );
      }).whereType<Marker>().toList();
      
      setState(() {
        _markers
          ..clear()
          ..addAll(markers);
        
        // Add pending marker if exists
        if (_pendingLocation != null) {
          _markers.add(
            Marker(
              point: _pendingLocation!,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.location_on,
                size: 40,
                color: Colors.green,
              ),
            ),
          );
        }
      });
    });
  }

  void _showShopInfo(String shopName, bool isMe) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$shopName${isMe ? " (Your shop)" : ""}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onMapTap(TapPosition tapPosition, LatLng location) {
    if (!_isSetLocationMode) return; // Only allow tap when in set location mode
    
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to set your shop location'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _pendingLocation = location;
      // Update markers to include pending marker
      _subscribeShops();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location selected! Tap "Save Location" to confirm.'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );
  }
  
  void _toggleSetLocationMode() {
    setState(() {
      _isSetLocationMode = !_isSetLocationMode;
      if (!_isSetLocationMode) {
        _pendingLocation = null; // Clear pending location when exiting mode
      }
    });
    
    if (_isSetLocationMode) {
      _showSetLocationInstructions();
    }
  }
  
  void _showSetLocationInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Set Your Shop Location'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How to set your shop location:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text('Tap anywhere on the map')),
              ],
            ),
            SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('2. ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text('A green marker will appear')),
              ],
            ),
            SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('3. ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text('Tap "Save Location" to confirm')),
              ],
            ),
            SizedBox(height: 12),
            Text('💡 Tip: Pinch to zoom and find your exact location!', 
                 style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
  
  void _cancelPendingLocation() {
    setState(() {
      _pendingLocation = null;
      _isSetLocationMode = false;
    });
    _subscribeShops();
  }

  Future<void> _saveMyLocation() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty || _pendingLocation == null) return;

    setState(() => _isSaving = true);
    
    try {
      final data = {
        'ownerUid': uid,
        'name': 'My Shop', // Default name, can be updated later
        'location': GeoPoint(_pendingLocation!.latitude, _pendingLocation!.longitude),
        'visible': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await FirebaseFirestore.instance.collection('shops').doc(uid).set(
            data,
            SetOptions(merge: true),
          );
      
      setState(() {
        _pendingLocation = null;
        _isSetLocationMode = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Shop location saved successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedProvider = _tileProviders[_selectedTileProvider]!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shops Map',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.layers, color: Colors.black87),
            tooltip: 'Change Map Style',
            onSelected: (value) {
              setState(() {
                _selectedTileProvider = value;
              });
            },
            itemBuilder: (context) => _tileProviders.keys.map((provider) {
              return PopupMenuItem<String>(
                value: provider,
                child: Row(
                  children: [
                    Icon(
                      _selectedTileProvider == provider
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(provider),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              onTap: _onMapTap,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: selectedProvider['url'] as String,
                userAgentPackageName: 'com.example.growtown',
                maxZoom: (selectedProvider['maxZoom'] as int).toDouble(),
                minZoom: 3,
                subdomains: selectedProvider['subdomains'] as List<String>? ?? const [],
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),
          
          // Set Location Mode Banner
          if (_isSetLocationMode)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade600, Colors.green.shade400],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Tap anywhere on the map to set your shop location',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: _toggleSetLocationMode,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          
          // Map type indicator
          Positioned(
            top: _isSetLocationMode ? 64 : 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.map, size: 16, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(
                    _selectedTileProvider,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Set Location Button
          if (!_isSetLocationMode && _pendingLocation == null)
            Positioned(
              top: _isSetLocationMode ? 64 : 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'setLocation',
                onPressed: _toggleSetLocationMode,
                backgroundColor: Colors.blue,
                tooltip: 'Set My Shop Location',
                child: const Icon(Icons.add_location_alt),
              ),
            ),
          
          // Legend
          Positioned(
            bottom: _pendingLocation != null ? 80 : 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _legendItem(Colors.blue, 'Your Shop'),
                  const SizedBox(height: 4),
                  _legendItem(Colors.red, 'Other Shops'),
                  const SizedBox(height: 4),
                  _legendItem(Colors.green, 'New Location'),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _pendingLocation == null
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'cancel',
                  onPressed: _cancelPendingLocation,
                  backgroundColor: Colors.grey.shade700,
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.extended(
                  heroTag: 'save',
                  onPressed: _isSaving ? null : _saveMyLocation,
                  backgroundColor: Colors.green,
                  icon: _isSaving 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save Location'),
                ),
              ],
            ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
