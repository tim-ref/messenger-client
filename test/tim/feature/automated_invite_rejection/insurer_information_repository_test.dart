/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - 2025 akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:convert';

import 'package:fluffychat/tim/feature/automated_invite_rejection/insurer_information_repository.dart';
import 'package:fluffychat/tim/shared/matrix/tim_matrix_client.dart';
import 'package:fluffychat/tim/shared/tim_auth_repository.dart';
import 'package:fluffychat/tim/shared/tim_auth_token.dart';
import 'package:fluffychat/tim/tim_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'insurer_information_repository_test.mocks.dart';

@GenerateMocks([TimAuthRepository, TimMatrixClient])
void main() {
  const fakeHost = 'localhost';
  final fakeToken = TimAuthToken(
    accessToken: 'fakeAccessToken',
    tokenType: 'bearer',
    matrixServerName: fakeHost,
    expiresIn: 3600,
  );

  late MockTimAuthRepository mockAuthRepository;
  late MockTimMatrixClient mockMatrixClient;
  late InsurerInformationRepository repo;

  setUp(() {
    mockAuthRepository = MockTimAuthRepository();
    mockMatrixClient = MockTimMatrixClient();

    when(mockAuthRepository.getOpenIdToken()).thenAnswer((_) async => fakeToken);
    when(mockMatrixClient.homeserver).thenReturn(Uri.parse('https://$fakeHost'));
  });

  group('getServerByIk', () {
    test('returns server name on success', () async {
      const ikNumber = '123456';

      // Use a Fake HTTP client that intercepts the API call.
      final httpClient = MockClient((http.Request request) async {
        // Verify that the constructed URL contains the expected base path.
        expect(request.url.toString(), contains('https://$fakeHost$timInformationPath'));
        // Also check that the request path is the one for finding a server by IK.
        expect(request.url.path, contains('/v1/server/findByIk'));
        expect(request.headers['Authorization'], equals('Bearer ${fakeToken.accessToken}'));

        final responseJson = jsonEncode({"serverName": "example.com"});
        return http.Response(responseJson, 200);
      });

      repo = InsurerInformationRepository(mockMatrixClient, mockAuthRepository, httpClient);
      final result = await repo.getServerByIk(ikNumber);

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('Expected a Right but got a Left: $l'),
        (r) {
          expect(r?.serverName, equals("example.com"));
        },
      );
    });

    test('returns ApiException on error response', () async {
      const ikNumber = 'errorIk';

      final httpClient = MockClient((http.Request request) async {
        return http.Response('Internal Server Error', 500);
      });

      repo = InsurerInformationRepository(mockMatrixClient, mockAuthRepository, httpClient);
      final result = await repo.getServerByIk(ikNumber);

      expect(result.isLeft(), isTrue);
      result.fold(
        (l) {
          expect(l.code, equals(500));
        },
        (r) => fail('Expected a Left but got a Right: $r'),
      );
    });
  });
  group('doesServerBelongToInsurer', () {
    test('returns Some(true) when server is insurance', () async {
      const serverName = 'example.com';

      final httpClient = MockClient((http.Request request) async {
        expect(request.url.path, contains('/v1/server/isInsurance'));
        expect(request.headers['Authorization'], equals('Bearer ${fakeToken.accessToken}'));

        final responseJson = jsonEncode({"isInsurance": true});
        return http.Response(responseJson, 200);
      });

      repo = InsurerInformationRepository(mockMatrixClient, mockAuthRepository, httpClient);
      final result = await repo.doesServerBelongToInsurer(serverName);

      // Expect a Some value.
      expect(result.isSome(), isTrue);
      result.fold(
        () => fail('Expected Some but got None'),
        (r) => expect(r, isTrue),
      );
    });

    test('returns None on error response for isServerAnInsurance', () async {
      const serverName = 'example.com';

      final httpClient = MockClient((http.Request request) async {
        return http.Response('Forbidden', 403);
      });

      repo = InsurerInformationRepository(mockMatrixClient, mockAuthRepository, httpClient);
      final result = await repo.doesServerBelongToInsurer(serverName);

      // Expect a None value when an error occurs.
      expect(result.isNone(), isTrue);
    });
  });
}
