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

import 'package:fluffychat/tim/feature/fhir/fhir_config.dart';
import 'package:fluffychat/tim/feature/hba/authentication/hba_authentication.dart';
import 'package:fluffychat/tim/shared/errors/tim_bad_state_exception.dart';
import 'package:fluffychat/tim/shared/tim_auth_repository.dart';
import 'package:fluffychat/tim/shared/tim_auth_token.dart';
import 'package:fluffychat/tim/shared/tim_auth_token_with_expiry_timestamp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../feature/contact_approval/contact_approval_repository_test.mocks.dart';
import '../share_room_archive_test.mocks.dart';
import 'tim_auth_repository_test.mocks.dart';

@GenerateMocks([FhirConfig, HbaAuthentication])
void main() {
  late final MockClient httpClient;
  late final MockTimMatrixClient timClient;
  late final MockFhirConfig fhirConfig;
  late final MockHbaAuthentication hbaAuthentication;

  late TimAuthRepository repo;

  const host = 'https://matrixServerName';
  const mxid = '@eins:matrixServerName';

  late Uri homeserver;

  setUpAll(() {
    httpClient = MockClient();
    timClient = MockTimMatrixClient();
    fhirConfig = MockFhirConfig();
    hbaAuthentication = MockHbaAuthentication();

    when(fhirConfig.host).thenReturn('http://localhost');
    when(fhirConfig.authBase).thenReturn('/tim-authenticate');

    when(timClient.userID).thenReturn(mxid);
    when(timClient.accessToken).thenReturn('ogAccessToken');
  });

  setUp(() {
    reset(httpClient);

    repo = TimAuthRepository(httpClient, timClient, fhirConfig, hbaAuthentication);

    homeserver = Uri.parse(host);
    when(timClient.homeserver).thenReturn(homeserver);
  });

  test('returns correct openid token', () async {
    // given
    final expectedUri =
        Uri.parse('https://${homeserver.host}/_matrix/client/v3/user/$mxid/openid/request_token');
    final expectedHeaders = _expectedOpenIdHeaders();
    final expectedBody = jsonEncode({});

    when(
      httpClient.post(expectedUri, headers: expectedHeaders, body: expectedBody),
    ).thenAnswer((_) async => http.Response(jsonEncode(_expectedOpenIdToken()), 200));

    // when
    final token = await repo.getOpenIdToken();

    // then
    expect(token, equals(_expectedOpenIdToken()));
  });

  group('FHIR tokens', () {
    test('returns correct FHIR token', () async {
      // given
      final expectedMatrixTokenUri =
          Uri.parse('https://${homeserver.host}/_matrix/client/v3/user/$mxid/openid/request_token');
      final expectedFhirTokenUri =
          Uri.parse('http://localhost/tim-authenticate?mxId=matrixServerName');

      when(
        httpClient.post(
          expectedMatrixTokenUri,
          headers: _expectedOpenIdHeaders(),
          body: jsonEncode({}),
        ),
      ).thenAnswer((_) async => http.Response(jsonEncode(_expectedOpenIdToken()), 200));
      when(
        httpClient.get(expectedFhirTokenUri, headers: _expectedFhirHeaders()),
      ).thenAnswer((_) async => http.Response(jsonEncode(_expectedFhirToken()), 200));

      // when
      final fhirToken = await repo.getFhirToken();

      // then
      expect(fhirToken, equals(_expectedFhirToken()));
    });

    test('should return a cached FHIR token if it exists', () async {
      // given
      when(httpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(jsonEncode(_expectedOpenIdToken()), 200));
      when(httpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(_expectedFhirToken()), 200));

      // when
      final fhirToken1 = await repo.getFhirToken();
      final fhirToken2 = await repo.getFhirToken();

      // then
      expect(fhirToken2, same(fhirToken1));
      verify(httpClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should fetch a new FHIR token if the cached token is expired', () async {
      // given
      when(httpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(jsonEncode(_expectedOpenIdToken()), 200));
      when(httpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(_expiredFhirToken()), 200));

      expect(TimAuthTokenWithExpiryTimestamp.from(_expiredFhirToken()).isExpired(), isTrue);

      // when
      final fhirToken1 = await repo.getFhirToken();
      final fhirToken2 = await repo.getFhirToken();

      // then
      expect(fhirToken2, isNot(same(fhirToken1)));
      verify(httpClient.get(any, headers: anyNamed('headers'))).called(2);
    });

    test('handles rest error correctly for getFhirToken', () async {
      // given
      final expectedMatrixTokenUri =
          Uri.parse('https://${homeserver.host}/_matrix/client/v3/user/$mxid/openid/request_token');
      final expectedFhirTokenUri =
          Uri.parse('http://localhost/tim-authenticate?mxId=matrixServerName');

      when(
        httpClient.post(expectedMatrixTokenUri,
            headers: _expectedOpenIdHeaders(), body: jsonEncode({}),),
      ).thenAnswer((_) async => http.Response(jsonEncode(_expectedOpenIdToken()), 200));
      when(
        httpClient.get(expectedFhirTokenUri, headers: _expectedFhirHeaders()),
      ).thenAnswer((_) async => http.Response('', 403));

      // expect
      final forbiddenMatcher = isA<HttpException>().having((e) => e.message, "message",
          contains("Unexpected status 403 for call to URI: $expectedFhirTokenUri"),);
      expectLater(repo.getFhirToken(), throwsA(forbiddenMatcher));
    });
  });

  test('returns correct hbaAuthToken', () async {
    // given
    final timAuthToken = TimAuthToken(
      accessToken: 'accessToken',
      tokenType: 'tokenType',
      expiresIn: 3600,
    );
    when(hbaAuthentication.getHbaToken()).thenAnswer((_) async => timAuthToken);

    // expect
    expectLater(await repo.getHbaToken(), equals(timAuthToken));
  });

  test('handles rest error correctly for getOpenIdToken', () async {
    // given
    final expectedUri =
        Uri.parse('https://${homeserver.host}/_matrix/client/v3/user/$mxid/openid/request_token');
    final expectedHeaders = _expectedOpenIdHeaders();
    final expectedBody = jsonEncode({});

    when(timClient.homeserver).thenReturn(homeserver);
    when(timClient.userID).thenReturn(mxid);

    when(
      httpClient.post(expectedUri, headers: expectedHeaders, body: expectedBody),
    ).thenAnswer((_) async => http.Response('{}', 401));

    //expect
    final unauthorizedMatcher = isA<HttpException>().having((e) => e.message, "message",
        contains("Unexpected status 401 for call to URI: $expectedUri"),);
    expectLater(repo.getOpenIdToken(), throwsA(unauthorizedMatcher));
  });

  test('should correctly handle null userID error', () async {
    // given
    when(timClient.userID).thenThrow(TimBadStateException('userID is null'));

    // expect
    expectLater(repo.getOpenIdToken(), throwsA(isA<TimBadStateException>()));
  });
}

Map<String, String> _expectedOpenIdHeaders() => <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      HttpHeaders.authorizationHeader: 'Bearer ogAccessToken',
    };

Map<String, String> _expectedFhirHeaders() => <String, String>{
      'X-Matrix-OpenID-Token': 'accessToken',
    };

TimAuthToken _expectedOpenIdToken() => TimAuthToken(
      accessToken: 'accessToken',
      tokenType: 'tokenType',
      matrixServerName: 'matrixServerName',
      expiresIn: 1337,
    );

TimAuthToken _expectedFhirToken() => TimAuthToken(
      accessToken: 'fhirToken',
      tokenType: 'tokenType',
      expiresIn: 1910,
    );

TimAuthToken _expiredFhirToken() => TimAuthToken(
      accessToken: 'fhirToken',
      tokenType: 'tokenType',
      expiresIn: -1910,
    );
