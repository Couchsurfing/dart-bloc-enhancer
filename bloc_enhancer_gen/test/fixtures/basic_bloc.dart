/**
Copyright 2024 CouchSurfing International Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 */
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
