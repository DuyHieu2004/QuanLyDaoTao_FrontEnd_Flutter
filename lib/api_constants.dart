// file: lib/api_constants.dart

class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:5025';

  static const String authEndpoint = '$baseUrl/api/Auth';
  static const String loginEndpoint = '$authEndpoint/login';
  static const String registerEndpoint = '$authEndpoint/register';
  static const String changePasswordEndpoint = '$authEndpoint/change-password';
  static const String logoutEndpoint = '$authEndpoint/logout';
  static const String lopHocEndpoint = '$baseUrl/api/LopHoc';
  static const String khoaHocEndpoint = '$baseUrl/api/KhoaHoc';
  static const String dangKyEndpoint = '$baseUrl/api/DangKy';
  static const String registerClassEndpoint = '$dangKyEndpoint/register';
  static const String ketQuaThiEndpoint = '$baseUrl/api/KetQuaThi';
  static const String ketQuaHocTapEndpoint = '$baseUrl/api/KetQuaHocTap';
  static const String phongThiEndpoint = '$baseUrl/api/PhongThi';
  static const String thanhToanEndpoint = '$baseUrl/api/ThanhToan';
  static const String giangVienEndpoint = '$baseUrl/api/GiangVien';
  static const String chuyenLopEndpoint = '$baseUrl/api/ChuyenLop';
  static const String chungChiEndpoint = '$baseUrl/api/ChungChi';
}