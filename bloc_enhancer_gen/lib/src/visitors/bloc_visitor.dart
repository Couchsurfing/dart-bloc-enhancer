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
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor2.dart';
import 'package:bloc_enhancer_gen/models/settings.dart';
import 'package:bloc_enhancer_gen/src/checkers/bloc_enhancer_checkers.dart';
import 'package:bloc_enhancer_gen/src/models/bloc_element.dart';
import 'package:bloc_enhancer_gen/src/models/event_element.dart';
import 'package:bloc_enhancer_gen/src/models/state_element.dart';

class BlocVisitor extends RecursiveElementVisitor2<void> {
  BlocVisitor(this.settings);

  final Settings settings;

  final blocs = <BlocElement>[];

  @override
  void visitClassElement(ClassElement2 element) {
    if (!blocChecker.isAssignableFromType(element.thisType)) {
      return;
    }

    if (ignoreChecker.hasAnnotationOfExact(element)) {
      return;
    }

    if (!settings.autoEnhance) {
      bool canEnhance = false;
      for (final pattern in settings.enhance) {
        if (RegExp(pattern).hasMatch(element.name3 ?? '')) {
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

    final [DartType(element3: event), DartType(element3: state)] = typeArgs;

    if (event == null || state == null) {
      throw Exception('Bloc must have 2 type arguments');
    }

    if (event is! ClassElement2 || state is! ClassElement2) {
      throw Exception('Bloc must have 2 type arguments');
    }

    final createStateFactory = switch (settings.createStateFactory) {
      false => createFactoryChecker.hasAnnotationOfExact(
        state,
        throwOnUnresolved: false,
      ),
      _ => true,
    };

    final createEventFactory = switch (settings.createEventFactory) {
      false => createFactoryChecker.hasAnnotationOfExact(
        event,
        throwOnUnresolved: false,
      ),
      _ => true,
    };

    final blocElement = BlocElement(
      event: EventElement(element: event, createFactory: createEventFactory),
      state: StateElement(element: state, createFactory: createStateFactory),
      bloc: element,
    );

    blocs.add(blocElement);
  }
}
