// file: lib/services/study_result_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';
import '../models/study_result_model.dart';

class StudyResultService {

  // 1. Get List of Results by Class ID
  Future<List<StudyResult>> getResultsByClass(int classId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.ketQuaHocTapEndpoint}/by-class/$classId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => StudyResult.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching study results: $e");
      return [];
    }
  }

  // 2. Get Class Statistics
  Future<ClassStatistics?> getClassStatistics(int classId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.ketQuaHocTapEndpoint}/statistics/by-class/$classId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return ClassStatistics.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print("Error fetching statistics: $e");
      return null;
    }
  }

  // 3. Create or Update Result (Assuming you edit existing registrations)
  // Your Swagger shows PUT /api/KetQuaHocTap/{id} takes diemChuyenCan and diemThi
  Future<bool> updateResult(int idKetQua, double diemChuyenCan, double diemThi) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.ketQuaHocTapEndpoint}/$idKetQua'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "diemChuyenCan": diemChuyenCan,
          "diemThi": diemThi
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error updating result: $e");
      return false;
    }
  }
}