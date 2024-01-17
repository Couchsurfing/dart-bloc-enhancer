import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'simple_bloc.g.dart';
part 'simple_event.dart';
part 'simple_state.dart';

class SimpleBloc extends Bloc<SimpleEvent, SimpleState> {
  SimpleBloc() : super(_Loading()) {
    on<SimpleEvent>((event, emit) {});
  }
}
