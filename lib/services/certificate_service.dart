// file: lib/services/certificate_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';
import '../models/certificate_model.dart';

class CertificateService {

  // GET: /api/ChungChi/by-student/{studentId}
  Future<List<ChungChi>> getMyCertificates(int studentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.chungChiEndpoint}/by-student/$studentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => ChungChi.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching certificates: $e");
      return [];
    }
  }
}