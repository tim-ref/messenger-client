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

import 'package:fluffychat/tim/feature/fhir/dto/codeable_concept.dart';
import 'package:fluffychat/tim/feature/fhir/dto/coding.dart';
import 'package:fluffychat/tim/feature/fhir/dto/meta.dart';
import 'package:fluffychat/tim/feature/fhir/dto/resource_type.dart';

part 'create_endpoint.g.dart';

@JsonSerializable(createFactory: false)
class CreateEndpoint {
  final ResourceType resourceType;
  final Meta meta;
  final String status;
  final Coding connectionType;
  final String name;
  final String address;
  final List<CodeableConcept> payloadType;

  CreateEndpoint({
    required this.resourceType,
    required this.meta,
    required this.status,
    required this.connectionType,
    required this.name,
    required this.address,
    required this.payloadType,
  });

  Map<String, dynamic> toJson() => _$CreateEndpointToJson(this);
}
