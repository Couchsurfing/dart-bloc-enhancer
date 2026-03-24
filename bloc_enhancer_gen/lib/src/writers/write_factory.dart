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
import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_enhancer_gen/src/checkers/bloc_enhancer_checkers.dart';
import 'package:bloc_enhancer_gen/src/models/bloc_element.dart';
import 'package:bloc_enhancer_gen/src/models/factory_element.dart';
import 'package:bloc_enhancer_gen/src/writers/type_utils.dart';
import 'package:change_case/change_case.dart';
import 'package:code_builder/code_builder.dart';

class WriteFactory {
  const WriteFactory(this.baseFactory, this.factories);

  final FactoryElement baseFactory;
  final Iterable<FactoryElement> factories;

  static Iterable<Class> write(
    Iterable<BlocElement> blocs,
    FactoryElement Function(BlocElement) root,
    Iterable<FactoryElement> Function(BlocElement) factories,
  ) sync* {
    for (final bloc in blocs) {
      final rootFactory = root(bloc);
      final factoryElements = factories(bloc);

      yield WriteFactory(rootFactory, factoryElements)._writeCreatorClass();
    }
  }

  Class _writeCreatorClass() {
    final docs =
        '''
  /// Creates a new instance of [${baseFactory.name}] with the given parameters
  ///
  /// Intended to be used for **_TESTING_** purposes only.''';

    final usedNames = <String, int>{};

    return Class(
      (b) => b
        ..name = '_\$${baseFactory.name}Creator'
        ..docs.add(docs)
        ..constructors.add(Constructor((b) => b..constant = true))
        ..methods.addAll(
          factories
              .where((e) => e.createFactory && !e.element.isAbstract)
              .map((e) => _writeCreatorMethod(e, usedNames))
              .expand((e) => e),
        ),
    );
  }

  Iterable<Method> _writeCreatorMethod(
    FactoryElement element,
    Map<String, int> usedNames,
  ) sync* {
    final classTypeParams = element.element.typeParameters;
    final inScopeNames = {
      for (final tp in classTypeParams)
        if (tp.name case final name? when name.isNotEmpty) name,
    };

    Parameter param(FormalParameterElement p, [bool? isRequired]) {
      return Parameter((b) {
        b
          ..name = p.name ?? ''
          ..named = p.isNamed
          ..defaultTo = switch (p.defaultValueCode) {
              final code? => Code(code),
              _ => null,
            }
          ..type = typeToReference(p.type, inScopeTypeParams: inScopeNames);

        if (isRequired != null) {
          b.required = isRequired;
        }
      });
    }

    String removePrivate(String name) {
      if (name == 'new') {
        return '';
      }

      return name.replaceAll(RegExp('^_+'), '');
    }

    final typeArgs = [
      for (final tp in classTypeParams) refer(tp.name ?? ''),
    ];

    for (final ctor in element.element.constructors) {
      final shouldIgnore = ignoreChecker.hasAnnotationOfExact(
        ctor,
        throwOnUnresolved: false,
      );
      if (shouldIgnore) {
        continue;
      }

      var ctorName = removePrivate(element.name).toCamelCase();

      if (ctor.name case final String name when name.isNotEmpty) {
        ctorName = '${removePrivate(element.name)}_${removePrivate(name)}'
            .toCamelCase();
      }

      if (usedNames[ctorName] case final count?) {
        ctorName += '$count';
      }

      usedNames[ctorName] = (usedNames[ctorName] ?? 0) + 1;

      final className = ctor.enclosingElement.name ?? '';
      final namedConstructorName = switch (ctor.name) {
        '_' || 'new' || null => null,
        final String n => n,
      };

      final returnType = classTypeParams.isEmpty
          ? refer(className)
          : TypeReference((b) => b
              ..symbol = className
              ..types.addAll(typeArgs));

      yield Method(
        (b) => b
          ..name = ctorName
          ..types.addAll(classTypeParams.map(typeParameterToReference))
          ..returns = returnType
          ..lambda = true
          ..requiredParameters.addAll(
            ctor.formalParameters
                .where((p) => p.isRequiredPositional)
                .map(param),
          )
          ..optionalParameters.addAll(
            ctor.formalParameters
                .where((p) => !p.isRequiredPositional)
                .map((p) => param(p, p.isRequiredNamed)),
          )
          ..body = genericConstructorInvocation(
            className: className,
            namedConstructorName: namedConstructorName,
            positionalArguments: ctor.formalParameters
                .where((p) => p.isPositional)
                .map((p) => refer(p.name ?? '')),
            namedArguments: {
              for (final p in ctor.formalParameters.where((p) => p.isNamed))
                p.name ?? '': refer(p.name ?? ''),
            },
            typeArguments: typeArgs,
          ).code,
      );
    }
  }
}
