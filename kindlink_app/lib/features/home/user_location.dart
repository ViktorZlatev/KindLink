import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  
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
