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
import 'package:equatable/equatable.dart';

part 'simple_bloc.g.dart';
part 'simple_event.dart';
part 'simple_state.dart';

class SimpleBloc extends Bloc<SimpleEvent, SimpleState> {
  SimpleBloc() : super(_Loading()) {
    on<SimpleEvent>((event, emit) {});
  }
}
