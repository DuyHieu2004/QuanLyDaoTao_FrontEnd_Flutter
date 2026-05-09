import 'package:equatable/equatable.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object> get props => [];
}

// Sự kiện yêu cầu lấy danh sách lớp đã đăng ký
class FetchMyRegistrations extends RegistrationEvent {}