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

import 'package:fhir/r4.dart';

/// Contains functions for FHIR [PractitionerRole](https://hl7.org/fhir/R4/practitionerrole.html) resources in JSON.
class PractitionerRoleJson {
  static PractitionerRole copyAndAddEndpointReference(
    PractitionerRole practitionerRole,
    String endpointId,
  ) {
    final containsEndpoint = practitionerRole.endpoint
            ?.any((endpoint) => endpoint.reference?.contains(endpointId) ?? false) ??
        false;

    if (!containsEndpoint) {
      return practitionerRole.copyWith(
        endpoint: [
          ...?practitionerRole.endpoint,
          Reference(reference: "Endpoint/$endpointId"),
        ],
      );
    } else {
      return practitionerRole;
    }
  }

  static PractitionerRole copyAndRemoveEndpointReference(
    PractitionerRole practitionerRole,
    String endpointId,
  ) {
    final containsEndpoint = practitionerRole.endpoint
            ?.any((endpoint) => endpoint.reference?.contains(endpointId) == true) ??
        false;

    if (containsEndpoint) {
      final filteredEndpoints = practitionerRole.endpoint
          ?.where((endpoint) => endpoint.reference?.contains(endpointId) != true)
          .toList();
      return practitionerRole.copyWith(
        endpoint: filteredEndpoints?.isNotEmpty == true ? filteredEndpoints : null,
      );
    } else {
      return practitionerRole;
    }
  }
}
