// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map json) => Settings.defaults(
      autoEnhance: json['auto_enhance'] as bool? ?? false,
      avoidEvents: (json['avoid_events'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      avoidStates: (json['avoid_states'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createStateFactory: json['create_state_factory'] as bool? ?? false,
      enhance: (json['enhance'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createEventFactory: json['create_event_factory'] as bool? ?? false,
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'auto_enhance': instance.autoEnhance,
      'avoid_events': instance.avoidEvents,
      'avoid_states': instance.avoidStates,
      'enhance': instance.enhance,
      'create_state_factory': instance.createStateFactory,
      'create_event_factory': instance.createEventFactory,
    };
