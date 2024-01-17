import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'basic_event.dart';
part 'basic_state.dart';

class SimpleBloc extends Bloc<SimpleEvent, SimpleState> {
  SimpleBloc() : super(_Initial()) {
    on<SimpleEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
