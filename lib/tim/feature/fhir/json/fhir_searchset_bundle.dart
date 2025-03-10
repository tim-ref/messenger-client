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

import 'package:fluffychat/tim/feature/fhir/json/fhir_json_bundle.dart';

/// Wraps a searchset Bundle.
class FhirSearchsetBundle {
  final Map<String, dynamic> _queryResponse;

  /// First PractitionerRole in [_queryResponse].
  late final Map<String, dynamic>? practitionerRole;

  /// The Matrix user's first TIM Endpoint in [_queryResponse].
  late final Map<String, dynamic>? timEndpoint;

  FhirSearchsetBundle.fromJson(
    String mxid,
    this._queryResponse,
  ) {
    if (_queryResponse['total'] > 0) {
      practitionerRole = BundleJson.getFirstPractitionerRole(_queryResponse);
      timEndpoint = BundleJson.getFirstTimEndpointWithAddress(_queryResponse, address: mxid);
    }
  }

  bool anyEntryResource(bool Function(dynamic) test) =>
      BundleJson.anyEntryResource(_queryResponse, test);
}
