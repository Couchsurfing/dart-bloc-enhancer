import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:bloc_enhancer_gen/gen/settings.dart';
import 'package:bloc_enhancer_gen/src/checkers/bloc_enhancer_checkers.dart';
import 'package:bloc_enhancer_gen/src/models/bloc_element.dart';
import 'package:bloc_enhancer_gen/src/models/state_element.dart';

class BlocVisitor extends RecursiveElementVisitor<void> {
  BlocVisitor(this.settings);

  final Settings settings;

  final blocs = <BlocElement>[];

  @override
  void visitClassElement(ClassElement element) {
    if (!blocChecker.isAssignableFromType(element.thisType)) {
      return;
    }

    if (ignoreChecker.hasAnnotationOfExact(element)) {
      return;
    }

    if (!settings.autoEnhance) {
      bool canEnhance = false;
      for (final pattern in settings.enhance) {
        if (RegExp(pattern).hasMatch(element.name)) {
          canEnhance = true;
          break;
        }
      }

      if (!canEnhance && enhanceChecker.hasAnnotationOfExact(element)) {
        canEnhance = true;
      }

      if (!canEnhance) {
        return;
      }
    }

    // get the event and state from the extended clause
    final typeArgs = element.allSupertypes
        .firstWhere((e) => e.element.name == 'Bloc')
        .typeArguments;
    if (typeArgs.length != 2) {
      throw Exception('Bloc must have 2 type arguments');
    }

    final event = typeArgs[0].element;
    final state = typeArgs[1].element;

    if (event == null || state == null) {
      throw Exception('Bloc must have 2 type arguments');
    }

    if (event is! ClassElement || state is! ClassElement) {
      throw Exception('Bloc must have 2 type arguments');
    }

    bool createFactory = settings.createStateFactory;

    if (!createFactory) {
      createFactory = stateFactoryChecker.hasAnnotationOfExact(state,
          throwOnUnresolved: false);
    }

    final blocElement = BlocElement(
      event: event,
      state: StateElement(
        element: state,
        createFactory: createFactory,
      ),
      bloc: element,
    );

    blocs.add(blocElement);
  }
}
