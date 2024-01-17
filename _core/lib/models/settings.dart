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
  });

  const Settings.defaults({
    this.autoEnhance = false,
    this.avoidEvents = const [],
    this.avoidStates = const [],
    this.createStateFactory = false,
    this.enhance = const [],
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

  Map<String, dynamic> toJson() => _$SettingsToJson(this);
}
