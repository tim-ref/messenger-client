// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'human_name.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HumanName _$HumanNameFromJson(Map<String, dynamic> json) => HumanName(
      text: json['text'] as String?,
      family: json['family'] as String?,
      given:
          (json['given'] as List<dynamic>?)?.map((e) => e as String).toList(),
      prefix:
          (json['prefix'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
