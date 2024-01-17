// @generator=BlocEnhancerGenerator
class _Events {
  const _Events(this._bloc);

  final SimpleBloc _bloc;

  void init() {
    _bloc.add(_Init());
  }
}

extension SimpleBlocX on SimpleBloc {
  _Events get events => _Events(this);
}

extension SimpleStateX on SimpleState {
  bool get isInitial => this is _Initial;
  _Initial get asInitial => this as _Initial;
}
