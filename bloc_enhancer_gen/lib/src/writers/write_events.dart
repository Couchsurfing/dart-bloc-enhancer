// ignore_for_file: deprecated_member_use
// --- LICENSE ---

/**
Copyright 2025 CouchSurfing International Inc.

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
import 'package:analyzer/dart/element/element2.dart';
import 'package:bloc_enhancer_gen/src/checkers/bloc_enhancer_checkers.dart';
import 'package:bloc_enhancer_gen/src/models/bloc_element.dart';
import 'package:bloc_enhancer_gen/src/models/event_element.dart';
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
      ..name = '_${bloc.bloc.name3}Events'
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
            ..type = refer(bloc.bloc.name3 ?? ''),
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

  for (final ctor in event.element.constructors2) {
    // check for ignore annotation

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
          ..name = p.name3 ?? ''
          ..named = p.isNamed
          ..defaultTo = p.defaultValueCode == null
              ? null
              : Code(p.defaultValueCode!)
          ..type = refer(p.type.getDisplayString());

        if (isRequired != null) {
          b.required = isRequired;
        }
      });
    }

    var name = switch (ctor.name3) {
      '_' || 'new' || null => eventName,
      final String name => name,
      // ignore: dead_code
      Object() => eventName,
    };

    if (usedNames[name] case final count?) {
      name = '$name$count';
    }
    usedNames[name] = (usedNames[name] ?? 0) + 1;

    final ctorName = switch (ctor.name3) {
      '_' || 'new' || null => '',
      final String name => '.$name',
    };

    final method = Method.returnsVoid(
      (b) => b
        ..name = name
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
            refer('${event.name}${ctorName}').newInstance(
              ctor.formalParameters.where((p) => p.isPositional).map((p) {
                return refer(p.name3 ?? '');
              }),
              {
                for (final p in ctor.formalParameters.where((p) => p.isNamed))
                  p.name3 ?? '': refer(p.name3 ?? ''),
              },
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
      ..name = '\$${bloc.bloc.name3}EventsX'
      ..on = refer(bloc.bloc.name3 ?? '')
      ..methods.add(
        Method(
          (b) => b
            ..name = 'events'
            ..returns = refer('_${bloc.bloc.name3}Events')
            ..lambda = true
            ..type = MethodType.getter
            ..body = refer(
              '_${bloc.bloc.name3}Events',
            ).newInstance([refer('this')]).code,
        ),
      ),
  );

  return extension;
}
