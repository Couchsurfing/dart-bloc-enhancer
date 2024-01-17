import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_enhancer_gen/src/checkers/bloc_enhancer_checkers.dart';
import 'package:bloc_enhancer_gen/src/models/bloc_element.dart';
import 'package:change_case/change_case.dart';
import 'package:code_builder/code_builder.dart';

List<Spec> writeEvents(List<BlocElement> bloc) {
  final eventClasses = bloc.map(_writeEventsClass).toList();
  final extensions = bloc.map(_writeExtension).toList();

  return [
    ...eventClasses,
    ...extensions,
  ];
}

Class _writeEventsClass(BlocElement bloc) {
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
            ..type = refer(bloc.bloc.name),
        ),
      )
      ..methods.addAll(bloc.events.expand(_writeEventMethod)),
  );

  return events;
}

List<Method> _writeEventMethod(ClassElement event) {
  final methods = <Method>[];
  for (final ctor in event.constructors) {
    // check for ignore annotation

    final hasIgnoreAnnotation = ignoreChecker.hasAnnotationOfExact(
      ctor,
      throwOnUnresolved: false,
    );

    if (hasIgnoreAnnotation) {
      continue;
    }

    final eventName = event.name.replaceAll(RegExp('^_+'), '').toCamelCase();

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

    final method = Method.returnsVoid(
      (b) => b
        ..name = ctor.name == '' ? eventName : ctor.name
        ..requiredParameters.addAll(
          ctor.parameters.where((p) => p.isRequiredPositional).map(param),
        )
        ..optionalParameters.addAll(
          ctor.parameters
              .where((p) => !p.isRequiredPositional)
              .map((p) => param(p, p.isRequiredNamed)),
        )
        ..body = Block.of(
          [
            refer('_bloc').property('add').call([
              refer('${event.name}${ctor.name == '' ? '' : '.${ctor.name}'}')
                  .newInstance(
                      ctor.parameters.where((p) => p.isPositional).map(
                        (p) {
                          return refer(p.name);
                        },
                      ),
                      {
                    for (final p in ctor.parameters.where((p) => p.isNamed))
                      p.name: refer(p.name),
                  })
            ]).statement,
          ],
        ),
    );

    methods.add(method);
  }

  return methods;
}

Extension _writeExtension(BlocElement bloc) {
  final extension = Extension((b) => b
    ..name = '\$${bloc.bloc.name}EventsX'
    ..on = refer(bloc.bloc.name)
    ..methods.add(
      Method(
        (b) => b
          ..name = 'events'
          ..returns = refer('_${bloc.bloc.name}Events')
          ..lambda = true
          ..type = MethodType.getter
          ..body = refer('_${bloc.bloc.name}Events').newInstance([
            refer('this'),
          ]).code,
      ),
    ));

  return extension;
}
