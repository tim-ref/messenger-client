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

import 'package:fluffychat/tim/feature/fhir/dto/endpoint_reference.dart';
import 'package:fluffychat/tim/feature/fhir/dto/reference.dart';
import 'package:fluffychat/tim/feature/fhir/dto/resource.dart';
import 'package:fluffychat/tim/feature/fhir/dto/resource_type.dart';

part 'healthcare_service.g.dart';

@JsonSerializable(createToJson: false)
class HealthcareService extends Resource implements EndpointReference {
  final List<Reference>? location;
  final Reference providedBy;
  final String? name;
  @override
  final List<Reference>? endpoint;

  HealthcareService({
    required ResourceType resourceType,
    required String id,
    this.location,
    required this.providedBy,
    this.name,
    this.endpoint,
  }) : super(resourceType, id);

  factory HealthcareService.fromJson(Map<String, dynamic> json) =>
      _$HealthcareServiceFromJson(json);
}
