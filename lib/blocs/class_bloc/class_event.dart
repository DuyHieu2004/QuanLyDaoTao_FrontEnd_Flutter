import 'package:equatable/equatable.dart';

abstract class ClassEvent extends Equatable {
  const ClassEvent();

  @override
  List<Object> get props => [];
}

// Sự kiện yêu cầu tải danh sách lớp CHƯA đăng ký
class FetchAvailableClasses extends ClassEvent {
  final int idHocVien;

  const FetchAvailableClasses({required this.idHocVien});

  @override
  List<Object> get props => [idHocVien];
}