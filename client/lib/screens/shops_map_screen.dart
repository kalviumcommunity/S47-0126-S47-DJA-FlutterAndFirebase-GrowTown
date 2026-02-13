import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShopsMapScreen extends StatefulWidget {
  const ShopsMapScreen({super.key});

  @override
  State<ShopsMapScreen> createState() => _ShopsMapScreenState();
}

class _ShopsMapScreenState extends State<ShopsMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Marker? _pendingMarker;

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(28.6139, 77.2090),
    zoom: 10,
  );

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
        return Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(gp.latitude, gp.longitude),
          infoWindow: InfoWindow(
            title: (data['name'] as String?) ?? 'Shop',
            snippet: isMe ? 'Your shop' : null,
          ),
          icon: isMe
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      }).whereType<Marker>().toSet();
      setState(() {
        _markers
          ..clear()
          ..addAll(markers);
      });
    });
  }

  void _onMapTap(LatLng pos) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    setState(() {
      _pendingMarker = Marker(
        markerId: const MarkerId('pending'),
        position: pos,
        infoWindow: const InfoWindow(title: 'New shop location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    });
  }

  Future<void> _saveMyLocation() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final pm = _pendingMarker;
    if (uid == null || uid.isEmpty || pm == null) return;

    final data = {
      'ownerUid': uid,
      'location': GeoPoint(pm.position.latitude, pm.position.longitude),
      'visible': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await FirebaseFirestore.instance.collection('shops').doc(uid).set(
          data,
          SetOptions(merge: true),
        );
    setState(() {
      _pendingMarker = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allMarkers = {
      ..._markers,
      if (_pendingMarker != null) _pendingMarker!,
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Shops Map')),
      body: GoogleMap(
        initialCameraPosition: _initialCamera,
        markers: allMarkers,
        onMapCreated: (c) => _mapController = c,
        onTap: _onMapTap,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      floatingActionButton: _pendingMarker == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _saveMyLocation,
              icon: const Icon(Icons.save),
              label: const Text('Save location'),
            ),
    );
  }
}
