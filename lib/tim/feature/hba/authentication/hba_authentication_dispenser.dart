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
import 'dart:io';

import 'package:matrix/matrix.dart';
import 'package:http/http.dart' as http;

import 'package:fluffychat/tim/feature/hba/authentication/hba_authentication.dart';
import 'package:fluffychat/utils/future_with_retries.dart';
import 'package:fluffychat/tim/shared/tim_auth_token.dart';
import 'package:fluffychat/tim/tim_constants.dart';

// use the token dispenser to get a hba token
class HbaTokenDispenserAuthentication implements HbaAuthentication {
  final http.Client _client;
  final Duration _timeout;

  HbaTokenDispenserAuthentication(this._client,
      {Duration timeout = const Duration(seconds: 30),})
      : _timeout = timeout;

  @override
  Future<TimAuthToken> getHbaToken() async {
    const tokenDispenserUrl = String.fromEnvironment(defaultTokenDispenserUrl);
    return getHbaTokenFromUrl(tokenDispenserUrl);
  }

  @override
  Future<TimAuthToken> getHbaTokenFromUrl(String url) async {
    const username = String.fromEnvironment(tokenDispenserUser);
    const password = String.fromEnvironment(tokenDispenserPassword);
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final response = await runRequestWithRetries(() {
      Logs().d("Fetching hba token..");
      return _client.get(
        Uri.parse(url),
        headers: <String, String>{
          HttpHeaders.authorizationHeader: basicAuth,
        },
      ).timeout(_timeout);
    });

    final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
    try {
      return TimAuthToken(
        accessToken: decodedResponse['access_token'],
        expiresIn: decodedResponse['expires_in'],
        matrixServerName: null,
        tokenType: 'bearer',
      );
    } catch (e) {
      throw FormatException("could not read json body $decodedResponse");
    }
  }
}
