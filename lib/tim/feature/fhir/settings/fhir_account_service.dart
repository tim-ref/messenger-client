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

import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:matrix/matrix.dart';

import 'package:fluffychat/tim/feature/fhir/dto/resource_type.dart';
import 'package:fluffychat/tim/feature/fhir/fhir_data_helper.dart';
import 'package:fluffychat/tim/feature/fhir/fhir_query_builder.dart';
import 'package:fluffychat/tim/feature/fhir/fhir_repository.dart';
import 'package:fluffychat/tim/shared/tim_auth_repository.dart';
import 'package:fluffychat/tim/shared/tim_auth_state.dart';
import 'package:fluffychat/tim/shared/tim_auth_token.dart';

class FhirAccountService {
  final TimAuthRepository _authRepository;
  final FhirRepository _fhirRepository;
  final TimAuthState _authState;

  FhirAccountService(
    this._authRepository,
    this._fhirRepository,
    this._authState,
  );

  Future<TimAuthToken> hbaAccess() async {
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

  Future<bool> getFhirVisibility(TimAuthToken token, String mxid) async {
    Logs().i('Fetching FHIR visibility for mxid: $mxid');
    try {
      final jwt = JWT.decode(token.accessToken);
      Logs().d(
          "using TelematikId ${jwt.payload['sub']} to get visibility for mxid $mxid");
      final query = FhirQueryBuilder.findOwnerByMxidAndTelematikId(
        mxid,
        jwt.payload['sub']!,
      );
      final response = await _fhirRepository.ownerSearch(query, token);
      final fhirData = FhirDataHelper(mxid, response);
      return fhirData.isFhirVisible;
    } catch (e, s) {
      Logs().e('Error getting Fhir visibility', e, s);
      rethrow;
    }
  }

  Future<bool> setFhirVisibility(
    bool isVisible,
    String mxid,
    String endpointName,
    TimAuthToken token,
  ) async {
    Logs().i('Setting FHIR visibility for mxid \'$mxid\' to \'$isVisible\'');
    final jwt = JWT.decode(token.accessToken);
    final telematikId = jwt.payload['sub']!;
    final query = FhirQueryBuilder.findOwnerByTelematikId(telematikId);
    Logs().d("using telematikId $telematikId to search owner for mxId $mxid");
    final searchResponse = await _fhirRepository.ownerSearch(query, token);
    final fhirData = FhirDataHelper(mxid, searchResponse);
    if (fhirData.validSearchResponseToSetVisibility()) {
      try {
        if (isVisible && fhirData.oldTimEndpoint == null) {
          await _addTimEndpoint(mxid, endpointName, token, fhirData);
        } else if (isVisible) {
          await _updateEndpoint(fhirData, token);
        } else {
          final endpointId = fhirData.oldTimEndpoint!['id'];
          await _removeEndpoint(fhirData, endpointId, token);
        }
        return isVisible;
      } catch (e, s) {
        Logs().e('Error Setting Fhir Visibility', e, s);
        rethrow;
      }
    }
    return !isVisible;
  }

  Future<void> _addTimEndpoint(
    String mxid,
    String endpointName,
    TimAuthToken token,
    FhirDataHelper fhirData,
  ) async {
    final newEndpoint = fhirData.newEndpoint(mxid: mxid, name: endpointName);
    try {
      final endpointCreationResponse = await _fhirRepository.createResource(
        ResourceType.Endpoint,
        token,
        jsonEncode(newEndpoint.toJson()),
      );
      await _updatePractitionerRole(
        fhirData,
        token,
        endpointCreationResponse['id'],
        visible: true,
      );
    } catch (e, s) {
      Logs().e('Error creating new Endpoint', e, s);
      rethrow;
    }
  }

  Future<void> _updateEndpoint(
    FhirDataHelper fhirData,
    TimAuthToken token,
  ) async {
    final updatedEndpoint = fhirData.getUpdatedEndpoint();
    await _fhirRepository.updateResource(
      ResourceType.Endpoint,
      updatedEndpoint['id'],
      token,
      jsonEncode(updatedEndpoint),
    );
  }

  Future<void> _removeEndpoint(
    FhirDataHelper fhirData,
    endpointId,
    TimAuthToken token,
  ) async {
    await _updatePractitionerRole(
      fhirData,
      token,
      endpointId,
      visible: false,
    );
    try {
      await _fhirRepository.deleteResource(
        ResourceType.Endpoint,
        endpointId,
        token,
      );
    } catch (e, s) {
      Logs().e('Error removing Endpoint', e, s);
      await _revertPractitionerRole(fhirData, token);
      rethrow;
    }
  }

  Future<void> _revertPractitionerRole(
    FhirDataHelper fhirData,
    TimAuthToken token,
  ) async {
    Logs().i('Revert PractitionerRole');
    await _fhirRepository.updateResource(
      ResourceType.PractitionerRole,
      fhirData.oldPractitionerRole!['id'],
      token,
      jsonEncode(fhirData.oldPractitionerRole),
    );
  }

  Future<void> _updatePractitionerRole(
    FhirDataHelper fhirData,
    TimAuthToken token,
    String endpointId, {
    required bool visible,
  }) async {
    final updatedPractitionerRole =
        fhirData.getUpdatedPractitionerRole(visible, endpointId);
    try {
      await _fhirRepository.updateResource(
        ResourceType.PractitionerRole,
        updatedPractitionerRole['id'],
        token,
        jsonEncode(updatedPractitionerRole),
      );
    } catch (e, s) {
      Logs().e('Error updating PractitionerRole', e, s);
      rethrow;
    }
  }
}
