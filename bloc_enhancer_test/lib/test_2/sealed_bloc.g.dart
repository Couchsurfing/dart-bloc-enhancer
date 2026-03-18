// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sealed_bloc.dart';

// **************************************************************************
// BlocEnhancerGenerator
// **************************************************************************

class _SealedBlocEvents {
  const _SealedBlocEvents(this._bloc);

  final SealedBloc _bloc;

  void load() {
    if (_bloc.isClosed) return;
    _bloc.add(_Load());
  }

  void edit(String id) {
    if (_bloc.isClosed) return;
    _bloc.add(_Edit(id));
  }
}

extension $SealedBlocEventsX on SealedBloc {
  _SealedBlocEvents get events => _SealedBlocEvents(this);
}

/// Intended for **_TESTING_** only — avoid using in production.
class _$SealedBlocEventCreator {
  const _$SealedBlocEventCreator();

  _Load load() => _Load();

  _Edit edit(String id) => _Edit(id);
}

extension $SealedBlocStateTypingX on SealedBlocState {
  bool get isLoading => this is _Loading;

  _Loading get asLoading => this as _Loading;

  _Loading? get asIfLoading => this is _Loading ? this as _Loading : null;

  bool get isError => this is _Error;

  _Error get asError => this as _Error;

  _Error? get asIfError => this is _Error ? this as _Error : null;

  bool get isReady => this is _Ready;

  _Ready get asReady => this as _Ready;

  _Ready? get asIfReady => this is _Ready ? this as _Ready : null;

  bool get isIdle => this is _Idle;

  _Idle get asIdle => this as _Idle;

  _Idle? get asIfIdle => this is _Idle ? this as _Idle : null;

  bool get isEditing => this is _Editing;

  _Editing get asEditing => this as _Editing;

  _Editing? get asIfEditing => this is _Editing ? this as _Editing : null;
}
