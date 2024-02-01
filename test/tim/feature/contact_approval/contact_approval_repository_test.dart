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

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:fluffychat/tim/feature/contact_approval/contact_approval_repository.dart';
import 'package:fluffychat/tim/feature/contact_approval/dto/contact.dart';
import 'package:fluffychat/tim/feature/contact_approval/dto/invite_settings.dart';
import 'package:fluffychat/tim/shared/errors/tim_bad_state_exception.dart';
import 'package:fluffychat/tim/shared/tim_auth_repository.dart';
import 'package:fluffychat/tim/shared/tim_auth_token.dart';
import 'package:fluffychat/tim/tim_constants.dart';

import '../../share_room_archive_test.mocks.dart';
import 'contact_approval_repository_test.mocks.dart';

const host = 'https://localhost';
const userId = '@user:mxid';

@GenerateMocks([http.Client, TimAuthRepository])
void main() {
  late final MockClient httpClient;
  late final MockTimMatrixClient timClient;
  late final MockTimAuthRepository tokenRepo;

  setUpAll(() {
    httpClient = MockClient();
    timClient = MockTimMatrixClient();
    tokenRepo = MockTimAuthRepository();
    when(tokenRepo.getOpenIdToken())
        .thenAnswer((_) async => _defaultOpenIdToken());
    when(timClient.userID).thenReturn(userId);
    when(timClient.homeserver).thenReturn(Uri.parse(host));
  });

  test('returns the correct approvals', () async {
    // given
    final expectedUri = Uri.parse('$host$contactMgmtAPIPath');
    final expectedHeaders = _expectedHeaders();
    when(
      httpClient.get(
        expectedUri,
        headers: expectedHeaders,
      ),
    ).thenAnswer(
      (_) async => http.Response(
        jsonEncode(_expectedApprovals().map((e) => e.toJson()).toList()),
        200,
      ),
    );

    final repo = ContactApprovalRepository(
      httpClient,
      timClient,
      tokenRepo,
    );

    // when
    final approvals = await repo.listApprovals();

    // then
    expect(approvals, equals(_expectedApprovals()));
  });

  test('handles rest error correctly for listApprovals()', () async {
    // given
    final expectedUri = Uri.parse('$host$contactMgmtAPIPath');
    final expectedHeaders = _expectedHeaders();
    when(
      httpClient.get(
        expectedUri,
        headers: expectedHeaders,
      ),
    ).thenAnswer(
      (_) async => http.Response(
        '',
        500,
      ),
    );

    final repo = ContactApprovalRepository(
      httpClient,
      timClient,
      tokenRepo,
    );

    // expect
    final internalServerErrorMatcher = isA<HttpException>().having(
        (e) => e.message,
        "message",
        contains("Unexpected status 500 for call to URI: $expectedUri"));
    expectLater(repo.listApprovals(), throwsA(internalServerErrorMatcher));
  });

  test('returns the correct contact for given mxid', () async {
    // given
    const mxid = '@eins:localhost';
    final expectedUri =
        Uri.parse('$host$contactMgmtAPIPath/${Uri.encodeComponent(mxid)}');
    final expectedHeaders = _expectedHeaders();
    when(
      httpClient.get(
        expectedUri,
        headers: expectedHeaders,
      ),
    ).thenAnswer(
      (_) async => http.Response(
        jsonEncode(_expectedApproval().toJson()),
        200,
      ),
    );

    final repo = ContactApprovalRepository(
      httpClient,
      timClient,
      tokenRepo,
    );

    // when
    final contact = await repo.getApproval(mxid);

    // then
    expect(contact, equals(_expectedApproval()));
  });

  test('handles rest error correctly for getContact()', () async {
    // given
    const mxid = '@eins:localhost';
    final expectedUri =
        Uri.parse('$host$contactMgmtAPIPath/${Uri.encodeComponent(mxid)}');
    final expectedHeaders = _expectedHeaders();
    when(
      httpClient.get(
        expectedUri,
        headers: expectedHeaders,
      ),
    ).thenAnswer(
      (_) async => http.Response(
        '',
        404,
      ),
    );

    final repo = ContactApprovalRepository(
      httpClient,
      timClient,
      tokenRepo,
    );

    // expect
    final notFoundMatcher = isA<HttpException>().having(
        (e) => e.message,
        "message",
        contains("Unexpected status 404 for call to URI: $expectedUri"));
    expectLater(repo.getApproval(mxid), throwsA(notFoundMatcher));
  });

  test('constructs correct api call for update contact', () async {
    // given
    final expectedUri = Uri.parse('$host$contactMgmtAPIPath');
    final expectedHeaders = _expectedHeaders();
    final expectedBody = jsonEncode(_expectedApproval().toJson());
    when(
      httpClient.put(
        expectedUri,
        headers: expectedHeaders,
        body: expectedBody,
      ),
    ).thenAnswer(
      (_) async => http.Response(
        '{}',
        200,
      ),
    );

    final repo = ContactApprovalRepository(
      httpClient,
      timClient,
      tokenRepo,
    );

    // when
    await repo.updateApproval(_expectedApproval());

    // expect
    // implicitly verified through method stubs
  });

  test('handles rest error correctly for updateContact()', () async {
    // given
    final expectedUri = Uri.parse('$host$contactMgmtAPIPath');
    final expectedHeaders = _expectedHeaders();
    final expectedBody = jsonEncode(_expectedApproval().toJson());
    when(
      httpClient.put(
        expectedUri,
        headers: expectedHeaders,
        body: expectedBody,
      ),
    ).thenAnswer(
      (_) async => http.Response(
        '',
        400,
      ),
    );

    final repo = ContactApprovalRepository(
      httpClient,
      timClient,
      tokenRepo,
    );

    // expect
    final badRequestMatcher = isA<HttpException>().having(
        (e) => e.message,
        "message",
        contains("Unexpected status 400 for call to URI: $expectedUri"));
    expectLater(
        repo.updateApproval(_expectedApproval()), throwsA(badRequestMatcher));
  });

  test('constructs correct api call for add contact', () async {
    // given
    final repo = ContactApprovalRepository(
      httpClient,
      timClient,
      tokenRepo,
    );
    final expectedUri = Uri.parse('$host$contactMgmtAPIPath');
    final expectedHeaders = _expectedHeaders();
    final expectedBody = jsonEncode(_expectedApproval().toJson());
    when(
      httpClient.post(
        expectedUri,
        headers: expectedHeaders,
        body: expectedBody,
      ),
    ).thenAnswer(
      (_) async => http.Response(
        '{}',
        200,
      ),
    );

    // when
    await repo.addApproval(_expectedApproval());

    // expect
    // implicitly verified through method stubs
  });

  test('handles rest error correctly for addContact()', () async {
    // given
    final repo = ContactApprovalRepository(
      httpClient,
      timClient,
      tokenRepo,
    );
    final expectedUri = Uri.parse('$host$contactMgmtAPIPath');
    final expectedHeaders = _expectedHeaders();
    final expectedBody = jsonEncode(_expectedApproval().toJson());
    when(
      httpClient.post(
        expectedUri,
        headers: expectedHeaders,
        body: expectedBody,
      ),
    ).thenAnswer(
      (_) async => http.Response(
        '{}',
        500,
      ),
    );

    // expect
    final internalServerErrorMatcher = isA<HttpException>().having(
        (e) => e.message,
        "message",
        contains("Unexpected status 500 for call to URI: $expectedUri"));
    expectLater(repo.addApproval(_expectedApproval()),
        throwsA(internalServerErrorMatcher));
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('constructs correct api call for delete contact', () async {
    // given
    const mxid = '@eins:localhost';
    final expectedUri =
        Uri.parse('$host$contactMgmtAPIPath/${Uri.encodeComponent(mxid)}');
    final expectedHeaders = _expectedHeaders();
    when(
      httpClient.delete(
        expectedUri,
        headers: expectedHeaders,
      ),
    ).thenAnswer(
      (_) async => http.Response(
        '{}',
        200,
      ),
    );

    final repo = ContactApprovalRepository(
      httpClient,
      timClient,
      tokenRepo,
    );

    // when
    await repo.deleteApproval(mxid);

    // expect
    // implicitly verified through method stubs
  });

  test('handles rest error correctly for deleteContact()', () async {
    // given
    const mxid = '@eins:localhost';
    final repo = ContactApprovalRepository(
      httpClient,
      timClient,
      tokenRepo,
    );
    final expectedUri =
        Uri.parse('$host$contactMgmtAPIPath/${Uri.encodeComponent(mxid)}');
    when(
      httpClient.delete(
        expectedUri,
        headers: _expectedHeaders(),
      ),
    ).thenAnswer(
      (_) async => http.Response(
        '{}',
        403,
      ),
    );

    // expect
    final forbiddenMatcher = isA<HttpException>().having(
        (e) => e.message,
        "message",
        contains("Unexpected status 403 for call to URI: $expectedUri"));
    expectLater(repo.deleteApproval(mxid), throwsA(forbiddenMatcher));
  });

  test('handles null homeserver correctly for addContact()', () async {
    // given
    final repo = ContactApprovalRepository(
      httpClient,
      timClient,
      tokenRepo,
    );
    when(timClient.homeserver)
        .thenThrow(TimBadStateException('homeServer is null'));

    // expect
    expectLater(repo.addApproval(_expectedApproval()),
        throwsA(isA<TimBadStateException>()));
  }, timeout: const Timeout(Duration(seconds: 30)));
}

Map<String, String> _expectedHeaders() {
  return <String, String>{
    HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    HttpHeaders.authorizationHeader:
        'Bearer ${_defaultOpenIdToken().accessToken}',
    'mxid': userId
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
    inviteSettings: InviteSettings(
      start: DateTime.utc(2023, 2, 8, 12, 12, 1),
    ),
  );
}

List<Contact> _expectedApprovals() {
  return [
    Contact(
      displayName: 'eins',
      mxid: '@eins:localhost',
      inviteSettings: InviteSettings(
        start: DateTime.utc(2023, 2, 8, 12, 12, 1),
      ),
    ),
    Contact(
      displayName: 'zwei',
      mxid: '@zwei:localhost',
      inviteSettings: InviteSettings(
        start: DateTime.utc(2023, 2, 8, 12, 12, 1),
        end: DateTime.utc(2023, 2, 10, 12, 12, 1),
      ),
    ),
    Contact(
      displayName: 'drei',
      mxid: '@drei:otherhost',
      inviteSettings: InviteSettings(
        start: DateTime.utc(2023, 2, 8, 12, 12, 1),
      ),
    ),
  ];
}
