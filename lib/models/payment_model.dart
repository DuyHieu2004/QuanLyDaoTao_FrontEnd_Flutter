// file: lib/models/payment_model.dart

class ThanhToanModel {
  final int idThanhToan;
  final int idDangKy;
  final double soTien;
  final String? hinhThucThanhToan;
  final String? trangThaiThanhToan;
  final DateTime? ngayTao;
  final DateTime? ngayThanhToan;
  final String? ghiChu;

  ThanhToanModel({
    required this.idThanhToan,
    required this.idDangKy,
    required this.soTien,
    this.hinhThucThanhToan,
    this.trangThaiThanhToan,
    this.ngayTao,
    this.ngayThanhToan,
    this.ghiChu,
  });

  factory ThanhToanModel.fromJson(Map<String, dynamic> json) {
    return ThanhToanModel(
      idThanhToan: json['idThanhToan'] ?? 0,
      idDangKy: json['idDangKy'] ?? 0,
      soTien: (json['soTien'] ?? 0).toDouble(),
      hinhThucThanhToan: json['hinhThucThanhToan'],
      trangThaiThanhToan: json['trangThaiThanhToan'],
      ngayTao: json['ngayTao'] != null ? DateTime.parse(json['ngayTao']) : null,
      ngayThanhToan: json['ngayThanhToan'] != null ? DateTime.parse(json['ngayThanhToan']) : null,
      ghiChu: json['ghiChu'],
    );
  }
}