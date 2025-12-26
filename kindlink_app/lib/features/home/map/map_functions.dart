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
  StreamSubscription<Position>? _locationStream;
  StreamSubscription<QuerySnapshot>? _volunteerLocationStream;

  // ================================
  // 1. START VOLUNTEER LOCATION UPDATES
  // ================================
  Future<void> startVolunteerLocationUpdates({
    required Function(String) onError,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      onError("Please enable GPS.");
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      onError("Location permission permanently denied.");
      return;
    }

    await _locationStream?.cancel();

    _locationStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) async {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "location": {
          "lat": pos.latitude,
          "lng": pos.longitude,
          "updatedAt": FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
    });
  }

  // ================================
  // 2. LISTEN TO VOLUNTEERS (LIVE)
  // ================================
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
        final data = doc.data() as Map<String, dynamic>;

        if (data["location"] == null) continue;

        final loc = Map<String, dynamic>.from(data["location"]);

        final double? lat = (loc["lat"] as num?)?.toDouble();
        final double? lng = (loc["lng"] as num?)?.toDouble();
        if (lat == null || lng == null) continue;

        final updatedAt = loc["updatedAt"];
        final name = (data["username"] ?? "Volunteer").toString();
        final userId = (data["uid"] as String?) ?? doc.id;

        // 🔥 CRITICAL FIX: markerId MUST CHANGE when location changes
        final markerId = '${doc.id}_${lat}_$lng';

        markers[markerId] = Marker(
          markerId: MarkerId(markerId),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
          infoWindow: InfoWindow(
            title: name,
            snippet: "Tap to see details",
          ),
          onTap: () {
            onMarkerTap(
              name: name,
              lat: lat,
              lng: lng,
              updatedAt: updatedAt,
              userId: userId,
            );
          },
        );
      }

      onMarkersUpdated(markers);
    });
  }

  // ================================
  // CLEANUP
  // ================================
  void dispose() {
    _locationStream?.cancel();
    _volunteerLocationStream?.cancel();
  }
}
