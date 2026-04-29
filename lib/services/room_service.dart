// file: lib/services/room_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';
import '../models/room_model.dart';

class RoomService {

  // GET: /api/PhongThi
  Future<List<PhongThi>> getAllRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.phongThiEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => PhongThi.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching rooms: $e");
      return [];
    }
  }

  // POST: /api/PhongThi
  Future<bool> createRoom(String tenPhong, int soLuong) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.phongThiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "tenPhong": tenPhong,
          "soLuong": soLuong
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error creating room: $e");
      return false;
    }
  }

  // PUT: /api/PhongThi/{id}
  Future<bool> updateRoom(int idPhong, String tenPhong, int soLuong) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.phongThiEndpoint}/$idPhong'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "tenPhong": tenPhong,
          "soLuong": soLuong
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error updating room: $e");
      return false;
    }
  }

  // DELETE: /api/PhongThi/{id}
  Future<bool> deleteRoom(int idPhong) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.phongThiEndpoint}/$idPhong'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error deleting room: $e");
      return false;
    }
  }
}