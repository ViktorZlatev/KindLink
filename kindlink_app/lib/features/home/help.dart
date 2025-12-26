import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';

class HelpRequestService {
  static Future<String> sendImmediateHelpRequest({
    required Function(String) onError,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      onError("You must be logged in to request help.");
      throw Exception("Not logged in");
    }

    try {
      final userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userSnap.data() ?? {};

      final resume = (userData['survey'] is Map<String, dynamic>)
          ? Map<String, dynamic>.from(userData['survey'])
          : <String, dynamic>{};

      // 1) Create help request
      final docRef =
          await FirebaseFirestore.instance.collection('help_requests').add({
        'userId': user.uid,
        'username': userData['username'] ?? user.email,
        'location': userData['location'], // may be null
        'resume': resume,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'open',
      });

      final requestId = docRef.id;

      // 2) Call callable Cloud Function (auth is required; SDK includes token automatically)
      final callable = FirebaseFunctions.instance.httpsCallable(
        'rankHelpRequest',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
      );

      await callable.call({'requestId': requestId});

      return requestId;
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint("Cloud Function error: ${e.code} ${e.message} ${e.details}");
      debugPrintStack(stackTrace: st);
      onError(e.message ?? "Failed to rank volunteers.");
      rethrow;
    } catch (e, st) {
      debugPrint("Error sending help request: $e");
      debugPrintStack(stackTrace: st);
      onError("Failed to send help request.");
      rethrow;
    }
  }
}
