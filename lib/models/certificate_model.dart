// file: lib/models/certificate_model.dart

class ChungChi {
  final int idChungChi;
  final int idHocVien;
  final String? hoTenHocVien;
  final int idKhoaHoc;
  final String? tenKhoaHoc;
  final DateTime? ngayCap;

  ChungChi({
    required this.idChungChi,
    required this.idHocVien,
    this.hoTenHocVien,
    required this.idKhoaHoc,
    this.tenKhoaHoc,
    this.ngayCap,
  });

  factory ChungChi.fromJson(Map<String, dynamic> json) {
    return ChungChi(
      idChungChi: json['idChungChi'] ?? 0,
      idHocVien: json['idHocVien'] ?? 0,
      hoTenHocVien: json['hoTenHocVien'],
      idKhoaHoc: json['idKhoaHoc'] ?? 0,
      tenKhoaHoc: json['tenKhoaHoc'],
      ngayCap: json['ngayCap'] != null ? DateTime.parse(json['ngayCap']) : null,
    );
  }
}