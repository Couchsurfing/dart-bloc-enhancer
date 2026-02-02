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
import 'dart:async' show FutureOr;

import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_enhancer_gen/models/settings.dart';
import 'package:bloc_enhancer_gen/src/checkers/bloc_enhancer_checkers.dart';
import 'package:bloc_enhancer_gen/src/models/event_element.dart';
import 'package:bloc_enhancer_gen/src/models/state_element.dart';
import 'package:bloc_enhancer_gen/src/visitors/bloc_visitor.dart';
import 'package:bloc_enhancer_gen/src/writers/write_file.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart' hide TypeChecker;

final class BlocEnhancerGenerator extends Generator {
  BlocEnhancerGenerator(this.settings);

  final Settings settings;

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final visitor = BlocVisitor(settings);
    library.element.visitChildren(visitor);

    final allClassElements = library.allElements.whereType<ClassElement>();

    for (final bloc in visitor.blocs) {
      final eventAndState = {bloc.event.name, bloc.state.name};
      final ignore = {bloc.bloc.name, ...eventAndState};

      for (final clazz in allClassElements) {
        if (ignore.contains(clazz.name)) {
          continue;
        }

        // get super types
        final superTypes = {
          ...clazz.allSupertypes.map((e) => e.element.name),
        };
        if (superTypes.contains(bloc.event.name)) {
          bool canAdd = true;
          for (final pattern in settings.avoidEvents) {
            if (RegExp(pattern).hasMatch(clazz.name ?? '')) {
              canAdd = false;
              break;
            }
          }

          if (canAdd) {
            final createFactory = switch (true) {
              _ when bloc.event.createFactory => true,
              _
                  when createFactoryChecker.hasAnnotationOf(
                    clazz,
                    throwOnUnresolved: false,
                  ) =>
                true,
              _ => settings.createEventFactory,
            };

            bloc.addEvent(
              EventElement(element: clazz, createFactory: createFactory),
            );
          }
        } else if (superTypes.contains(bloc.state.name)) {
          bool canAdd = true;

          if (!enhanceChecker.hasAnnotationOfExact(clazz)) {
            for (final pattern in settings.avoidStates) {
              if (RegExp(pattern).hasMatch(clazz.name ?? '')) {
                canAdd = false;
                break;
              }
            }
          }

          if (canAdd) {
            final createFactory = switch (true) {
              _ when bloc.state.createFactory => true,
              _
                  when createFactoryChecker.hasAnnotationOf(
                    clazz,
                    throwOnUnresolved: false,
                  ) =>
                true,
              _ => settings.createStateFactory,
            };

            bloc.addState(
              StateElement(element: clazz, createFactory: createFactory),
            );
          }
        }
      }
    }

    final emitter = DartEmitter(useNullSafetySyntax: true);

    final generated = writeFile(visitor.blocs);

    final output = generated.map((e) => e.accept(emitter)).join('\n');

    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format(output);
  }
}
