import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<bool> activateRoute(String userId, String start, String end, int engineCC) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/routes/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'start_location': start,
          'end_location': end,
          'is_active': true,
          'engine_cc': engineCC
        }),
      );
      return response.statusCode == 200; 
    } catch (e) {
      debugPrint("Error connecting to backend: $e");
      return false;
    }
  }

  static Future<String?> getAIMatch(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/routes/match/$userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ai_analysis'] ?? data['error'];
      }
      return "Server Error ${response.statusCode}";
    } catch (e) {
      return "Critical Error. Is the Python backend running?";
    }
  }

  static Future<Map<String, dynamic>> verifyIDCard(List<int> imageBytes, String filename) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/users/verify/'));
      request.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: filename));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {"is_valid": false, "reason": "Server error"};
    } catch (e) {
      return {"is_valid": false, "reason": "Failed to connect to AI."};
    }
  }

  // --- THE MISSING METHOD FOR THE LIVE METER ---
  static Future<Map<String, dynamic>> getMeteredPrice(int engineCC, double actualDistanceKm) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/routes/meter/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'engine_cc': engineCC,
          'actual_distance_km': actualDistanceKm
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"error": "Server error"};
    } catch (e) {
      debugPrint("Meter Error: $e");
      return {"error": "Failed to connect to meter"};
    }
  }
}