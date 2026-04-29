// file: lib/models/class_model.dart

class LopHoc {
  final int idLop;
  final String tenLop;
  final int idKhoaHoc;
  final DateTime ngayBatDau;
  final DateTime ngayKetThuc;
  final int siSoToiDa;
  final int soHocVienDangKy;
  final int soChoConLai;
  final bool allowDangKy;
  final String? trangThai;
  final String? ghiChu;

  LopHoc({
    required this.idLop,
    required this.tenLop,
    required this.idKhoaHoc,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.siSoToiDa,
    required this.soHocVienDangKy,
    required this.soChoConLai,
    required this.allowDangKy,
    this.trangThai,
    this.ghiChu,
  });

  factory LopHoc.fromJson(Map<String, dynamic> json) {
    return LopHoc(
      idLop: json['idLop'] ?? 0,
      tenLop: json['tenLop'] ?? '',
      idKhoaHoc: json['idKhoaHoc'] ?? 0,
      ngayBatDau: DateTime.parse(json['ngayBatDau']),
      ngayKetThuc: DateTime.parse(json['ngayKetThuc']),
      siSoToiDa: json['siSoToiDa'] ?? 0,
      soHocVienDangKy: json['soHocVienDangKy'] ?? 0,
      soChoConLai: json['soChoConLai'] ?? 0,
      allowDangKy: json['allowDangKy'] ?? false,
      trangThai: json['trangThai'],
      ghiChu: json['ghiChu'],
    );
  }
}