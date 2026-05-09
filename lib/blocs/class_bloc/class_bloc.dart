import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/class_service.dart';
import 'class_event.dart';
import 'class_state.dart';

class ClassBloc extends Bloc<ClassEvent, ClassState> {
  final ClassService classService;

  ClassBloc({required this.classService}) : super(ClassInitial()) {
    on<FetchAvailableClasses>(_onFetchAvailableClasses);
  }

  Future<void> _onFetchAvailableClasses(
    FetchAvailableClasses event,
    Emitter<ClassState> emit,
  ) async {
    emit(ClassLoading()); // Phát trạng thái đang tải
    try {
      // Gọi service để lấy dữ liệu
      final classes = await classService.getAvailableClasses(event.idHocVien);
      if (classes.isEmpty) {
        // Nếu không có lớp nào
        emit(const ClassLoaded([])); 
      } else {
        // Có dữ liệu thì ném ra cho UI
        emit(ClassLoaded(classes));
      }
    } catch (e) {
      emit(ClassError(e.toString()));
    }
  }
}