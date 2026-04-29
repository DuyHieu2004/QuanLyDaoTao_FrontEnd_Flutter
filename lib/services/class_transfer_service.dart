// file: lib/services/class_transfer_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';
import '../models/class_transfer_model.dart';

class ClassTransferService {

  // INSTRUCTOR: Get all pending requests
  Future<List<ClassTransfer>> getPendingTransfers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.chuyenLopEndpoint}/status/pending'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => ClassTransfer.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching pending transfers: $e");
      return [];
    }
  }

  // INSTRUCTOR: Approve a transfer
  Future<bool> approveTransfer(int id, String approverName, String note) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.chuyenLopEndpoint}/$id/approve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "nguoiPheDuyet": approverName,
          "ghiChu": note
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error approving transfer: $e");
      return false;
    }
  }

  // INSTRUCTOR: Reject a transfer
  Future<bool> rejectTransfer(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.chuyenLopEndpoint}/$id/reject'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error rejecting transfer: $e");
      return false;
    }
  }
}