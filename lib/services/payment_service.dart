// file: lib/services/payment_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';
import '../models/payment_model.dart';

class PaymentService {
  // GET: /api/ThanhToan/{idDangKy}
  Future<ThanhToanModel?> getPaymentInfo(int idDangKy) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.thanhToanEndpoint}/$idDangKy'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return ThanhToanModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print("Error fetching payment info: $e");
      return null;
    }
  }

  // POST: /api/ThanhToan/{idDangKy}/confirm-payment
  Future<bool> confirmPayment(int idDangKy, String hinhThuc, String ghiChu) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.thanhToanEndpoint}/$idDangKy/confirm-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "hinhThucThanhToan": hinhThuc,
          "ghiChu": ghiChu
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error confirming payment: $e");
      return false;
    }
  }

  // POST: /api/ThanhToan/{idDangKy}/refund
  Future<bool> requestRefund(int idDangKy) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.thanhToanEndpoint}/$idDangKy/refund'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error requesting refund: $e");
      return false;
    }
  }
}