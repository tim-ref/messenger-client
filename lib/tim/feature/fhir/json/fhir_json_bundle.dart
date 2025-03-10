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

import 'package:fluffychat/tim/feature/fhir/json/fhir_json_endpoint.dart';
import 'package:fluffychat/tim/feature/fhir/json/fhir_json_practitioner_role.dart';
import 'package:matrix/matrix.dart';

// JSON keys for FHIR Bundle resources
const _total = 'total';
const _entry = 'entry';
const _resource = 'resource';

/// Contains functions for FHIR [Bundle](https://hl7.org/fhir/R4/bundle.html) resources in JSON.
class BundleJson {
  static bool anyEntryResource(dynamic bundle, bool Function(dynamic) test) =>
      bundle[_total] > 0 && bundle[_entry].map((entry) => entry[_resource]).any(test);

  static Iterable<dynamic> whereEntryResource(dynamic bundle, bool Function(dynamic) test) =>
      bundle[_entry].map((entry) => entry[_resource]).where(test);

  /// Extract the first PractitionerRole from the Bundle in [bundle].
  static Map<String, dynamic> getFirstPractitionerRole(Map<String, dynamic> bundle) {
    try {
      return whereEntryResource(bundle, PractitionerRoleJson.isPractitionerRoleResource).first;
    } catch (e, s) {
      Logs().e('No PractitionerRole in Entries', e, s);
      rethrow;
    }
  }

  /// Extract a user's first TIM Endpoint from the Bundle in [json].
  static Map<String, dynamic>? getFirstTimEndpointWithAddress(
    Map<String, dynamic> json, {
    required String address,
  }) {
    try {
      final endpoints = whereEntryResource(
        json,
        (resource) => EndpointJson.isActiveTimEndpointWithAddress(resource, address: address),
      );
      return endpoints.isNotEmpty ? endpoints.first : null;
    } catch (ignored) {
      return null;
    }
  }
}
