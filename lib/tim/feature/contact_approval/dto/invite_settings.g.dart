// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InviteSettings _$InviteSettingsFromJson(Map<String, dynamic> json) =>
    InviteSettings(
      start: InviteSettings._startFromJson(json['start'] as int),
      end: InviteSettings._endFromJson(json['end'] as int?),
    );

Map<String, dynamic> _$InviteSettingsToJson(InviteSettings instance) =>
    <String, dynamic>{
      'start': InviteSettings._startToJson(instance.start),
      'end': InviteSettings._endToJson(instance.end),
    };
