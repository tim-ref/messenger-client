// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'healthcare_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthcareService _$HealthcareServiceFromJson(Map<String, dynamic> json) =>
    HealthcareService(
      resourceType: $enumDecode(_$ResourceTypeEnumMap, json['resourceType']),
      id: json['id'] as String,
      location: (json['location'] as List<dynamic>?)
          ?.map((e) => Reference.fromJson(e as Map<String, dynamic>))
          .toList(),
      providedBy:
          Reference.fromJson(json['providedBy'] as Map<String, dynamic>),
      name: json['name'] as String?,
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
