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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fluffychat/tim/feature/fhir/fhir_config.dart';
import 'package:fluffychat/tim/feature/hba/authentication/hba_authentication.dart';
import 'package:fluffychat/tim/shared/matrix/tim_matrix_client.dart';
import 'package:fluffychat/tim/shared/tim_auth_token.dart';
import 'package:fluffychat/tim/shared/tim_rest_repository.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';

import 'tim_auth_token_with_expiry_timestamp.dart';

/// Fetches and caches [TimAuthToken]s
class TimAuthRepository extends TimRestRepository {
  final TimMatrixClient _timClient;
  final FhirConfig _fhirConfig;
  final HbaAuthentication _hbaAuthentication;

  TimAuthTokenWithExpiryTimestamp? _cachedFhirToken;

  TimAuthRepository(
    http.Client httpClient,
    this._timClient,
    this._fhirConfig,
    this._hbaAuthentication,
  ) : super(httpClient);

  Future<TimAuthToken> getOpenIdToken() async {
    try {
      final host = _timClient.homeserver.host;
      final headers = <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ${_timClient.accessToken}',
      };
      final response = await post(
        Uri.parse(
          'https://$host/_matrix/client/v3/user/${_timClient.userID}/openid/request_token',
        ),
        headers: headers,
        body: jsonEncode({}),
      );
      return TimAuthToken.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      Logs().e('Error fetching OpenId-Token', error, stacktrace);
      rethrow;
    }
  }

  /// Return a cached FHIR token, or fetch, cache and return a new one if there is no cached token.
  Future<TimAuthToken> getFhirToken() async {
    final isCachedTokenValid = _cachedFhirToken?.isExpired() == false;
    if (isCachedTokenValid) {
      return _cachedFhirToken!.token;
    } else {
      final newFhirToken = await _getFhirToken();
      _cachedFhirToken = TimAuthTokenWithExpiryTimestamp.from(newFhirToken);
      return newFhirToken;
    }
  }

  Future<TimAuthToken> _getFhirToken() async {
    try {
      final matrixOpenIdToken = await getOpenIdToken();
      final uri = Uri.parse(
        '${_fhirConfig.host}${_fhirConfig.authBase}?mxId=${matrixOpenIdToken.matrixServerName}',
      );
      final headers = <String, String>{
        'X-Matrix-OpenID-Token': matrixOpenIdToken.accessToken,
      };
      final response = await get(
        uri,
        headers: headers,
      );
      return TimAuthToken.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      Logs().e('Error fetching Fhir-Token', error, stacktrace);
      rethrow;
    }
  }

  Future<TimAuthToken> getHbaToken() {
    return _hbaAuthentication.getHbaToken();
  }

  Future<TimAuthToken> getHbaTokenFromUrl(String url) {
    return _hbaAuthentication.getHbaTokenFromUrl(url);
  }
}
