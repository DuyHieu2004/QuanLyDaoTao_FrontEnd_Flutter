// file: lib/api_constants.dart

class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:5025';

  static const String authEndpoint = '$baseUrl/api/Auth';
  static const String loginEndpoint = '$authEndpoint/login';
  static const String registerEndpoint = '$authEndpoint/register';
  static const String changePasswordEndpoint = '$authEndpoint/change-password';
  static const String logoutEndpoint = '$authEndpoint/logout';
}