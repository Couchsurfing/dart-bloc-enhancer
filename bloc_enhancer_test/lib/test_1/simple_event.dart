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
part of 'simple_bloc.dart';

@createFactory
class SimpleEvent extends Equatable {
  static const create = _$SimpleEventCreator();

  const SimpleEvent();

  @override
  List<Object> get props => [];
}

class _Init extends SimpleEvent {
  const _Init();
}

class _Create extends SimpleEvent {
  const _Create(this.name);
  const _Create.personal() : name = '';
  const _Create.other({required this.name});
  const _Create.dude([this.name = 'sup']);

  final String name;
}

class _Optional extends SimpleEvent {
  const _Optional([this.name]);
  const _Optional.req(String this.name);
  const _Optional.op(this.name);
  const _Optional.no({this.name = 'no'});

  final String? name;
}

/// Preserves error type at call site (e.g. bloc.events.addTokenFailed<MyException>(...)).
class _AddTokenFailed<E extends Object> extends SimpleEvent {
  const _AddTokenFailed({required this.error, required this.stackTrace});
  final E error;
  final StackTrace stackTrace;

  @override
  List<Object> get props => [error, stackTrace];
}

/// Covers multiple type params in generated methods.
class _MultiGeneric<E, F> extends SimpleEvent {
  const _MultiGeneric({required this.a, required this.b});
  final E a;
  final F b;

  @override
  List<Object> get props => [a as Object, b as Object];
}

/// Generic + named ctor: Dart requires `Class<T>.named()`, not `Class.named<T>()`.
class _GenericNamed<T> extends SimpleEvent {
  const _GenericNamed.foo();
}
