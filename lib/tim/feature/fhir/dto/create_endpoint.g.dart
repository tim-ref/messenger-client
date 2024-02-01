// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_endpoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreateEndpointToJson(CreateEndpoint instance) =>
    <String, dynamic>{
      'resourceType': _$ResourceTypeEnumMap[instance.resourceType]!,
      'meta': instance.meta,
      'status': instance.status,
      'connectionType': instance.connectionType,
      'name': instance.name,
      'address': instance.address,
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
