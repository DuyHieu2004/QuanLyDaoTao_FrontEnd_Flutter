// file: lib/models/room_model.dart

class PhongThi {
  final int idPhong;
  final String tenPhong;
  final int soLuong; // Capacity

  PhongThi({
    required this.idPhong,
    required this.tenPhong,
    required this.soLuong,
  });

  factory PhongThi.fromJson(Map<String, dynamic> json) {
    return PhongThi(
      idPhong: json['idPhong'] ?? 0,
      tenPhong: json['tenPhong'] ?? '',
      soLuong: json['soLuong'] ?? 0,
    );
  }
}