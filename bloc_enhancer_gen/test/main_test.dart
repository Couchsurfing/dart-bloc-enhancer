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
import 'package:bloc_enhancer_gen/bloc_enhancer_gen.dart';
import 'package:bloc_enhancer_gen/gen/settings.dart';
import 'package:generator_test/generator_test.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Generator', () {
    const files = {
      [
        'basic_bloc.dart',
        'basic_event.dart',
        'basic_state.dart',
      ]: ['basic_bloc.dart'],
    };

    for (final file in files.entries) {
      test('runs', () async {
        final tester = SuccessGenerator.fromBuilder(
          file.key,
          file.value,
          blocEnhancerGenerator,
          onLog: print,
          logLevel: Level.ALL,
          options: Settings.defaults().toJson(),
          partOfFile: 'basic_bloc.bloc_enhancer_gen.g.part',
        );

        await tester.test();
      });
    }
  });
}
