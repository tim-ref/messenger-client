// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practitioner_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PractitionerRole _$PractitionerRoleFromJson(Map<String, dynamic> json) =>
    PractitionerRole(
      resourceType: $enumDecode(_$ResourceTypeEnumMap, json['resourceType']),
      id: json['id'] as String,
      practitioner: json['practitioner'] == null
          ? null
          : Reference.fromJson(json['practitioner'] as Map<String, dynamic>),
      endpoint: (json['endpoint'] as List<dynamic>?)
          ?.map((e) => Reference.fromJson(e as Map<String, dynamic>))
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
