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
part of 'simple_bloc.dart';

class SimpleEvent extends Equatable {
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
