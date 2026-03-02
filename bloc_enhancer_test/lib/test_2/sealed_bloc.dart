// --- LICENSE ---
/**
Copyright 2026 CouchSurfing International Inc.

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
// --- LICENSE ---
import 'package:bloc/bloc.dart';

part 'sealed_bloc.g.dart';
part 'sealed_event.dart';
part 'sealed_state.dart';

class SealedBloc extends Bloc<SealedBlocEvent, SealedBlocState> {
  SealedBloc() : super(const _Loading()) {
    on<_Load>((event, emit) => emit(const _Idle(data: 'test')));
    on<_Edit>((event, emit) {
      final state = this.state;
      if (state.asIfReady case final ready?) {
        emit(_Editing(data: ready.data, editingId: event.id));
      }
    });
  }
}
