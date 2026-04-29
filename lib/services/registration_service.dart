import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';

class RegistrationService {
  Future<bool> registerForClass(int idLop) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.registerClassEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
        body: jsonEncode({
          "idLop": idLop
        }),
      );

      // Check if registration was successful (usually 200 OK or 201 Created)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Registration failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Connection error during registration: $e");
      return false;
    }
  }

  // Add this inside RegistrationService
  Future<List<dynamic>> getMyRegistrations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.dangKyEndpoint}/my-registrations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetching registrations: $e");
      return [];
    }
  }
}