// file: lib/services/instructor_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';
import '../models/instructor_model.dart';

class InstructorService {

  // GET: /api/GiangVien
  Future<List<GiangVien>> getAllInstructors() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.giangVienEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => GiangVien.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching instructors: $e");
      return [];
    }
  }

  // POST: /api/GiangVien
  Future<bool> createInstructor(String hoTen, String chuyenMon, String dienThoai, String email, double phi) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.giangVienEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "hoTenGv": hoTen,
          "chuyenMon": chuyenMon,
          "dienThoaiGv": dienThoai,
          "emailGv": email,
          "phiGiangDay": phi
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error creating instructor: $e");
      return false;
    }
  }

  // PUT: /api/GiangVien/{id}
  Future<bool> updateInstructor(int id, String hoTen, String chuyenMon, String dienThoai, String email, double phi) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.giangVienEndpoint}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "hoTenGv": hoTen,
          "chuyenMon": chuyenMon,
          "dienThoaiGv": dienThoai,
          "emailGv": email,
          "phiGiangDay": phi
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error updating instructor: $e");
      return false;
    }
  }

  // DELETE: /api/GiangVien/{id}
  Future<bool> deleteInstructor(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.giangVienEndpoint}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error deleting instructor: $e");
      return false;
    }
  }
}