import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/registration_service.dart';
import 'registration_event.dart';
import 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final RegistrationService registrationService;

  RegistrationBloc({required this.registrationService}) : super(RegistrationInitial()) {
    on<FetchMyRegistrations>(_onFetchMyRegistrations);
  }

  Future<void> _onFetchMyRegistrations(
    FetchMyRegistrations event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(RegistrationLoading());
    try {
      // Gọi api từ service của bạn
      final data = await registrationService.getMyRegistrations();
      emit(RegistrationLoaded(data));
    } catch (e) {
      emit(RegistrationError("Lỗi khi tải danh sách đăng ký: ${e.toString()}"));
    }
  }
}