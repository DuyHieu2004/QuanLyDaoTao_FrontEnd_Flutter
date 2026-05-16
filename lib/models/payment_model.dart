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
      idThanhToan: int.tryParse((json['idThanhToan'] ?? 0).toString()) ?? 0,
      idDangKy: int.tryParse((json['idDangKy'] ?? 0).toString()) ?? 0,
      soTien: double.tryParse((json['soTien'] ?? 0).toString()) ?? 0.0,
      hinhThucThanhToan: json['hinhThucThanhToan'],
      trangThaiThanhToan: json['trangThaiThanhToan'],
      ngayTao: json['ngayTao'] != null ? DateTime.parse(json['ngayTao']) : null,
      ngayThanhToan: json['ngayThanhToan'] != null ? DateTime.parse(json['ngayThanhToan']) : null,
      ghiChu: json['ghiChu'],
    );
  }
}