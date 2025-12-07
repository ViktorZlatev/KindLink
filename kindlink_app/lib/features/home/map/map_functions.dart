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

  // 🔥 1. START UPDATING THIS USER'S CURRENT LOCATION (Volunteer)
  Future<void> startVolunteerLocationUpdates({
    required Function(String) onError,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
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

    _locationStream?.cancel();

    _locationStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position pos) async {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({
        "location": {
          "lat": pos.latitude,
          "lng": pos.longitude,
          "updatedAt": FieldValue.serverTimestamp(),
        }
      });

      // Debug:
      // print("🌍 Updated Location: ${pos.latitude}, ${pos.longitude}");
    });
  }

  // 🔥 2. LISTEN TO ALL VOLUNTEERS' LIVE LOCATIONS
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
      Map<String, Marker> markers = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (data["location"] == null) continue;

        final loc = data["location"] as Map<String, dynamic>;
        final double? lat = (loc["lat"] as num?)?.toDouble();
        final double? lng = (loc["lng"] as num?)?.toDouble();

        if (lat == null || lng == null) continue;

        final String name = (data["username"] ?? "Volunteer").toString();
        final dynamic updatedAt = loc["updatedAt"] ?? "Unknown";

        // 👇 THIS IS THE IMPORTANT PART
        final String userId =
            (data["uid"] as String?) ?? doc.id; // prefer 'uid' field, fallback doc.id

        final markerId = doc.id;

        markers[markerId] = Marker(
          markerId: MarkerId(markerId),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          infoWindow: InfoWindow(
            title: name,
            snippet: "Tap to see details",
          ),
          onTap: () {
            // Debug:
            // print("📍 Marker tapped for userId = $userId");
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

  void dispose() {
    _locationStream?.cancel();
    _volunteerLocationStream?.cancel();
  }
}
