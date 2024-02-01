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

import 'package:matrix/matrix.dart';

import 'package:fluffychat/tim/feature/hba/authentication/hba_authentication.dart';
import 'package:fluffychat/tim/feature/hba/authentication/authenticator.dart';
import 'package:fluffychat/tim/feature/hba/authentication/vzd_client.dart';
import 'package:fluffychat/tim/shared/tim_auth_token.dart';

// Use the authenticator app flow to get an HBA token.
class HbaAuthenticationAuthenticator implements HbaAuthentication {
  final Authenticator _authenticator;
  final VzdClient _vzdClient;

  HbaAuthenticationAuthenticator(this._authenticator, this._vzdClient);

  @override
  Future<TimAuthToken> getHbaToken() async {
    Logs().i('Get HBA token via authenticator app');

    final String challengePath = await _vzdClient.getChallengePath();

    Logs().i("Got ChallengePath: $challengePath");

    _authenticator.openAuthenticator(challengePath);

    final authCode = await _authenticator.waitForAuthCode();

    Logs().i("Got authCode '$authCode'");

    final parsed = _parseChallengePath(challengePath);

    Logs()
        .i("Got redirect path ${parsed.redirectUri}and state ${parsed.state}");

    return await _vzdClient.authCodeToToken(
      parsed.redirectUri,
      authCode,
      parsed.state,
    );
  }

  @override
  Future<TimAuthToken> getHbaTokenFromUrl(String _) {
    return getHbaToken();
  }
}

ParsedChallengePath _parseChallengePath(String challengePath) {
  final parsed = Uri.parse(challengePath);
  return ParsedChallengePath(
    parsed.queryParameters['redirect_uri']!,
    parsed.queryParameters['state']!,
  );
}

class ParsedChallengePath {
  final String redirectUri;
  final String state;

  const ParsedChallengePath(this.redirectUri, this.state);
}
