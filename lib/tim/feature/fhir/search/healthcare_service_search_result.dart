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
import 'package:fluffychat/tim/feature/fhir/search/fhir_search_result.dart';

part 'healthcare_service_search_result.g.dart';

@JsonSerializable(createFactory: false)
class HealthcareServiceSearchResult extends FhirSearchResult {
  final List<String> endpointIdList;
  final List<String> statusList;
  final List<Coding> connectionTypeList;
  final List<String> nameList;
  final String? name;
  final String id;
  final String? organizationName;
  final String? managingOrganization;
  final List<List<CodeableConcept>> payloadTypeList;
  final List<String> addressList;

  HealthcareServiceSearchResult({
    required this.endpointIdList,
    required this.statusList,
    required this.connectionTypeList,
    required this.nameList,
    this.name,
    required this.id,
    this.organizationName,
    this.managingOrganization,
    required this.payloadTypeList,
    required this.addressList,
  });

  @override
  Map<String, dynamic> toJson() => _$HealthcareServiceSearchResultToJson(this);
}
