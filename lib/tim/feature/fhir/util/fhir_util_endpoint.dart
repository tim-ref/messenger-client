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
import 'package:fluffychat/tim/feature/fhir/util/fhir_util_extensions.dart';

// JSON values for FHIR Endpoint resources.
const _active = 'active';
const _tim = 'tim';

/// Contains functions for FHIR [Endpoint](https://www.hl7.org/fhir/R4/endpoint.html) resources in JSON.
class EndpointJson {
  static bool isActiveTimEndpointWithAddress(Resource resource, {required String address}) {
    return resource is FhirEndpoint &&
        resource.status == FhirCode(_active) &&
        resource.connectionType.code == FhirCode(_tim) &&
        resource.address == FhirUrl(address);
  }

  static bool isActiveTimEndpointHiddenFromInsureesWithAddress(
    Resource resource, {
    required String address,
  }) {
    return resource is FhirEndpoint &&
        resource.status == FhirCode(_active) &&
        resource.connectionType.code == FhirCode(_tim) &&
        resource.address == FhirUrl(address) &&
        resource.extension_?.any(ExtensionsJson.isHideEndpointExtension) == true;
  }

  /// Copy and set 'status' to 'active'.
  static FhirEndpoint copyAndActivateEndpoint(FhirEndpoint endpoint) =>
      endpoint.copyWith(status: FhirCode(_active));
}
