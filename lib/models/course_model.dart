// file: lib/models/course_model.dart

import 'class_model.dart';

class KhoaHoc {
  final int idKhoaHoc;
  final String tenKhoaHoc;
  final int thoiLuong;
  final int hocPhi;
  final String? moTa;
  final String? anhDaiDien;
  final String? moTaChiTiet;
  final String? doiTuong;
  final String? loTrinh;
  final String? camKet;
  final String? yeuCauDauVao;
  final DateTime? ngayBatDau;
  final DateTime? ngayKetThuc;
  final String? trangThai;
  final List<LopHoc>? lopHocs; // Nested classes from GET by ID

  KhoaHoc({
    required this.idKhoaHoc,
    required this.tenKhoaHoc,
    required this.thoiLuong,
    required this.hocPhi,
    this.moTa,
    this.anhDaiDien,
    this.moTaChiTiet,
    this.doiTuong,
    this.loTrinh,
    this.camKet,
    this.yeuCauDauVao,
    this.ngayBatDau,
    this.ngayKetThuc,
    this.trangThai,
    this.lopHocs,
  });

  factory KhoaHoc.fromJson(Map<String, dynamic> json) {
    var list = json['lopHocs'] as List?;
    List<LopHoc>? lopHocsList;
    if (list != null) {
      lopHocsList = list.map((i) => LopHoc.fromJson(i)).toList();
    }

    return KhoaHoc(
      idKhoaHoc: json['idKhoaHoc'] ?? 0,
      tenKhoaHoc: json['tenKhoaHoc'] ?? '',
      thoiLuong: json['thoiLuong'] ?? 0,
      hocPhi: json['hocPhi'] ?? 0,
      moTa: json['moTa'],
      anhDaiDien: json['anhDaiDien'],
      moTaChiTiet: json['moTaChiTiet'],
      doiTuong: json['doiTuong'],
      loTrinh: json['loTrinh'],
      camKet: json['camKet'],
      yeuCauDauVao: json['yeuCauDauVao'],
      ngayBatDau: json['ngayBatDau'] != null ? DateTime.parse(json['ngayBatDau']) : null,
      ngayKetThuc: json['ngayKetThuc'] != null ? DateTime.parse(json['ngayKetThuc']) : null,
      trangThai: json['trangThai'],
      lopHocs: lopHocsList,
    );
  }
}