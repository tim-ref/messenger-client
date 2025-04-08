/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - 2025 – akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fhir/r4.dart';
import 'package:fluffychat/tim/feature/fhir/util/fhir_util_endpoint.dart';

/// Wraps a searchset Bundle.
class FhirSearchsetBundle {
  late final Bundle _bundle;

  /// First PractitionerRole in [_queryResponse].
  late final PractitionerRole? practitionerRole;

  /// The Matrix user's first TIM Endpoint in [_queryResponse].
  late final FhirEndpoint? timEndpoint;

  FhirSearchsetBundle.fromJson(
    String mxid,
    Map<String, dynamic> queryResponse,
  ) {
    _bundle = Bundle.fromJson(queryResponse);

    if (_bundle.total != null && _bundle.total! > 0) {
      final resources = _bundle.entry?.map((entry) => entry.resource) ?? List.empty();

      practitionerRole = resources.whereType<PractitionerRole>().first;

      timEndpoint = resources
          .whereType<FhirEndpoint>()
          .where(
            (resource) => EndpointJson.isActiveTimEndpointWithAddress(resource, address: mxid),
          )
          .firstOrNull;
    }
  }

  bool anyEntryResource(bool Function(Resource) test) =>
      _bundle.total != null &&
      _bundle.total! > 0 &&
      (_bundle.entry?.map((entry) => entry.resource).whereType<Resource>().any(test) ?? false);
}
