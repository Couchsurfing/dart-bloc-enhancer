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
import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_enhancer_gen/src/models/bloc_element.dart';
import 'package:bloc_enhancer_gen/src/models/state_element.dart';
import 'package:change_case/change_case.dart';
import 'package:code_builder/code_builder.dart';

List<Spec> writeStates(List<BlocElement> blocs) {
  final extensions = blocs.map(_writeTypingExtension).toList();

  final redirects = blocs.where((e) => e.shouldCreateFactory);
  final creatorClasses = redirects.map(_writeCreatorClass).toList();
  final creatorExtension = redirects.map(_writeCreatorExtension).toList();

  return [
    ...extensions,
    ...creatorClasses,
    ...creatorExtension,
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

Class _writeCreatorClass(BlocElement element) {
  return Class(
    (b) => b
      ..name = '_\$${element.state.name}Creator'
      ..constructors.add(
        Constructor((b) => b..constant = true),
      )
      ..methods.addAll(element.states
          .where((e) => e.createFactory)
          .map(_writeCreatorMethod)
          .expand((e) => e)),
  );
}

Extension _writeCreatorExtension(BlocElement element) {
  final docs = '''
  /// Creates a new instance of [${element.state.name}] with the given parameters
  ///
  /// Intended to be used for **_TESTING_** purposes only.''';
  return Extension(
    (b) => b
      ..name = '_\$${element.state.name}CreatorX'
      ..on = refer(element.state.name)
      ..methods.add(
        Method(
          (b) => b
            ..name = '_\$Creator'
            ..static = true
            ..returns = refer('_\$${element.state.name}Creator')
            ..type = MethodType.getter
            ..lambda = true
            ..docs.add(docs)
            ..body = refer('_\$${element.state.name}Creator').newInstance(
              [
                refer('this'),
              ],
            ).code,
        ),
      ),
  );
}

Iterable<Method> _writeCreatorMethod(StateElement element) sync* {
  Parameter param(ParameterElement p, [bool? isRequired]) {
    return Parameter(
      (b) {
        b
          ..name = p.name
          ..named = p.isNamed
          ..defaultTo =
              p.defaultValueCode == null ? null : Code(p.defaultValueCode!)
          ..type = refer(
            p.type.getDisplayString(withNullability: true),
          );

        if (isRequired != null) {
          b.required = isRequired;
        }
      },
    );
  }

  String removePrivate(String name) {
    return name.replaceAll(RegExp('^_+'), '');
  }

  for (final ctor in element.element.constructors) {
    final ctorName = ctor.name.isNotEmpty
        ? '${removePrivate(element.name)}_${removePrivate(ctor.name)}'
            .toCamelCase()
        : removePrivate(element.name).toCamelCase();

    final classAccess = ctor.name.isEmpty
        ? ctor.enclosingElement.name
        : '${ctor.enclosingElement.name}.${ctor.name}';

    yield Method(
      (b) => b
        ..name = ctorName
        ..returns = refer(ctor.enclosingElement.name)
        ..lambda = true
        ..requiredParameters.addAll(
          ctor.parameters.where((p) => p.isRequiredPositional).map(param),
        )
        ..optionalParameters.addAll(
          ctor.parameters
              .where((p) => !p.isRequiredPositional)
              .map((p) => param(p, p.isRequiredNamed)),
        )
        ..body = refer(classAccess).newInstance(
          ctor.parameters.where((p) => p.isPositional).map(
            (p) {
              return refer(p.name);
            },
          ),
          {
            for (final p in ctor.parameters.where((p) => p.isNamed))
              p.name: refer(p.name),
          },
        ).code,
    );
  }
}
