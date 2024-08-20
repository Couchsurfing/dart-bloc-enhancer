// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_bloc.dart';

// **************************************************************************
// BlocEnhancerGenerator
// **************************************************************************

class _SimpleBlocEvents {
  const _SimpleBlocEvents(this._bloc);

  final SimpleBloc _bloc;

  void init() {
    if (_bloc.isClosed) return;
    _bloc.add(_Init());
  }

  void create(String name) {
    if (_bloc.isClosed) return;
    _bloc.add(_Create(name));
  }

  void personal() {
    if (_bloc.isClosed) return;
    _bloc.add(_Create.personal());
  }

  void other({required String name}) {
    if (_bloc.isClosed) return;
    _bloc.add(_Create.other(name: name));
  }

  void dude([String name = 'sup']) {
    if (_bloc.isClosed) return;
    _bloc.add(_Create.dude(name));
  }

  void optional([String? name]) {
    if (_bloc.isClosed) return;
    _bloc.add(_Optional(name));
  }

  void req(String name) {
    if (_bloc.isClosed) return;
    _bloc.add(_Optional.req(name));
  }

  void op(String? name) {
    if (_bloc.isClosed) return;
    _bloc.add(_Optional.op(name));
  }

  void no({String? name = 'no'}) {
    if (_bloc.isClosed) return;
    _bloc.add(_Optional.no(name: name));
  }
}

extension $SimpleBlocEventsX on SimpleBloc {
  _SimpleBlocEvents get events => _SimpleBlocEvents(this);
}

extension $SimpleStateTypingX on SimpleState {
  bool get isError => this is _Error;
  bool get isReady => this is _Ready;
  bool get isLoading => this is _Loading;
  _Error get asError => this as _Error;
  _Ready get asReady => this as _Ready;
  _Loading get asLoading => this as _Loading;
}
