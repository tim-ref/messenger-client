/*
 * TIM-Referenzumgebung
 * Copyright (C) 2025 - akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/tim/feature/fhir/dto/resource_type.dart';

// JSON keys for PractitionerRole resources
const _resourceType = 'resourceType';
const _endpoint = 'endpoint';
const _reference = 'reference';

/// Contains functions for FHIR [PractitionerRole](https://hl7.org/fhir/R4/practitionerrole.html) resources in JSON.
class PractitionerRoleJson {
  static bool isPractitionerRoleResource(dynamic resource) =>
      resource[_resourceType] == ResourceType.PractitionerRole.name;

  static Map<String, dynamic> copyAndAddEndpointReference(
    Map<String, dynamic> practitionerRole,
    String endpointId,
  ) {
    final pr = {...practitionerRole};
    final endpoints = pr[_endpoint] as List<dynamic>?;
    final newReference = {_reference: '${ResourceType.Endpoint.name}/$endpointId'};
    final containsEndpoint =
        endpoints?.any((reference) => reference[_reference].contains(endpointId)) ?? false;
    if (endpoints != null && !containsEndpoint) {
      endpoints.add(newReference);
    } else if (endpoints == null) {
      pr.putIfAbsent(_endpoint, () => [newReference]);
    }
    return pr;
  }

  static Map<String, dynamic> copyAndRemoveEndpointReference(
    Map<String, dynamic> practitionerRole,
    String endpointId,
  ) {
    final pr = {...practitionerRole};
    final endpointReferences = List.from(pr[_endpoint] as List);
    endpointReferences.removeWhere((element) => element[_reference].contains(endpointId));
    if (endpointReferences.isEmpty) {
      pr.removeWhere((key, _) => key == _endpoint);
    } else {
      pr[_endpoint] = endpointReferences;
    }
    return pr;
  }
}
