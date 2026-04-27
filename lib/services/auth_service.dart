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
        String token = response.body;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        return true;
      }
      return false;
    } catch (e) {
      print("Login connection error: $e");
      return false;
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