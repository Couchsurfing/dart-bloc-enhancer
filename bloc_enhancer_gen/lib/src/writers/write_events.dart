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
// ignore_for_file: deprecated_member_use
import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_enhancer_gen/src/checkers/bloc_enhancer_checkers.dart';
import 'package:bloc_enhancer_gen/src/models/bloc_element.dart';
import 'package:bloc_enhancer_gen/src/models/event_element.dart';
import 'package:bloc_enhancer_gen/src/writers/type_utils.dart';
import 'package:bloc_enhancer_gen/src/writers/write_factory.dart';
import 'package:change_case/change_case.dart';
import 'package:code_builder/code_builder.dart';

List<Spec> writeEvents(List<BlocElement> blocs) {
  final eventClasses = blocs.map(_writeEventsClass);
  final extensions = blocs.map(_writeExtension);

  final creatorClasses = WriteFactory.write(
    blocs.where((e) => e.shouldCreateEventFactory),
    (e) => e.event,
    (e) => e.events,
  );

  return [...eventClasses, ...extensions, ...creatorClasses];
}

Class _writeEventsClass(BlocElement bloc) {
  final usedNames = <String, int>{};

  final events = Class(
    (b) => b
      ..name = '_${bloc.bloc.name}Events'
      ..constructors.add(
        Constructor(
          (b) => b
            ..constant = true
            ..requiredParameters.add(
              Parameter(
                (b) => b
                  ..name = '_bloc'
                  ..toThis = true,
              ),
            ),
        ),
      )
      ..fields.add(
        Field(
          (b) => b
            ..name = '_bloc'
            ..modifier = FieldModifier.final$
            ..type = refer(bloc.bloc.name ?? ''),
        ),
      )
      ..methods.addAll([
        for (final event in bloc.events)
          if (!event.element.isAbstract) ..._writeEventMethod(event, usedNames),
      ]),
  );

  return events;
}

List<Method> _writeEventMethod(EventElement event, Map<String, int> usedNames) {
  final methods = <Method>[];
  final classTypeParams = event.element.typeParameters;
  final inScopeNames = {
    for (final tp in classTypeParams)
      if (tp.name case final name? when name.isNotEmpty) name,
  };

  for (final ctor in event.element.constructors) {
    // Skip constructors the user explicitly opted out of.
    final hasIgnoreAnnotation = ignoreChecker.hasAnnotationOfExact(
      ctor,
      throwOnUnresolved: false,
    );

    if (hasIgnoreAnnotation) {
      continue;
    }

    final eventName = event.name.replaceAll(RegExp('^_+'), '').toCamelCase();

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

    var name = switch (ctor.name) {
      '_' || 'new' || null => eventName,
      final String name => name,
    };

    if (usedNames[name] case final count?) {
      name = '$name$count';
    }
    usedNames[name] = (usedNames[name] ?? 0) + 1;

    final typeArgs = [
      for (final tp in classTypeParams) refer(tp.name ?? ''),
    ];

    final namedConstructorName = switch (ctor.name) {
      '_' || 'new' || null => null,
      final String n => n,
    };

    final method = Method.returnsVoid(
      (b) => b
        ..name = name
        ..types.addAll(
          classTypeParams.map(typeParameterToReference),
        )
        ..requiredParameters.addAll(
          ctor.formalParameters.where((p) => p.isRequiredPositional).map(param),
        )
        ..optionalParameters.addAll(
          ctor.formalParameters
              .where((p) => !p.isRequiredPositional)
              .map((p) => param(p, p.isRequiredNamed)),
        )
        ..body = Block.of([
          Block.of([
            Code('if ('),
            refer('_bloc').property('isClosed').code,
            Code(')'),
            refer('').returned.statement,
          ]),
          refer('_bloc').property('add').call([
            genericConstructorInvocation(
              className: event.name,
              namedConstructorName: namedConstructorName,
              positionalArguments: ctor.formalParameters
                  .where((p) => p.isPositional)
                  .map((p) => refer(p.name ?? '')),
              namedArguments: {
                for (final p in ctor.formalParameters.where((p) => p.isNamed))
                  p.name ?? '': refer(p.name ?? ''),
              },
              typeArguments: typeArgs,
            ),
          ]).statement,
        ]),
    );

    methods.add(method);
  }

  return methods;
}

Extension _writeExtension(BlocElement bloc) {
  final extension = Extension(
    (b) => b
      ..name = '\$${bloc.bloc.name}EventsX'
      ..on = refer(bloc.bloc.name ?? '')
      ..methods.add(
        Method(
          (b) => b
            ..name = 'events'
            ..returns = refer('_${bloc.bloc.name}Events')
            ..lambda = true
            ..type = MethodType.getter
            ..body = refer(
              '_${bloc.bloc.name}Events',
            ).newInstance([refer('this')]).code,
        ),
      ),
  );

  return extension;
}
