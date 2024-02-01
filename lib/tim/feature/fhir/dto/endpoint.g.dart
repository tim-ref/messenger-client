// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'endpoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Endpoint _$EndpointFromJson(Map<String, dynamic> json) => Endpoint(
      resourceType: $enumDecode(_$ResourceTypeEnumMap, json['resourceType']),
      id: json['id'] as String,
      name: json['name'] as String?,
      status: json['status'] as String,
      address: json['address'] as String,
      connectionType:
          Coding.fromJson(json['connectionType'] as Map<String, dynamic>),
      payloadType: (json['payloadType'] as List<dynamic>)
          .map((e) => CodeableConcept.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EndpointToJson(Endpoint instance) => <String, dynamic>{
      'resourceType': _$ResourceTypeEnumMap[instance.resourceType]!,
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'address': instance.address,
      'connectionType': instance.connectionType,
      'payloadType': instance.payloadType,
    };

const _$ResourceTypeEnumMap = {
  ResourceType.Bundle: 'Bundle',
  ResourceType.PractitionerRole: 'PractitionerRole',
  ResourceType.Practitioner: 'Practitioner',
  ResourceType.HealthcareService: 'HealthcareService',
  ResourceType.Organization: 'Organization',
  ResourceType.Location: 'Location',
  ResourceType.Endpoint: 'Endpoint',
};
