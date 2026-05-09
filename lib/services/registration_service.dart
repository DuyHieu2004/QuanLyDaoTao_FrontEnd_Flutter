import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';

class RegistrationService {
  int _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return 0;
      final payload = parts[1];
      String normalized = base64Url.normalize(payload);
      String resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(resp);

      var idClaim = payloadMap['nameid'] ??
          payloadMap['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
          payloadMap['IdHocVien'] ??
          payloadMap['IdNguoiDung'] ??
          payloadMap['id'];

      if (idClaim != null) {
        return int.tryParse(idClaim.toString()) ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, dynamic>> registerForClass(int idLop) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    final int idHocVien = _extractUserIdFromToken(token);

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.registerClassEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
        body: jsonEncode({
          "idLopHoc": idLop,
          "idHocVien": idHocVien,
        }),
      );

      // Check if registration was successful (usually 200 OK or 201 Created)
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'idDangKy': data['idDangKy'] ?? 0,
        };
      } else {
        print("Registration failed: ${response.body}");
        return {
          'success': false,
        };
      }
    } catch (e) {
      print("Connection error during registration: $e");
      return {
        'success': false,
      };
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