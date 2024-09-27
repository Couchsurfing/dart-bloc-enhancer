// --- LICENSE ---
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
// --- LICENSE ---
import 'package:json_annotation/json_annotation.dart';

import 'settings_interface.dart';

part 'settings.g.dart';

@JsonSerializable(constructor: 'defaults')
class Settings implements SettingsInterface {
  const Settings({
    required this.autoEnhance,
    required this.avoidEvents,
    required this.avoidStates,
    required this.createStateFactory,
    required this.enhance,
    required this.createEventFactory,
  });

  const Settings.defaults({
    this.autoEnhance = false,
    this.avoidEvents = const [],
    this.avoidStates = const [],
    this.createStateFactory = false,
    this.enhance = const [],
    this.createEventFactory = false,
  });

  factory Settings.fromJson(Map json) {
    final settings = _$SettingsFromJson(json);

    final patterns = <String, List<String>>{};

    settings.avoidEvents
        .forEach((e) => patterns.putIfAbsent(e, () => []).add('avoid_events'));
    settings.avoidStates
        .forEach((e) => patterns.putIfAbsent(e, () => []).add('avoid_states'));

    // make sure that the priorities patterns are valid regex
    for (final MapEntry(key: pattern, value: locations) in patterns.entries) {
      try {
        RegExp(pattern);
      } catch (error) {
        throw ArgumentError.value(
          pattern,
          'Found in ${locations.join(',')}',
          error,
        );
      }
    }
    return settings;
  }

  @override
  final bool autoEnhance;

  @override
  final List<String> avoidEvents;

  @override
  final List<String> avoidStates;

  @override
  final List<String> enhance;

  @override
  final bool createStateFactory;

  @override
  final bool createEventFactory;

  Map<String, dynamic> toJson() => _$SettingsToJson(this);
}
