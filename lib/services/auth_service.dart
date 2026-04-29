// file: lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';

class AuthService {
  // Helper method to get the saved JWT token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // --- LOGIN ---
  Future<bool> login(String tenDangNhap, String matKhau) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode({
          "tenDangNhap": tenDangNhap,
          "matKhau": matKhau,
        }),
      );

      if (response.statusCode == 200) {
        // 1. Get the token string
        String token = response.body;

        // 2. Decode the token to get the user claims (like the role)
        int roleId = _extractRoleIdFromToken(token);

        // 3. Save BOTH to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setInt('role_id', roleId); // The HomeScreen needs this!

        return true;
      }
      return false;
    } catch (e) {
      print("Login connection error: $e");
      return false;
    }
  }

  // --- HELPER METHOD TO DECODE JWT ---
  int _extractRoleIdFromToken(String token) {
    try {
      // JWTs have 3 parts separated by dots. The payload is the middle part.
      final parts = token.split('.');
      if (parts.length != 3) {
        return 2; // Default to HocVien (Student) if token is weird
      }

      final payload = parts[1];

      // Base64Url decoding requires padding handling
      String normalized = base64Url.normalize(payload);
      String resp = utf8.decode(base64Url.decode(normalized));

      final payloadMap = jsonDecode(resp);

      // Extract the role.
      // Note: .NET often uses long URI strings for roles. You might need to adjust this key.
      // Common .NET keys are 'role', 'roles', or 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'
      var roleClaim = payloadMap['role'] ??
          payloadMap['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
          payloadMap['IdVaiTro']; // Add your specific key if you know it

      if (roleClaim != null) {
        // Convert it to an int (in case it comes through as a String like "3")
        return int.tryParse(roleClaim.toString()) ?? 2;
      }

      return 2; // Default to Student
    } catch (e) {
      print("Error decoding token: $e");
      return 2; // Default to Student on error
    }
  }

  // --- REGISTER ---
  Future<bool> register(String tenDangNhap, String matKhau, String hoTen, String email, String dienThoai) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.registerEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode({
          "tenDangNhap": tenDangNhap,
          "matKhau": matKhau,
          "hoTen": hoTen,
          "email": email,
          "dienThoai": dienThoai
        }),
      );

      // Assuming your backend returns 200 OK or 201 Created on success
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print("Register connection error: $e");
      return false;
    }
  }

  // --- CHANGE PASSWORD ---
  Future<bool> changePassword(String matKhauCu, String matKhauMoi, String xacNhanMatKhau) async {
    try {
      String? token = await _getToken();
      if (token == null) return false; // Not logged in

      final response = await http.post(
        Uri.parse(ApiConstants.changePasswordEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $token', // Attach JWT token for secure access
        },
        body: jsonEncode({
          "matKhauCu": matKhauCu,
          "matKhauMoi": matKhauMoi,
          "xacNhanMatKhau": xacNhanMatKhau
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("Change password connection error: $e");
      return false;
    }
  }

  // --- LOGOUT ---
  Future<bool> logout() async {
    try {
      String? token = await _getToken();

      // If the backend requires a token to blacklist it on logout:
      if (token != null) {
        await http.post(
          Uri.parse(ApiConstants.logoutEndpoint),
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
          },
        );
      }

    } catch (e) {
      print("Logout error: $e");

      // Still remove the token locally even if the server connection fails

    }
    finally{
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      return true;
    }
  }
}