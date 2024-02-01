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

import 'package:http/http.dart' as http;

import 'package:fluffychat/tim/shared/tim_auth_token.dart';

// this is the variant for local testing when the proxy is running on a separate port
// final authenticateUri = "${Uri.base.scheme}://${Uri.base.host}:8080/vzd-owner-authenticate/";

// this is the productive variant
final authUri =
    "${Uri.base.scheme}://${Uri.base.host}:${Uri.base.port}/vzd-owner-authenticate/";

// this is for testing against the version from EU
// final authenticateUri = "https://tim-client.eu.timref.akquinet.nx2.dev/vzd-owner-authenticate/";

class VzdClient {
  final http.Client _client;

  VzdClient(this._client);

  Future<String> getChallengePath() async {
    final response = await _client.get(Uri.parse(authUri));
    if (response.statusCode != 200) {
      throw HttpException("unexpected status ${response.statusCode}");
    }

    final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    if (decodedResponse["status"] != 302) {
      throw HttpException(
          "unexpected proxy status ${decodedResponse["status"]}");
    }

    return decodedResponse["location"];
  }

  Future<TimAuthToken> authCodeToToken(
      String challengePath, String authCode, String state) async {
    final tokenUri = "$challengePath?code=$authCode&state=$state";
    final response = await _client.get(Uri.parse(tokenUri));
    if (response.statusCode != 200) {
      throw HttpException("unexpected status ${response.statusCode}");
    }

    final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
    try {
      return TimAuthToken(
        accessToken: decodedResponse['access_token'],
        tokenType: 'bearer',
        matrixServerName: null,
        expiresIn: decodedResponse['expires_in'],
      );
    } catch (e) {
      throw FormatException("Could not read json body $decodedResponse");
    }
  }
}
