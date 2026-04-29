// file: lib/services/exam_result_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';
import '../models/exam_result_model.dart';

class ExamResultService {
  // GET: /api/KetQuaThi/by-schedule/{scheduleId}
  Future<List<KetQuaThi>> getResultsBySchedule(int scheduleId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.ketQuaThiEndpoint}/by-schedule/$scheduleId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => KetQuaThi.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching exam results: $e");
      return [];
    }
  }

  // POST: /api/KetQuaThi (Input a new score)
  Future<bool> createResult(int idLichThi, int idHocVien, double diem) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.ketQuaThiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "idLichThi": idLichThi,
          "idHocVien": idHocVien,
          "diem": diem
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error creating result: $e");
      return false;
    }
  }

  // PUT: /api/KetQuaThi/{id} (Update an existing score)
  Future<bool> updateResult(int idKetQuaThi, double diem) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.ketQuaThiEndpoint}/$idKetQuaThi'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "diem": diem
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error updating result: $e");
      return false;
    }
  }
}