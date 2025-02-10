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

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tim_contact_management_api/api.dart';

import 'package:fluffychat/tim/feature/contact_approval/contact_approval_repository.dart';
import 'package:fluffychat/tim/shared/tim_auth_repository.dart';
import 'package:fluffychat/tim/shared/tim_auth_token.dart';
import 'package:fluffychat/tim/tim_constants.dart';
import 'package:fluffychat/utils/date_time_extension.dart';

import '../../share_room_archive_test.mocks.dart';
import 'contact_approval_repository_test.mocks.dart';

const host = 'https://localhost';
const userId = '@user:mxid';
const baseUrl = '$host$contactMgmtAPIPath/contacts';

@GenerateMocks([http.Client, TimAuthRepository])
void main() {
  late final MockClient httpClient;
  late final MockTimMatrixClient timClient;
  late final MockTimAuthRepository tokenRepo;
  late final ContactApprovalRepository repo;

  setUpAll(() {
    httpClient = MockClient();
    timClient = MockTimMatrixClient();
    tokenRepo = MockTimAuthRepository();
    when(tokenRepo.getOpenIdToken()).thenAnswer((_) async => _defaultOpenIdToken());
    when(timClient.userID).thenReturn(userId);
    when(timClient.homeserver).thenReturn(Uri.parse(host));
    repo = ContactApprovalRepository(timClient, tokenRepo, httpClient);
  });

  test('returns the correct approvals', () async {
    // given
    final expectedUri = Uri.parse(baseUrl);
    final expectedHeaders = _expectedHeaders();
    when(
      httpClient.get(
        expectedUri,
        headers: expectedHeaders,
      ),
    ).thenAnswer(
      (_) async => http.Response(
        jsonEncode(Contacts(contacts: _expectedApprovals())),
        200,
      ),
    );

    // when
    final approvals = await repo.listApprovals();

    // then
    expect(approvals, equals(_expectedApprovals()));
  });

  test('handles rest error correctly for listApprovals()', () async {
    // given
    final expectedUri = Uri.parse(baseUrl);
    final expectedHeaders = _expectedHeaders();
    when(
      httpClient.get(
        expectedUri,
        headers: expectedHeaders,
      ),
    ).thenAnswer(
      (_) async => http.Response(
        jsonEncode(Error(errorCode: "500", errorMessage: "Internal Server Error occured")),
        500,
      ),
    );

    // expect
    final internalServerErrorMatcher = isA<ApiException>()
        .having((e) => e.code, "code", 500)
        .having((e) => e.message, "message", contains("Internal Server Error occured"));
    expectLater(repo.listApprovals(), throwsA(internalServerErrorMatcher));
  });

  test('returns the correct contact for given mxid', () async {
    // given
    const mxid = '@eins:localhost';
    final expectedUri = Uri.parse('$baseUrl/$mxid');
    final expectedHeaders = _expectedHeaders();
    when(
      httpClient.get(
        expectedUri,
        headers: expectedHeaders,
      ),
    ).thenAnswer(
      (_) async => http.Response(
        jsonEncode(_expectedApproval()),
        200,
      ),
    );

    // when
    final contact = await repo.getApproval(mxid);

    // then
    expect(contact, equals(_expectedApproval()));
  });

  test('handles rest error correctly for getContact()', () async {
    // given
    const mxid = '@eins:localhost';
    final expectedUri = Uri.parse('$baseUrl/$mxid');
    final expectedHeaders = _expectedHeaders();
    when(
      httpClient.get(
        expectedUri,
        headers: expectedHeaders,
      ),
    ).thenAnswer(
      (_) async => http.Response(
        jsonEncode(Error(errorCode: "404", errorMessage: "Not Found")),
        404,
      ),
    );

    // expect
    final notFoundMatcher = isA<ApiException>()
        .having((e) => e.code, "code", 404)
        .having((e) => e.message, "message", contains("Not Found"));
    expectLater(repo.getApproval(mxid), throwsA(notFoundMatcher));
  });

  test('constructs correct api call for update contact', () async {
    // given
    final expectedUri = Uri.parse(baseUrl);
    final expectedHeaders = _expectedHeaders();
    final expectedBody = jsonEncode(_expectedApproval());
    expectedHeaders.putIfAbsent('Content-Type', () => 'application/json');
    when(
      httpClient.put(
        expectedUri,
        headers: expectedHeaders,
        body: expectedBody,
      ),
    ).thenAnswer(
      (_) async => http.Response(
        expectedBody,
        200,
      ),
    );

    // when
    await repo.updateApproval(_expectedApproval());

    // expect
    // implicitly verified through method stubs
  });

  test('handles rest error correctly for updateContact()', () async {
    // given
    final expectedUri = Uri.parse(baseUrl);
    final expectedHeaders = _expectedHeaders();
    final expectedBody = jsonEncode(_expectedApproval());
    expectedHeaders.putIfAbsent('Content-Type', () => 'application/json');
    when(
      httpClient.put(
        expectedUri,
        headers: expectedHeaders,
        body: expectedBody,
      ),
    ).thenAnswer(
      (_) async => http.Response(
        jsonEncode(Error(errorCode: "400", errorMessage: "Bad Request")),
        400,
      ),
    );

    // expect
    final badRequestMatcher = isA<ApiException>()
        .having((e) => e.code, "code", 400)
        .having((e) => e.message, "message", contains("Bad Request"));

    expectLater(repo.updateApproval(_expectedApproval()), throwsA(badRequestMatcher));
  });

  test('constructs correct api call for add contact', () async {
    // given
    final expectedUri = Uri.parse(baseUrl);
    final expectedHeaders = _expectedHeaders();
    final expectedBody = jsonEncode(_expectedApproval());
    expectedHeaders.putIfAbsent('Content-Type', () => 'application/json');
    when(
      httpClient.post(
        expectedUri,
        headers: expectedHeaders,
        body: expectedBody,
      ),
    ).thenAnswer(
      (_) async => http.Response(
        jsonEncode(_expectedApproval()),
        200,
      ),
    );

    // when
    await repo.addApproval(_expectedApproval());

    // expect
    // implicitly verified through method stubs
  });

  test(
    'handles rest error correctly for addContact()',
    () async {
      // given
      final expectedUri = Uri.parse(baseUrl);
      final expectedHeaders = _expectedHeaders();
      final expectedBody = jsonEncode(_expectedApproval());
      expectedHeaders.putIfAbsent('Content-Type', () => 'application/json');
      when(
        httpClient.post(
          expectedUri,
          headers: expectedHeaders,
          body: expectedBody,
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode(Error(errorCode: "500", errorMessage: "Internal Server Error")),
          500,
        ),
      );

      // expect
      final internalServerErrorMatcher = isA<ApiException>()
          .having((e) => e.code, "code", 500)
          .having((e) => e.message, "message", contains("Internal Server Error"));

      expectLater(repo.addApproval(_expectedApproval()), throwsA(internalServerErrorMatcher));
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );

  test('constructs correct api call for delete contact', () async {
    // given
    const mxid = '@eins:localhost';
    final expectedUri = Uri.parse('$baseUrl/$mxid');
    final expectedHeaders = _expectedHeaders();
    when(
      httpClient.delete(expectedUri, headers: expectedHeaders, body: ''),
    ).thenAnswer(
      (_) async => http.Response('', 204),
    );

    // when
    await repo.deleteApproval(mxid);

    // expect
    // implicitly verified through method stubs
  });

  test('handles rest error correctly for deleteContact()', () async {
    // given
    const mxid = '@eins:localhost';
    final expectedUri = Uri.parse('$baseUrl/$mxid');
    when(
      httpClient.delete(
        expectedUri,
        headers: _expectedHeaders(),
        body: '',
      ),
    ).thenAnswer(
      (_) async => http.Response(
        jsonEncode(Error(errorCode: "403", errorMessage: "Forbidden")),
        403,
      ),
    );

    // expect
    final forbiddenMatcher = isA<ApiException>()
        .having((e) => e.code, "code", 403)
        .having((e) => e.message, "message", contains("Forbidden"));

    expectLater(repo.deleteApproval(mxid), throwsA(forbiddenMatcher));
  });
}

Map<String, String> _expectedHeaders() {
  return <String, String>{
    'Mxid': userId,
    'Authorization': 'Bearer ${_defaultOpenIdToken().accessToken}',
  };
}

TimAuthToken _defaultOpenIdToken() {
  return TimAuthToken(
    accessToken: 'accessToken',
    tokenType: 'bearer',
    matrixServerName: 'localhost',
    expiresIn: 3600,
  );
}

Contact _expectedApproval() {
  return Contact(
    displayName: 'eins',
    mxid: '@eins:localhost',
    inviteSettings: ContactInviteSettings(
      start: DateTime.utc(2023, 2, 8, 12, 12, 1).secondsSinceEpoch,
    ),
  );
}

List<Contact> _expectedApprovals() {
  return [
    Contact(
      displayName: 'eins',
      mxid: '@eins:localhost',
      inviteSettings: ContactInviteSettings(
        start: DateTime.utc(2023, 2, 8, 12, 12, 1).secondsSinceEpoch,
      ),
    ),
    Contact(
      displayName: 'zwei',
      mxid: '@zwei:localhost',
      inviteSettings: ContactInviteSettings(
        start: DateTime.utc(2023, 2, 8, 12, 12, 1).secondsSinceEpoch,
        end: DateTime.utc(2023, 2, 10, 12, 12, 1).secondsSinceEpoch,
      ),
    ),
    Contact(
      displayName: 'drei',
      mxid: '@drei:otherhost',
      inviteSettings: ContactInviteSettings(
        start: DateTime.utc(2023, 2, 8, 12, 12, 1).secondsSinceEpoch,
      ),
    ),
  ];
}
