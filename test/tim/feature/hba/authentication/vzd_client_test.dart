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

import 'package:fluffychat/tim/feature/hba/authentication/vzd_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

void main() {
  test('can fetch challenge path from vzd', () async {
    final mockClient = MockClient((request) async {
      if (request.url.path != "/vzd-owner-authenticate/") {
        return Response("", 404);
      }

      return Response(
          """{"status": 302, "location": "https://challenge-path?foo=bar&bar=baz"}""",
          200,);
    });

    final sut = VzdClient(mockClient);
    final challengePath = await sut.getChallengePath();

    expect(challengePath, equals('https://challenge-path?foo=bar&bar=baz'));
  });

  test('getChallengePath should throw if status is not 200', () async {
    final mockClient = MockClient((request) async {
      return Response("", 500);
    });

    final sut = VzdClient(mockClient);

    await expectLater(sut.getChallengePath(), throwsA(isA<Exception>()));
  });

  test('authToToken should throw if status is not 200', () async {
    final mockClient = MockClient((request) async {
      return Response("", 500);
    });

    final sut = VzdClient(mockClient);

    await expectLater(sut.authCodeToToken("code", "state", "http://challenge"),
        throwsA(isA<Exception>()),);
  });

  test('authToToken', () async {
    late Map<String, String> params;
    late String host;

    final mockClient = MockClient((request) async {
      host = request.url.host;
      params = request.url.queryParameters;

      return Response(authCodeToTokenResponseBody, 200);
    });

    final sut = VzdClient(mockClient);

    final token =
        await sut.authCodeToToken("http://challenge", "code", "state");

    expect(token.expiresIn, equals(86400));
    expect(token.accessToken, startsWith("ey"));
    expect(host, equals("challenge"));
    expect(params["code"], equals("code"));
    expect(params["state"], equals("state"));
  });
}

const authCodeToTokenResponseBody = """
{"access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJpc3MiOiJodHRwczovL2ZoaXItZGlyZWN0b3J5LXJlZi52emQudGktZGllbnN0ZS5kZS9vd25lci1hdXRoZW50aWNhdGUiLCJhdWQiOiJodHRwczovL2ZoaXItZGlyZWN0b3J5LXJlZi52emQudGktZGllbnN0ZS5kZS9vd25lciIsInN1YiI6IjEtSEJBLVRlc3RrYXJ0ZS04ODMxMTAwMDAxMjkwODMiLCJpYXQiOjE2ODMwMTY4MDEsImV4cCI6MTY4MzEwMzIwMX0.pcdVisTWu1jSms2zKh6jNbN4ZXdSuFiorP5ugJlsV_9TcljO1C6D3rYwkcf7yPVoYVjtJc6BW3_K3kOCTqthbw","token_type":"bearer","expires_in":86400}
""";
