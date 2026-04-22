import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show consolidateHttpClientResponseBytes;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

typedef MarkerTapCallback = void Function({
  required String name,
  required double lat,
  required double lng,
  required dynamic updatedAt,
  required String userId,
});

class MapFunctions {
  StreamSubscription<Position>? _liveLocationStream;
  StreamSubscription<QuerySnapshot>? _volunteerLocationStream;

  bool _isStreaming = false;

  final Map<String, BitmapDescriptor> _markerIconCache = {};

  Future<BitmapDescriptor> _buildCircularMarker(String imageUrl) async {
    if (_markerIconCache.containsKey(imageUrl)) {
      return _markerIconCache[imageUrl]!;
    }
    try {
      final client = HttpClient();
      final req = await client.getUrl(Uri.parse(imageUrl));
      final res = await req.close();
      final bytes = await consolidateHttpClientResponseBytes(res);
      client.close();

      const double size = 120;
      final codec = await ui.instantiateImageCodec(
          bytes, targetWidth: size.toInt(), targetHeight: size.toInt());
      final frame = await codec.getNextFrame();
      final srcImage = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);

      canvas.drawCircle(
        const ui.Offset(size / 2, size / 2),
        size / 2,
        ui.Paint()..color = const ui.Color(0xFF6C63FF),
      );

      final clipPath = ui.Path()
        ..addOval(ui.Rect.fromLTWH(4, 4, size - 8, size - 8));
      canvas.clipPath(clipPath);

      canvas.drawImageRect(
        srcImage,
        ui.Rect.fromLTWH(
            0, 0, srcImage.width.toDouble(), srcImage.height.toDouble()),
        const ui.Rect.fromLTWH(4, 4, size - 8, size - 8),
        ui.Paint(),
      );

      final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      final descriptor =
          BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
      _markerIconCache[imageUrl] = descriptor;
      return descriptor;
    } catch (_) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    }
  }

  
  // SAVE SINGLE LOCATION - ALL USERS
  
  Future<void> saveSingleLocation({
    required Function(String) onError,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      onError("Please enable GPS.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      onError("Location permission permanently denied.");
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "location": {
        "lat": pos.latitude,
        "lng": pos.longitude,
        "updatedAt": FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true));
  }


  // START LIVE LOCATION - VOLUNTEERS
  
  Future<void> startVolunteerLocationUpdates({
    required Function(String) onError,
  }) async {
    if (_isStreaming) return;
    _isStreaming = true;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _isStreaming = false;
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _isStreaming = false;
      onError("Please enable GPS.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      _isStreaming = false;
      onError("Location permission required.");
      return;
    }

    await _liveLocationStream?.cancel();

    _liveLocationStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) async {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "location": {
          "lat": pos.latitude,
          "lng": pos.longitude,
          "updatedAt": FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
    });
  }

  
  // STOP LIVE LOCATION
  
  Future<void> stopVolunteerLocationUpdates() async {
    _isStreaming = false;
    await _liveLocationStream?.cancel();
    _liveLocationStream = null;
  }

  // LISTEN TO VOLUNTEER MARKERS

  void listenToVolunteerLocations({
    required Function(Map<String, Marker>) onMarkersUpdated,
    required MarkerTapCallback onMarkerTap,
  }) {
    _volunteerLocationStream?.cancel();

    _volunteerLocationStream = FirebaseFirestore.instance
        .collection("users")
        .where("isVolunteer", isEqualTo: true)
        .snapshots()
        .listen((snapshot) async {
      final futures = snapshot.docs.map((doc) async {
        final data = doc.data();
        final loc = data["location"];
        if (loc == null) return null;

        final lat = (loc["lat"] as num?)?.toDouble();
        final lng = (loc["lng"] as num?)?.toDouble();
        if (lat == null || lng == null) return null;

        final markerId = "${doc.id}_${lat}_${lng}";
        final photoUrl = data["profilePhotoUrl"] as String?;

        final icon = (photoUrl != null && photoUrl.isNotEmpty)
            ? await _buildCircularMarker(photoUrl)
            : BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet);

        return MapEntry(
          markerId,
          Marker(
            markerId: MarkerId(markerId),
            position: LatLng(lat, lng),
            icon: icon,
            onTap: () {
              onMarkerTap(
                name: data["username"] ?? "Volunteer",
                lat: lat,
                lng: lng,
                updatedAt: loc["updatedAt"],
                userId: doc.id,
              );
            },
          ),
        );
      });

      final results = await Future.wait(futures);
      final Map<String, Marker> markers = {};
      for (final entry in results) {
        if (entry != null) markers[entry.key] = entry.value;
      }
      onMarkersUpdated(markers);
    });
  }

  void dispose() {
    _isStreaming = false;
    _liveLocationStream?.cancel();
    _volunteerLocationStream?.cancel();
  }
}
