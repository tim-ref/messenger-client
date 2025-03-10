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

import 'package:fluffychat/tim/feature/fhir/json/fhir_json_extensions.dart';

// JSON keys for FHIR Endpoint resources.
const _resourceType = 'resourceType';
const _status = 'status';
const _connectionType = 'connectionType';
const _code = 'code';
const _address = 'address';
const _extension = 'extension';

// JSON values for FHIR Endpoint resources.
const _endpoint = 'Endpoint';
const _active = 'active';
const _tim = 'tim';

/// Contains functions for FHIR [Endpoint](https://www.hl7.org/fhir/R4/endpoint.html) resources in JSON.
class EndpointJson {
  static bool isActiveTimEndpointWithAddress(dynamic resource, {required String address}) {
    return switch (resource) {
      {
        _resourceType: _endpoint,
        _status: _active,
        _connectionType: {_code: _tim},
        _address: final addr,
      } =>
        addr == address,
      _ => false,
    };
  }

  static bool isActiveTimEndpointHiddenFromInsureesWithAddress(dynamic resource,
      {required String address}) {
    return switch (resource) {
      {
        _resourceType: _endpoint,
        _status: _active,
        _connectionType: {_code: _tim},
        _address: final addr,
        _extension: final List<dynamic> extensions
      } =>
        extensions.any(ExtensionsJson.isHideEndpointExtension) && addr == address,
      _ => false,
    };
  }

  /// Copy and set 'status' to 'active'.
  static Map<String, dynamic> copyAndActivateEndpoint(Map<String, dynamic> endpoint) {
    final newEndpoint = {...endpoint};
    newEndpoint[_status] = _active;
    return newEndpoint;
  }
}
