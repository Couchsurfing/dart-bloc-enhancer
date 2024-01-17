part of 'simple_bloc.dart';

class SimpleEvent extends Equatable {
  const SimpleEvent();

  @override
  List<Object> get props => [];
}

class _Init extends SimpleEvent {
  const _Init();
}

class _Create extends SimpleEvent {
  const _Create(this.name);
  const _Create.personal() : name = '';
  const _Create.other({required this.name});
  const _Create.dude([this.name = 'sup']);

  final String name;
}

class _Optional extends SimpleEvent {
  const _Optional([this.name]);
  const _Optional.req(String this.name);
  const _Optional.op(this.name);
  const _Optional.no({this.name = 'no'});

  final String? name;
}
