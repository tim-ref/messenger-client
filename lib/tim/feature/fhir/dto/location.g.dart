// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      resourceType: $enumDecode(_$ResourceTypeEnumMap, json['resourceType']),
      id: json['id'] as String,
      name: json['name'] as String?,
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
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
