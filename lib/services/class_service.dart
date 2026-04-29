import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';
import '../models/class_model.dart';

class ClassService {

  // 1. GET /api/LopHoc/by-course/{idKhoaHoc}
  Future<List<LopHoc>> getClassesByCourse(int idKhoaHoc) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.lopHocEndpoint}/by-course/$idKhoaHoc'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => LopHoc.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching by course: $e");
      return [];
    }
  }

// 2. GET /api/LopHoc/{id}
  Future<LopHoc?> getClassById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.lopHocEndpoint}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return LopHoc.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print("Error fetching class details: $e");
      return null;
    }
  }

// 3. GET /api/LopHoc/khoaHoc/{id}
// Based on your image d5df94, this specifically gets class info linked to a KhoaHoc ID
  Future<LopHoc?> getLopHocByKhoaHoc(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.lopHocEndpoint}/khoaHoc/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return LopHoc.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print("Error fetching by khoaHoc: $e");
      return null;
    }
  }

  Future<List<LopHoc>> getAllClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.lopHocEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => LopHoc.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load classes");
      }
    } catch (e) {
      print("Error fetching classes: $e");
      return [];
    }
  }

  Future<bool> createClass({
    required String tenLop,
    required int idKhoaHoc,
    required DateTime ngayBatDau,
    required DateTime ngayKetThuc,
    required int siSoToiDa,
    required bool allowDangKy,
    String? ghiChu,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.lopHocEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
        body: jsonEncode({
          "tenLop": tenLop,
          "idKhoaHoc": idKhoaHoc,
          "ngayBatDau": ngayBatDau.toIso8601String(),
          "ngayKetThuc": ngayKetThuc.toIso8601String(),
          "siSoToiDa": siSoToiDa,
          "allowDangKy": allowDangKy,
          "ghiChu": ghiChu ?? "",
        }),
      );

      // Check for 200 OK or 201 Created based on your .NET implementation
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Server Error: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Connection Error: $e");
      return false;
    }
  }

}