// file: lib/services/course_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';
import '../models/course_model.dart';

class CourseService {
  // GET: /api/KhoaHoc
  Future<List<KhoaHoc>> getAllCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.khoaHocEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => KhoaHoc.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching courses: $e");
      return [];
    }
  }

  // GET: /api/KhoaHoc/{id}
  Future<KhoaHoc?> getCourseById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.khoaHocEndpoint}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return KhoaHoc.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print("Error fetching course details: $e");
      return null;
    }
  }

  // POST: /api/KhoaHoc
  Future<bool> createCourse(Map<String, dynamic> courseData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.khoaHocEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
        body: jsonEncode(courseData),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error creating course: $e");
      return false;
    }
  }
}