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
import 'package:matrix/matrix.dart';

import 'package:fluffychat/tim/feature/contact_approval/dto/contact.dart';
import 'package:fluffychat/tim/shared/matrix/tim_matrix_client.dart';
import 'package:fluffychat/tim/shared/tim_auth_repository.dart';
import 'package:fluffychat/tim/shared/tim_rest_repository.dart';
import 'package:fluffychat/utils/future_with_retries.dart';
import 'package:fluffychat/tim/tim_constants.dart';

class ContactApprovalRepository extends TimRestRepository {
  final TimMatrixClient _timClient;
  final TimAuthRepository _authRepository;

  ContactApprovalRepository(
    http.Client httpClient,
    this._timClient,
    this._authRepository,
  ) : super(httpClient);

  Future<List<Contact>> listApprovals() async {
    try {
      final response = await get(
        Uri.parse('https://${_timClient.homeserver.host}$contactMgmtAPIPath'),
        headers: await _buildHeaders(),
      );
      final contacts = (jsonDecode(response.body) as List<dynamic>)
          .map((e) => Contact.fromJson(e as Map<String, dynamic>))
          .toList();
      return contacts;
    } catch (error, stacktrace) {
      Logs().e('Error fetching contacts', error, stacktrace);
      rethrow;
    }
  }

  Future<http.Response> addApproval(Contact contact) async {
    return runFutureWithRetries(
      () async => post(
        Uri.parse('https://${_timClient.homeserver.host}$contactMgmtAPIPath'),
        headers: await _buildHeaders(),
        body: jsonEncode(
          contact.toJson(),
        ),
      ),
      errorMessage: 'Error adding contact',
    );
  }

  Future<http.Response> updateApproval(Contact contact) async {
    return put(
      Uri.parse('https://${_timClient.homeserver.host}$contactMgmtAPIPath'),
      headers: await _buildHeaders(),
      body: jsonEncode(
        contact.toJson(),
      ),
    ).catchError((error, stacktrace) {
      Logs().e('Error updating contact', error, stacktrace);
      throw error;
    });
  }

  Future<Contact> getApproval(String mxid) async {
    try {
      final response = await get(
        Uri.parse(
          'https://${_timClient.homeserver.host}$contactMgmtAPIPath/${Uri.encodeComponent(mxid)}',
        ),
        headers: await _buildHeaders(),
      );
      return Contact.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      Logs().e('Error fetching contact', error, stacktrace);
      rethrow;
    }
  }

  Future<http.Response> deleteApproval(String mxid) async {
    return delete(
      Uri.parse(
        'https://${_timClient.homeserver.host}$contactMgmtAPIPath/${Uri.encodeComponent(mxid)}',
      ),
      headers: await _buildHeaders(),
    ).catchError((error, stacktrace) {
      Logs().e('Error deleting contact', error, stacktrace);
      throw error;
    });
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    };
    final timMatrixOpenIdToken = await _authRepository.getOpenIdToken();
    headers.putIfAbsent(
      HttpHeaders.authorizationHeader,
      () => 'Bearer ${timMatrixOpenIdToken.accessToken}',
    );
    headers.putIfAbsent('mxid', () => _timClient.userID);
    return headers;
  }
}
