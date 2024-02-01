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

import 'package:fluffychat/tim/feature/fhir/search/fhir_search_constants.dart';

class FhirQueryBuilder {
  static String findOwnerByMxidAndTelematikId(String mxid, String telematikId) {
    return '_format=json&practitioner.active=true&practitioner.identifier=${Uri.encodeComponent(telematikId)}&endpoint.address=${Uri.encodeComponent(mxid)}&_include=PractitionerRole:endpoint';
  }

  static String findOwnerByTelematikId(String telematikId) {
    return '_format=json&practitioner.active=true&practitioner.identifier=${Uri.encodeComponent(telematikId)}&_include=PractitionerRole:endpoint';
  }

  static String buildPractitionerRoleQuery(Map<String, String> params) {
    if (params.isEmpty) {
      return '';
    }
    final paramsList = [];
    params.forEach((key, value) {
      paramsList.add('$key$containsModifier=${_encode(value)}');
    });
    final defaultParams = _getPractitionerRoleDefaults();
    final practitionerParams = paramsList.join('&');

    return '$defaultParams&$practitionerParams';
  }

  static String buildHealthcareServiceQuery(Map<String, String> params) {
    if (params.isEmpty) {
      return '';
    }
    final paramsList = [];
    params.forEach((key, value) {
      paramsList.add('$key$containsModifier=${_encode(value)}');
    });
    final defaultParams = _getHealthcareServiceDefaults();
    final healthcareServiceParams = paramsList.join('&');

    return '$defaultParams&$healthcareServiceParams';
  }

  static String _getPractitionerRoleDefaults() {
    final defaults = List.of(defaultQueryParams);
    defaults.addAll(practitionerRoleDefaultQueryParams);

    return defaults.join('&');
  }

  static String _getHealthcareServiceDefaults() {
    final defaults = List.of(defaultQueryParams);
    defaults.addAll(healthcareServiceDefaultQueryParams);
    return defaults.join('&');
  }

  static String _encode(String param) => Uri.encodeComponent(param.trim());
}
