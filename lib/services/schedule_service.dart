import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';

class ScheduleService {
  Future<Map<String, dynamic>> getMyWeekSchedule(DateTime date, {String type = 'all'}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) throw Exception('No token found');

    final isoDate = "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final url = Uri.parse('${ApiConstants.baseUrl}/api/Schedule/my-week?date=$isoDate&type=$type');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load schedule: ${response.statusCode}');
    }
  }
}
