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
// --- LICENSE ---
import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_enhancer_gen/src/checkers/bloc_enhancer_checkers.dart';
import 'package:bloc_enhancer_gen/src/models/bloc_element.dart';
import 'package:bloc_enhancer_gen/src/models/factory_element.dart';
import 'package:change_case/change_case.dart';
import 'package:code_builder/code_builder.dart';

class WriteFactory {
  const WriteFactory(this.baseFactory, this.factories);

  final FactoryElement baseFactory;
  final Iterable<FactoryElement> factories;

  static Iterable<Class> write(
      Iterable<BlocElement> blocs,
      FactoryElement Function(BlocElement) root,
      Iterable<FactoryElement> Function(BlocElement) factories) sync* {
    for (final bloc in blocs) {
      final rootFactory = root(bloc);
      final factoryElements = factories(bloc);

      yield WriteFactory(rootFactory, factoryElements)._writeCreatorClass();
    }
  }

  Class _writeCreatorClass() {
    final docs = '''
  /// Creates a new instance of [${baseFactory.name}] with the given parameters
  ///
  /// Intended to be used for **_TESTING_** purposes only.''';

    final usedNames = <String, int>{};

    return Class(
      (b) => b
        ..name = '_\$${baseFactory.name}Creator'
        ..docs.add(docs)
        ..constructors.add(
          Constructor((b) => b..constant = true),
        )
        ..methods.addAll(factories
            .where((e) => e.createFactory && !e.element.isAbstract)
            .map((e) => _writeCreatorMethod(e, usedNames))
            .expand((e) => e)),
    );
  }

  Iterable<Method> _writeCreatorMethod(
    FactoryElement element,
    Map<String, int> usedNames,
  ) sync* {
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
      final shouldIgnore = ignoreChecker.hasAnnotationOfExact(
        ctor,
        throwOnUnresolved: false,
      );
      if (shouldIgnore) {
        continue;
      }

      var ctorName = removePrivate(element.name).toCamelCase();

      if (ctor.name.isNotEmpty) {
        ctorName = '${removePrivate(element.name)}_${removePrivate(ctor.name)}'
            .toCamelCase();
      }

      if (usedNames[ctorName] case final count?) {
        ctorName += '$count';
      }

      usedNames[ctorName] = (usedNames[ctorName] ?? 0) + 1;

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
}
