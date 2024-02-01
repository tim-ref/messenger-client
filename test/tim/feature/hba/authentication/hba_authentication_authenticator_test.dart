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

import 'package:fluffychat/tim/feature/hba/authentication/authenticator.dart';
import 'package:fluffychat/tim/feature/hba/authentication/hba_authentication_authenticator.dart';
import 'package:fluffychat/tim/feature/hba/authentication/vzd_client.dart';
import 'package:fluffychat/tim/shared/tim_auth_token.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'hba_authentication_authenticator_test.mocks.dart';

final aValidToken = TimAuthToken(
    accessToken: "accessToken", tokenType: "tokenType", expiresIn: 123);

@GenerateMocks([Authenticator, VzdClient])
void main() {
  late final MockAuthenticator authenticator;
  late final MockVzdClient vzdClient;
  late final HbaAuthenticationAuthenticator sut;

  setUpAll(() {
    vzdClient = MockVzdClient();
    authenticator = MockAuthenticator();
    sut = HbaAuthenticationAuthenticator(authenticator, vzdClient);
  });

  test("hba auth authenticator flow", () async {
    when(vzdClient.getChallengePath()).thenAnswer((_) async =>
        "http://challengeResponse?state=state&redirect_uri=redirect_uri");
    when(authenticator.waitForAuthCode())
        .thenAnswer((_) async => "the auth code");
    when(vzdClient.authCodeToToken(any, any, any))
        .thenAnswer((_) async => aValidToken);

    final token = await sut.getHbaToken();

    expect(token, equals(aValidToken));

    verify(authenticator.openAuthenticator(
        "http://challengeResponse?state=state&redirect_uri=redirect_uri"));
    verify(vzdClient.authCodeToToken("redirect_uri", "the auth code", "state"));
  });
}
