import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Saves the current user's location to Firestore ONE TIME (no stream).
  ///
  /// - For normal users: call this once after permission is granted.
  /// - Writes into: users/{uid}.location.{lat,lng,updatedAt}
  static Future<void> saveUserLocationOnce({
    required void Function(String) onError,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      onError("You must be logged in.");
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      onError("Please enable GPS.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    // Request permission if needed
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      onError("Location permission denied.");
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      onError("Location permission permanently denied. Enable it from Settings.");
      return;
    }

    // For users, "whileInUse" is sufficient. No background requirement here.
    // Get one position fix.
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await FirebaseFirestore.instance.collection("users").doc(user.uid).set(
      {
        "location": {
          "lat": position.latitude,
          "lng": position.longitude,
          "updatedAt": FieldValue.serverTimestamp(),
        },
      },
      SetOptions(merge: true),
    );
  }
}
