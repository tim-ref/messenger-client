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

import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:fluffychat/tim/feature/fhir/dto/create_endpoint.dart';
import 'package:fluffychat/tim/feature/fhir/dto/resource_type.dart';
import 'package:fluffychat/tim/feature/fhir/fhir_query_builder.dart';
import 'package:fluffychat/tim/feature/fhir/fhir_repository.dart';
import 'package:fluffychat/tim/feature/fhir/json/fhir_json_endpoint.dart';
import 'package:fluffychat/tim/feature/fhir/json/fhir_json_extensions.dart';
import 'package:fluffychat/tim/feature/fhir/json/fhir_json_practitioner_role.dart';
import 'package:fluffychat/tim/feature/fhir/json/fhir_searchset_bundle.dart';
import 'package:fluffychat/tim/feature/fhir/settings/fhir_practitioner_visibility.dart';
import 'package:fluffychat/tim/shared/tim_auth_repository.dart';
import 'package:fluffychat/tim/shared/tim_auth_state.dart';
import 'package:fluffychat/tim/shared/tim_auth_token.dart';
import 'package:matrix/matrix.dart';

class FhirAccountService {
  final TimAuthRepository _authRepository;
  final FhirRepository _fhirRepository;
  final TimAuthState _authState;

  FhirAccountService(
    this._authRepository,
    this._fhirRepository,
    this._authState,
  );

  Future<TimAuthToken> hbaAccessToken() async {
    var hbaToken = _authState.hbaToken;
    if (hbaToken == null || !_authState.hbaTokenValid()) {
      hbaToken = await _authRepository.getHbaToken();
      _authState.hbaToken = hbaToken;
    }
    return hbaToken;
  }

  updateHbaAccessToken(String url) async {
    _authState.hbaToken = await _authRepository.getHbaTokenFromUrl(url);
  }

  /// Does Matrix user with [mxid] have any active TIM Endpoints without the extension 'endpointVisibility: hide-versicherte'?
  /// [AF_10376 - Practitioner - FHIR-VZD Sichtbarkeit für Versicherte setzen](https://gemspec.gematik.de/docs/gemSpec/gemSpec_TI-M_Pro/gemSpec_TI-M_Pro_V1.0.1/#AF_10376)
  Future<PractitionerVisibility?> fetchPractitionerVisibility(
    TimAuthToken token,
    String mxid,
  ) async {
    Logs().i('Fetching FHIR visibility for mxid: $mxid');
    try {
      final JWT(payload: {'sub': telematikId}) = JWT.decode(token.accessToken);
      Logs().d("using TelematikId $telematikId to get visibility for mxid $mxid");
      final query = FhirQueryBuilder.findOwnerByMxidAndTelematikId(mxid, telematikId!);
      final response = await _fhirRepository.searchPractitionerRoleAsOwner(query, token);
      final bundle = FhirSearchsetBundle.fromJson(mxid, response);
      final hasActiveTimEndpoints = bundle.anyEntryResource(
        (resource) => EndpointJson.isActiveTimEndpointWithAddress(resource, address: mxid),
      );
      if (hasActiveTimEndpoints == false) {
        return PractitionerVisibility.none();
      } else {
        final hasActiveTimEndpointsHiddenFromInsurees = bundle.anyEntryResource(
          (resource) => EndpointJson.isActiveTimEndpointHiddenFromInsureesWithAddress(
            resource,
            address: mxid,
          ),
        );
        return PractitionerVisibility(
          isGenerallyVisible: true,
          isVisibleExceptFromInsurees: hasActiveTimEndpointsHiddenFromInsurees,
        );
      }
    } catch (e, s) {
      Logs().e('Error getting Fhir visibility', e, s);
      rethrow;
    }
  }

  /// Set Matrix user's TIM Endpoint status, returns current visibility.
  Future<bool> setUsersVisibility({
    required bool isVisible,
    required String owningPractitionersMxid,
    required String endpointName,
    required TimAuthToken token,
  }) async {
    Logs().i('Setting FHIR visibility for mxid \'$owningPractitionersMxid\' to \'$isVisible\'');
    final JWT(payload: {'sub': telematikId}) = JWT.decode(token.accessToken);
    final query = FhirQueryBuilder.findOwnerByTelematikId(telematikId);
    Logs().d("using telematikId $telematikId to search owner for mxId $owningPractitionersMxid");
    final searchResponse = await _fhirRepository.searchPractitionerRoleAsOwner(query, token);
    final bundle = FhirSearchsetBundle.fromJson(owningPractitionersMxid, searchResponse);
    if (bundle.anyEntryResource(PractitionerRoleJson.isPractitionerRoleResource)) {
      try {
        if (isVisible) {
          if (bundle.timEndpoint == null) {
            await _addActiveEndpoint(owningPractitionersMxid, endpointName, token, bundle);
          } else {
            await _activateEndpoint(bundle.timEndpoint!, token);
          }
        } else {
          if (bundle.timEndpoint != null) {
            final endpointId = bundle.timEndpoint!['id'];
            await _removeEndpoint(bundle, endpointId, token);
          }
        }
        return isVisible;
      } catch (e, s) {
        Logs().e('Error Setting Fhir Visibility', e, s);
        rethrow;
      }
    }
    return !isVisible;
  }

  /// Add or remove the endpointVisibility extension from the user's TIM Endpoint. Returns current visibility.
  /// Changes nothing if Practitioner has not active TIM Endpoints.
  /// [AF_10376 - Practitioner - FHIR-VZD Sichtbarkeit für Versicherte setzen](https://gemspec.gematik.de/docs/gemSpec/gemSpec_TI-M_Pro/gemSpec_TI-M_Pro_V1.0.1/#AF_10376)
  Future<bool> setUsersVisibilityTowardsInsurees({
    required bool shouldBeVisible,
    required String owningPractitionersMxid,
    required String endpointName,
    required TimAuthToken token,
  }) async {
    Logs()
        .i('Setting FHIR visibility for mxid \'$owningPractitionersMxid\' to \'$shouldBeVisible\'');
    final JWT(payload: {'sub': telematikId}) = JWT.decode(token.accessToken);
    final query = FhirQueryBuilder.findOwnerByTelematikId(telematikId);
    Logs().d("using telematikId $telematikId to search owner for mxId $owningPractitionersMxid");
    final searchResponse = await _fhirRepository.searchPractitionerRoleAsOwner(query, token);
    final bundle = FhirSearchsetBundle.fromJson(owningPractitionersMxid, searchResponse);
    if (bundle.anyEntryResource(PractitionerRoleJson.isPractitionerRoleResource)) {
      try {
        if (bundle.timEndpoint != null &&
            EndpointJson.isActiveTimEndpointWithAddress(
              bundle.timEndpoint,
              address: owningPractitionersMxid,
            )) {
          final modifiedEndpoint = shouldBeVisible
              ? ExtensionsJson.copyAndRemoveHideEndpointExtension(bundle.timEndpoint!)
              : ExtensionsJson.copyAndAddHideEndpointExtension(bundle.timEndpoint!);
          await _fhirRepository.updateResource(
            ResourceType.Endpoint,
            modifiedEndpoint['id'],
            token,
            jsonEncode(modifiedEndpoint),
          );
          return shouldBeVisible;
        } else {
          return false;
        }
      } catch (e, s) {
        Logs().e('Error Setting Fhir Visibility', e, s);
        rethrow;
      }
    }
    return !shouldBeVisible;
  }

  /// Create and save an active FHIR Endpoint.
  Future<void> _addActiveEndpoint(
    String mxid,
    String endpointName,
    TimAuthToken token,
    FhirSearchsetBundle bundle,
  ) async {
    final newEndpoint = newEndpointResource(address: mxid, name: endpointName);
    try {
      final endpointCreationResponse = await _fhirRepository.createResource(
        ResourceType.Endpoint,
        token,
        jsonEncode(newEndpoint.toJson()),
      );
      if (bundle.practitionerRole == null) {
        throw Exception('Cannot update PractitionerRole because old PractitionerRole is null');
      }
      final updatedPractitionerRole = PractitionerRoleJson.copyAndAddEndpointReference(
        bundle.practitionerRole!,
        endpointCreationResponse['id'],
      );
      await _updatePractitionerRole(updatedPractitionerRole, token);
    } catch (e, s) {
      Logs().e('Error creating new Endpoint', e, s);
      rethrow;
    }
  }

  /// Activate and save an existing FHIR Endpoint.
  Future<void> _activateEndpoint(Map<String, dynamic> endpoint, TimAuthToken token) async {
    final activeEndpoint = EndpointJson.copyAndActivateEndpoint(endpoint);
    await _fhirRepository.updateResource(
      ResourceType.Endpoint,
      activeEndpoint['id'],
      token,
      jsonEncode(activeEndpoint),
    );
  }

  /// Removes any references to the Endpoint from the PractitionerRole and deletes the Endpoint.
  Future<void> _removeEndpoint(
    FhirSearchsetBundle bundle,
    String endpointId,
    TimAuthToken token,
  ) async {
    if (bundle.practitionerRole == null) {
      throw Exception('Cannot update PractitionerRole because old PractitionerRole is null');
    }
    final updatedPractitionerRole =
        PractitionerRoleJson.copyAndRemoveEndpointReference(bundle.practitionerRole!, endpointId);
    await _updatePractitionerRole(updatedPractitionerRole, token);
    try {
      await _fhirRepository.deleteResource(
        ResourceType.Endpoint,
        endpointId,
        token,
      );
    } catch (e, s) {
      Logs().e('Error removing Endpoint', e, s);
      await _revertPractitionerRole(bundle.practitionerRole!, token);
      rethrow;
    }
  }

  Future<void> _revertPractitionerRole(
    Map<String, dynamic> practitionerRole,
    TimAuthToken token,
  ) async {
    Logs().i('Revert PractitionerRole');
    await _fhirRepository.updateResource(
      ResourceType.PractitionerRole,
      practitionerRole['id'],
      token,
      jsonEncode(practitionerRole),
    );
  }

  /// Saves a FHIR Practitioner Role.
  Future<void> _updatePractitionerRole(
    Map<String, dynamic> practitionerRole,
    TimAuthToken token,
  ) async {
    try {
      await _fhirRepository.updateResource(
        ResourceType.PractitionerRole,
        practitionerRole['id'],
        token,
        jsonEncode(practitionerRole),
      );
    } catch (e, s) {
      Logs().e('Error updating PractitionerRole', e, s);
      rethrow;
    }
  }
}
