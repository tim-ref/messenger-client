/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:json_annotation/json_annotation.dart';

import 'package:fluffychat/tim/feature/fhir/dto/endpoint.dart';
import 'package:fluffychat/tim/feature/fhir/dto/healthcare_service.dart';
import 'package:fluffychat/tim/feature/fhir/dto/location.dart';
import 'package:fluffychat/tim/feature/fhir/dto/organization.dart';
import 'package:fluffychat/tim/feature/fhir/dto/practitioner.dart';
import 'package:fluffychat/tim/feature/fhir/dto/practitioner_role.dart';
import 'package:fluffychat/tim/feature/fhir/dto/resource.dart';
import 'package:fluffychat/tim/feature/fhir/dto/resource_type.dart';

part 'entry.g.dart';

@JsonSerializable(createToJson: false)
class Entry {
  @JsonKey(fromJson: _fromJsonToProperType)
  final Resource resource;

  Entry({
    required this.resource,
  });

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);

  static Resource _fromJsonToProperType(Map<String, dynamic> json) {
    final resource = Resource.fromJson(json);
    switch (resource.resourceType) {
      case ResourceType.PractitionerRole:
        return PractitionerRole.fromJson(json);
      case ResourceType.HealthcareService:
        return HealthcareService.fromJson(json);
      case ResourceType.Practitioner:
        return Practitioner.fromJson(json);
      case ResourceType.Organization:
        return Organization.fromJson(json);
      case ResourceType.Location:
        return Location.fromJson(json);
      case ResourceType.Endpoint:
        return Endpoint.fromJson(json);
      default:
        throw Exception(
            'Unknown ResourceType provided. Resource Type: ${json['resourceType']}',);
    }
  }

  @override
  String toString() {
    return 'Entry{resource: ${resource.resourceType}, id: ${resource.id}}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entry &&
          runtimeType == other.runtimeType &&
          resource == other.resource;

  @override
  int get hashCode => resource.hashCode;
}
