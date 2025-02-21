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
import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_enhancer_gen/src/checkers/bloc_enhancer_checkers.dart';
import 'package:bloc_enhancer_gen/src/checkers/type_checker.dart';
import 'package:bloc_enhancer_gen/src/models/event_element.dart';
import 'package:bloc_enhancer_gen/src/models/state_element.dart';

class BlocElement {
  BlocElement({
    required this.event,
    required this.state,
    required this.bloc,
  })  : _states = [],
        _events = [];

  final EventElement event;
  final StateElement state;
  final ClassElement bloc;

  void addState(StateElement state) {
    if (_hasIgnore(state.element)) {
      return;
    }

    if (!state.createFactory) {
      state.createFactory = _hasStateFactory(state.element);
    }

    _states.add(state);
  }

  bool _hasIgnore(ClassElement element) {
    return _hasAnnotation(element, ignoreChecker);
  }

  bool _hasStateFactory(ClassElement element) {
    return _hasAnnotation(element, createFactoryChecker);
  }

  bool _hasAnnotation(ClassElement element, TypeChecker checker) {
    final hasAnnotation = checker.hasAnnotationOfExact(
      element,
      throwOnUnresolved: false,
    );

    return hasAnnotation;
  }

  void addEvent(EventElement event) {
    if (_hasIgnore(event.element)) {
      return;
    }

    if (!event.createFactory) {
      event.createFactory = _hasStateFactory(event.element);
    }

    _events.add(event);
  }

  final List<StateElement> _states;
  final List<EventElement> _events;
  List<StateElement> get states => _states;
  List<EventElement> get events => _events;

  bool get shouldCreateStateFactory =>
      state.createFactory ||
      _states.any(
        (e) => e.createFactory,
      );

  bool get shouldCreateEventFactory =>
      event.createFactory ||
      _events.any(
        (e) => e.createFactory,
      );
}
