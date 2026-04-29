// file: lib/models/study_result_model.dart

class StudyResult {
  final int idKetQua;
  final int idDangKy;
  final String? hocVienName;
  final String? courseName;
  final String? className;
  final double diemChuyenCan;
  final double diemThi;
  final double diemTrungBinh;
  final String? ketLuan;
  final String? trangThaiHoc;

  StudyResult({
    required this.idKetQua,
    required this.idDangKy,
    this.hocVienName,
    this.courseName,
    this.className,
    required this.diemChuyenCan,
    required this.diemThi,
    required this.diemTrungBinh,
    this.ketLuan,
    this.trangThaiHoc,
  });

  factory StudyResult.fromJson(Map<String, dynamic> json) {
    return StudyResult(
      idKetQua: json['idKetQua'] ?? 0,
      idDangKy: json['idDangKy'] ?? 0,
      hocVienName: json['hocVienName'],
      courseName: json['courseName'],
      className: json['className'],
      diemChuyenCan: (json['diemChuyenCan'] ?? 0).toDouble(),
      diemThi: (json['diemThi'] ?? 0).toDouble(),
      diemTrungBinh: (json['diemTrungBinh'] ?? 0).toDouble(),
      ketLuan: json['ketLuan'],
      trangThaiHoc: json['trangThaiHoc'],
    );
  }
}

class ClassStatistics {
  final int totalStudents;
  final int passed;
  final int failed;
  final double passRate;
  final double averageScore;
  final double highestScore;
  final double lowestScore;

  ClassStatistics({
    required this.totalStudents,
    required this.passed,
    required this.failed,
    required this.passRate,
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
  });

  factory ClassStatistics.fromJson(Map<String, dynamic> json) {
    return ClassStatistics(
      totalStudents: json['totalStudents'] ?? 0,
      passed: json['passed'] ?? 0,
      failed: json['failed'] ?? 0,
      passRate: (json['passRate'] ?? 0).toDouble(),
      averageScore: (json['averageScore'] ?? 0).toDouble(),
      highestScore: (json['highestScore'] ?? 0).toDouble(),
      lowestScore: (json['lowestScore'] ?? 0).toDouble(),
    );
  }
}