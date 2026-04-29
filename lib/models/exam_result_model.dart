// file: lib/models/exam_result_model.dart

class KetQuaThi {
  final int idKetQuaThi;
  final int idLichThi;
  final int idHocVien;
  final String? hoTenHocVien;
  final double diem;
  final String? ketQua;

  KetQuaThi({
    required this.idKetQuaThi,
    required this.idLichThi,
    required this.idHocVien,
    this.hoTenHocVien,
    required this.diem,
    this.ketQua,
  });

  factory KetQuaThi.fromJson(Map<String, dynamic> json) {
    return KetQuaThi(
      idKetQuaThi: json['idKetQuaThi'] ?? 0,
      idLichThi: json['idLichThi'] ?? 0,
      idHocVien: json['idHocVien'] ?? 0,
      hoTenHocVien: json['hoTenHocVien'],
      // Safely parse the score as a double in case the API returns an int or float
      diem: (json['diem'] ?? 0).toDouble(),
      ketQua: json['ketQua'],
    );
  }
}