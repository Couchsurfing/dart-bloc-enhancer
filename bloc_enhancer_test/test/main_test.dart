/**
--- LICENSE ---
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
--- LICENSE ---
*/
import 'package:test/test.dart';

import 'package:_/lib.dart';

void main() {
  group('$SimpleBloc', () {
    group('State Typing', () {
      test('has all states', () {
        final bloc = SimpleBloc();

        final state = bloc.state;
        expect(state.isLoading, isA<bool>());
        expect(state.isReady, isA<bool>());
        expect(state.isError, isA<bool>());

        expect(state, isA<SimpleState>());

        expect(state.asLoading, isA<SimpleState>());
        expect(() => state.asReady, throwsA(isA()));
        expect(() => state.asError, throwsA(isA()));
      });
    });
  });
}
