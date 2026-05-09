import 'package:equatable/equatable.dart';
import '../../models/class_model.dart';

abstract class ClassState extends Equatable {
  const ClassState();
  
  @override
  List<Object> get props => [];
}

class ClassInitial extends ClassState {}

class ClassLoading extends ClassState {}

class ClassLoaded extends ClassState {
  final List<LopHoc> classes;

  const ClassLoaded(this.classes);

  @override
  List<Object> get props => [classes];
}

class ClassError extends ClassState {
  final String message;

  const ClassError(this.message);

  @override
  List<Object> get props => [message];
}