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
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

import 'package:fluffychat/tim/feature/hba/authentication/hba_authentication_dispenser.dart';

void main() {
  test('can fetch token from dispenser', () async {
    final mockClient = MockClient((request) async {
      if (request.url.path != "/2/dispenseToken") {
        return Response("", 404);
      }

      return Response(
          """{"access_token":"token","token_type":"bearer","expires_in":86400}""",
          200,
          headers: {'content-type': 'application/json'},);
    });

    final sut = HbaTokenDispenserAuthentication(mockClient);
    final token = await sut.getHbaToken();

    expect(token, isNotNull);
    expect(token.accessToken, equals("token"));
    expect(token.expiresIn, equals(86400));
  });

  test('good error message on unexpected http status code', () async {
    final mockClient = MockClient((request) async {
      return Response("", 404);
    });

    final sut = HbaTokenDispenserAuthentication(mockClient);

    final matcher = isA<HttpException>()
        .having((e) => e.message, "message", equals("unexpected status 404"));
    await expectLater(sut.getHbaToken(), throwsA(matcher));
  });

  test('good error message on unexpected payload', () async {
    final mockClient = MockClient((request) async {
      return Response("invalid json", 200);
    });

    final sut = HbaTokenDispenserAuthentication(mockClient);

    final matcher = isA<FormatException>()
        .having((e) => e.source, "body", contains("invalid json"));
    await expectLater(sut.getHbaToken(), throwsA(matcher));
  });

  test('good error message on missing fields', () async {
    final mockClient = MockClient((request) async {
      return Response("""{"expires_in": 123}""", 200);
    });

    final sut = HbaTokenDispenserAuthentication(mockClient);

    final matcher = isA<FormatException>()
        .having((e) => e.message, "message", contains("""expires_in"""));
    await expectLater(sut.getHbaToken(), throwsA(matcher));
  });

  test('should have timeout', () async {
    final mockClient = MockClient((request) {
      return Future.delayed(
        const Duration(seconds: 1),
        () => Response("", 200),
      );
    });

    final sut = HbaTokenDispenserAuthentication(
      mockClient,
      timeout: const Duration(milliseconds: 1000),
    );

    await expectLater(sut.getHbaToken(), throwsA(isA<TimeoutException>()));
  }, timeout: const Timeout(Duration(seconds: 30)),);
}
