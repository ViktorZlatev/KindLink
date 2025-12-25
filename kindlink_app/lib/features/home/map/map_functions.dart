import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // =====================================
  // 1️⃣ SAVE SINGLE LOCATION (ALL USERS)
  // =====================================
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

  // =====================================
  // 2️⃣ START LIVE LOCATION (VOLUNTEERS)
  // =====================================
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

  // =====================================
  // 3️⃣ STOP LIVE LOCATION
  // =====================================
  Future<void> stopVolunteerLocationUpdates() async {
    _isStreaming = false;
    await _liveLocationStream?.cancel();
    _liveLocationStream = null;
  }

  // =====================================
  // 4️⃣ LISTEN TO VOLUNTEER MARKERS
  // =====================================
  void listenToVolunteerLocations({
    required Function(Map<String, Marker>) onMarkersUpdated,
    required MarkerTapCallback onMarkerTap,
  }) {
    _volunteerLocationStream?.cancel();

    _volunteerLocationStream = FirebaseFirestore.instance
        .collection("users")
        .where("isVolunteer", isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      final Map<String, Marker> markers = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final loc = data["location"];
        if (loc == null) continue;

        final lat = (loc["lat"] as num?)?.toDouble();
        final lng = (loc["lng"] as num?)?.toDouble();
        if (lat == null || lng == null) continue;

        final markerId = "${doc.id}_${lat}_${lng}";

        markers[markerId] = Marker(
          markerId: MarkerId(markerId),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
          onTap: () {
            onMarkerTap(
              name: data["username"] ?? "Volunteer",
              lat: lat,
              lng: lng,
              updatedAt: loc["updatedAt"],
              userId: doc.id,
            );
          },
        );
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
