// file: lib/models/instructor_model.dart

class GiangVien {
  final int idGiangVien;
  final String hoTenGv;
  final String? chuyenMon;
  final String? dienThoaiGv;
  final String? emailGv;
  final double phiGiangDay;

  GiangVien({
    required this.idGiangVien,
    required this.hoTenGv,
    this.chuyenMon,
    this.dienThoaiGv,
    this.emailGv,
    required this.phiGiangDay,
  });

  factory GiangVien.fromJson(Map<String, dynamic> json) {
    return GiangVien(
      idGiangVien: json['idGiangVien'] ?? 0,
      hoTenGv: json['hoTenGv'] ?? '',
      chuyenMon: json['chuyenMon'],
      dienThoaiGv: json['dienThoaiGv'],
      emailGv: json['emailGv'],
      phiGiangDay: (json['phiGiangDay'] ?? 0).toDouble(),
    );
  }
}