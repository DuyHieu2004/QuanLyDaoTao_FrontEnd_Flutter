// file: lib/models/class_transfer_model.dart

class ClassTransfer {
  final int idChuyenLop;
  final int idHocVien;
  final int idLopCu;
  final int idLopMoi;
  final DateTime? ngayChuyenLop;
  final String? lyDo;
  final String? nguoiPheDuyet;
  final String? trangThai;
  final String? hoTenHocVien;
  final String? tenLopCu;
  final String? tenLopMoi;

  ClassTransfer({
    required this.idChuyenLop,
    required this.idHocVien,
    required this.idLopCu,
    required this.idLopMoi,
    this.ngayChuyenLop,
    this.lyDo,
    this.nguoiPheDuyet,
    this.trangThai,
    this.hoTenHocVien,
    this.tenLopCu,
    this.tenLopMoi,
  });

  factory ClassTransfer.fromJson(Map<String, dynamic> json) {
    return ClassTransfer(
      idChuyenLop: json['idChuyenLop'] ?? 0,
      idHocVien: json['idHocVien'] ?? 0,
      idLopCu: json['idLopCu'] ?? 0,
      idLopMoi: json['idLopMoi'] ?? 0,
      ngayChuyenLop: json['ngayChuyenLop'] != null ? DateTime.parse(json['ngayChuyenLop']) : null,
      lyDo: json['lyDo'],
      nguoiPheDuyet: json['nguoiPheDuyet'],
      trangThai: json['trangThai'],
      hoTenHocVien: json['hoTenHocVien'],
      tenLopCu: json['tenLopCu'],
      tenLopMoi: json['tenLopMoi'],
    );
  }
}