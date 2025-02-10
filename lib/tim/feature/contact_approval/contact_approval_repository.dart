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

import 'package:http/http.dart';

import 'package:fluffychat/tim/shared/matrix/tim_matrix_client.dart';
import 'package:fluffychat/tim/shared/tim_auth_repository.dart';
import 'package:fluffychat/utils/future_with_retries.dart';
import 'package:logger/logger.dart';
import 'package:tim_contact_management_api/api.dart';

import '../../tim_constants.dart';

class ContactApprovalRepository {
  final TimMatrixClient _timClient;
  final TimAuthRepository _authRepository;
  final ContactsApi _contactsApi;
  final Logger _logger = Logger();

  ContactApprovalRepository(this._timClient, this._authRepository, [Client? httpClient])
      : _contactsApi = ContactsApi(
          ApiClient(
            basePath: 'https://${_timClient.homeserver.host}$contactMgmtAPIPath',
            authentication: HttpBearerAuth(),
          ),
        ) {
    if (httpClient != null) {
      _contactsApi.apiClient.client = httpClient;
    }
  }

  Future<List<Contact>> listApprovals() async {
    try {
      await _setBearerToken();
      final contacts = await _contactsApi.getContacts(_timClient.userID);
      return contacts?.contacts ?? [];
    } catch (error, stacktrace) {
      _logger.e('Error fetching contacts', error: error, stackTrace: stacktrace);
      rethrow;
    }
  }

  Future<Contact?> addApproval(Contact contact) async {
    await _setBearerToken();
    return runFutureWithRetries(
      () async => _contactsApi.createContactSetting(_timClient.userID, contact),
      errorMessage: 'Error adding contact',
    );
  }

  Future<Contact?> updateApproval(Contact contact) async {
    await _setBearerToken();
    return _contactsApi.updateContactSetting(_timClient.userID, contact);
  }

  Future<Contact> getApproval(String mxid) async {
    await _setBearerToken();
    try {
      final contact = await _contactsApi.getContact(_timClient.userID, mxid);
      if (contact == null) throw ApiException(404, 'Returned ok without contact');
      return contact;
    } catch (error, stacktrace) {
      _logger.e('Error fetching contact', error: error, stackTrace: stacktrace);
      rethrow;
    }
  }

  Future<void> deleteApproval(String mxid) async {
    await _setBearerToken();
    try {
      return _contactsApi.deleteContactSetting(_timClient.userID, mxid);
    } catch (error, stacktrace) {
      _logger.e('Error deleting contact', error: error, stackTrace: stacktrace);
      rethrow;
    }
  }

  Future<void> _setBearerToken() async {
    final token = await _authRepository.getOpenIdToken();
    final bearerAuth = _contactsApi.apiClient.authentication as HttpBearerAuth;
    bearerAuth.accessToken = token.accessToken;
  }
}
