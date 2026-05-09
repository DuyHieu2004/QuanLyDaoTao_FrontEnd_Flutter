// file: lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';

class AuthService {
  // Hàm phụ trợ lấy token
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
        // QUAN TRỌNG: Backend trả về JSON dạng { "token": "..." } nên phải phân tích JSON ra
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String token = responseData['token'];

        // Giải mã token để lấy ID và Role
        int roleId = _extractRoleIdFromToken(token);
        int userId = _extractUserIdFromToken(token);

        // Lưu vào bộ nhớ máy
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setInt('role_id', roleId); 
        await prefs.setInt('user_id', userId); 

        return true;
      }
      return false;
    } catch (e) {
      print("Lỗi kết nối Login: $e");
      return false;
    }
  }

  // --- LẤY USER ID ---
  int _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return 1;

      final payload = parts[1];
      String normalized = base64Url.normalize(payload);
      String resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(resp);

      // Nhìn vào C# của bạn: new Claim("UserId", user.IdTaiKhoan.ToString())
      // Nên ở đây mình chỉ cần gọi đúng chữ "UserId" là ra!
      var idClaim = payloadMap['UserId'];

      if (idClaim != null) {
        return int.tryParse(idClaim.toString()) ?? 1;
      }
      return 1; 
    } catch (e) {
      print("Lỗi giải mã User ID: $e");
      return 1;
    }
  }

  // --- LẤY ROLE ID ---
  int _extractRoleIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return 2;

      final payload = parts[1];
      String normalized = base64Url.normalize(payload);
      String resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(resp);

      // Lấy Role ra
      var roleClaim = payloadMap['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ?? 
                      payloadMap['role'];

      if (roleClaim != null) {
        String roleStr = roleClaim.toString().toLowerCase();
        // Nhìn C#: user.VaiTro!.TenVaiTro (Trúng chữ Giảng viên thì cho là số 3, còn lại là 2 - học viên)
        if (roleStr.contains("giảng viên") || roleStr.contains("giangvien") || roleStr.contains("giang vien")) {
          return 3; 
        }
        return 2; // Học viên
      }
      return 2; 
    } catch (e) {
      print("Lỗi giải mã Role: $e");
      return 2; 
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print("Lỗi kết nối Register: $e");
      return false;
    }
  }

  // --- CHANGE PASSWORD ---
  Future<bool> changePassword(String matKhauCu, String matKhauMoi, String xacNhanMatKhau) async {
    try {
      String? token = await _getToken();
      if (token == null) return false; 

      final response = await http.post(
        Uri.parse(ApiConstants.changePasswordEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $token', 
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
      print("Lỗi kết nối đổi mật khẩu: $e");
      return false;
    }
  }

  // --- LẤY HỒ SƠ ---
  Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/my-profile'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Lỗi lấy hồ sơ: $e");
      return null;
    }
  }

  // --- CẬP NHẬT HỒ SƠ ---
  Future<bool> updateMyProfile(Map<String, dynamic> data) async {
    try {
      String? token = await _getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/my-profile'),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("Lỗi cập nhật hồ sơ: $e");
      return false;
    }
  }

  // --- LOGOUT ---
  Future<bool> logout() async {
    try {
      String? token = await _getToken();

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
      print("Lỗi đăng xuất: $e");
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      await prefs.remove('role_id');
      await prefs.remove('user_id'); 
      return true;
    }
  }
}