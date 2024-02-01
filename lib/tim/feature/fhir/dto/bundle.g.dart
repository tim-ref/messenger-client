// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bundle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bundle _$BundleFromJson(Map<String, dynamic> json) => Bundle(
      resourceType: $enumDecode(_$ResourceTypeEnumMap, json['resourceType']),
      id: json['id'] as String,
      total: json['total'] as int?,
      link: (json['link'] as List<dynamic>?)
          ?.map((e) => BackboneElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      entry: (json['entry'] as List<dynamic>?)
          ?.map((e) => Entry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

const _$ResourceTypeEnumMap = {
  ResourceType.Bundle: 'Bundle',
  ResourceType.PractitionerRole: 'PractitionerRole',
  ResourceType.Practitioner: 'Practitioner',
  ResourceType.HealthcareService: 'HealthcareService',
  ResourceType.Organization: 'Organization',
  ResourceType.Location: 'Location',
  ResourceType.Endpoint: 'Endpoint',
};
