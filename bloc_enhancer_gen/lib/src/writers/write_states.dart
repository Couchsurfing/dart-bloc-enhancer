// --- LICENSE ---
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
import 'package:bloc_enhancer_gen/src/models/bloc_element.dart';
import 'package:bloc_enhancer_gen/src/models/state_element.dart';
import 'package:bloc_enhancer_gen/src/writers/write_factory.dart';
import 'package:change_case/change_case.dart';
import 'package:code_builder/code_builder.dart';

List<Spec> writeStates(List<BlocElement> blocs) {
  final extensions = blocs.map(_writeTypingExtension).toList();

  final creatorClasses = WriteFactory.write(
    blocs.where((e) => e.shouldCreateStateFactory),
    (e) => e.state,
    (e) => e.states,
  );

  return [
    ...extensions,
    ...creatorClasses,
  ];
}

Extension _writeTypingExtension(BlocElement bloc) {
  final extension = Extension(
    (b) => b
      ..name = '\$${bloc.state.name}TypingX'
      ..on = refer(bloc.state.name)
      ..methods.addAll([
        ...bloc.states.map(_writeIsStateMethod),
        ...bloc.states.map(_writeAsStateMethod),
      ]),
  );

  return extension;
}

Method _writeIsStateMethod(StateElement state) {
  final method = Method(
    (b) => b
      ..name = 'is${state.name.toPascalCase()}'
      ..returns = refer('bool')
      ..type = MethodType.getter
      ..lambda = true
      ..body = Code('this is ${state.name}'),
  );

  return method;
}

Method _writeAsStateMethod(StateElement state) {
  final method = Method(
    (b) => b
      ..name = 'as${state.name.toPascalCase()}'
      ..returns = refer(state.name)
      ..type = MethodType.getter
      ..lambda = true
      ..body = Code('this as ${state.name}'),
  );

  return method;
}
