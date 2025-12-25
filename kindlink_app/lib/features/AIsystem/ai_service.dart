import 'dart:convert';
import 'package:http/http.dart' as http;

class AIDispatchService {
  static const String _baseUrl = "http://192.168.100.249:5000";

  // --------------------------------------------------
  // CALL AI TO RANK VOLUNTEERS
  // --------------------------------------------------
  static Future<void> rankHelpRequest(String requestId) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/rank"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"requestId": requestId}),
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Failed to call AI ranking service: ${response.body}");
    }
  }

  // --------------------------------------------------
  // ADVANCE TO NEXT VOLUNTEER AFTER REJECT
  // --------------------------------------------------
  static Future<void> advanceVolunteer(String requestId) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/advance"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"requestId": requestId}),
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Failed to advance volunteer: ${response.body}");
    }
  }
}
