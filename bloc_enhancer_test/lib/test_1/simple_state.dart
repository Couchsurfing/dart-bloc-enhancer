part of 'simple_bloc.dart';

class SimpleState extends Equatable {
  const SimpleState();

  @override
  List<Object> get props => [];
}

class _Error extends SimpleState {
  const _Error(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

class _Ready extends SimpleState {
  const _Ready();
}

class _Loading extends SimpleState {
  const _Loading();
}
