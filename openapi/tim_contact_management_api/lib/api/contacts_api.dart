//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ContactsApi {
  ContactsApi([ApiClient? apiClient])
      : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Creates the setting for the contact {mxid}.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] mxid (required):
  ///   MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token.
  ///
  /// * [Contact] contact (required):
  Future<Response> createContactSettingWithHttpInfo(
    String mxid,
    Contact contact,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/contacts';

    // ignore: prefer_final_locals
    Object? postBody = contact;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'Mxid'] = parameterToString(mxid);

    const contentTypes = <String>['application/json'];

    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Creates the setting for the contact {mxid}.
  ///
  /// Parameters:
  ///
  /// * [String] mxid (required):
  ///   MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token.
  ///
  /// * [Contact] contact (required):
  Future<Contact?> createContactSetting(
    String mxid,
    Contact contact,
  ) async {
    final response = await createContactSettingWithHttpInfo(
      mxid,
      contact,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty &&
        response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(
        await _decodeBodyBytes(response),
        'Contact',
      ) as Contact;
    }
    return null;
  }

  /// Deletes the setting for the contact {mxid}.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] mxid (required):
  ///   MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token.
  ///
  /// * [String] mxid2 (required):
  ///   ID of the contact (mxid)).
  Future<Response> deleteContactSettingWithHttpInfo(
    String mxid,
    String mxid2,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/contacts/{mxid}'.replaceAll('{mxid}', mxid2);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'Mxid'] = parameterToString(mxid);

    const contentTypes = <String>[];

    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Deletes the setting for the contact {mxid}.
  ///
  /// Parameters:
  ///
  /// * [String] mxid (required):
  ///   MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token.
  ///
  /// * [String] mxid2 (required):
  ///   ID of the contact (mxid)).
  Future<void> deleteContactSetting(
    String mxid,
    String mxid2,
  ) async {
    final response = await deleteContactSettingWithHttpInfo(
      mxid,
      mxid2,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Returns the contacts with invite settings.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] mxid (required):
  ///   MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token.
  ///
  /// * [String] mxid2 (required):
  ///   ID of the contact (mxid)).
  Future<Response> getContactWithHttpInfo(
    String mxid,
    String mxid2,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/contacts/{mxid}'.replaceAll('{mxid}', mxid2);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'Mxid'] = parameterToString(mxid);

    const contentTypes = <String>[];

    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Returns the contacts with invite settings.
  ///
  /// Parameters:
  ///
  /// * [String] mxid (required):
  ///   MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token.
  ///
  /// * [String] mxid2 (required):
  ///   ID of the contact (mxid)).
  Future<Contact?> getContact(
    String mxid,
    String mxid2,
  ) async {
    final response = await getContactWithHttpInfo(
      mxid,
      mxid2,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty &&
        response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(
        await _decodeBodyBytes(response),
        'Contact',
      ) as Contact;
    }
    return null;
  }

  /// Returns the contacts with invite settings.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] mxid (required):
  ///   MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token.
  Future<Response> getContactsWithHttpInfo(
    String mxid,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/contacts';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'Mxid'] = parameterToString(mxid);

    const contentTypes = <String>[];

    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Returns the contacts with invite settings.
  ///
  /// Parameters:
  ///
  /// * [String] mxid (required):
  ///   MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token.
  Future<Contacts?> getContacts(
    String mxid,
  ) async {
    final response = await getContactsWithHttpInfo(
      mxid,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty &&
        response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(
        await _decodeBodyBytes(response),
        'Contacts',
      ) as Contacts;
    }
    return null;
  }

  /// Updates the setting for the contact {mxid}.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] mxid (required):
  ///   MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token.
  ///
  /// * [Contact] contact (required):
  Future<Response> updateContactSettingWithHttpInfo(
    String mxid,
    Contact contact,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/contacts';

    // ignore: prefer_final_locals
    Object? postBody = contact;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'Mxid'] = parameterToString(mxid);

    const contentTypes = <String>['application/json'];

    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Updates the setting for the contact {mxid}.
  ///
  /// Parameters:
  ///
  /// * [String] mxid (required):
  ///   MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token.
  ///
  /// * [Contact] contact (required):
  Future<Contact?> updateContactSetting(
    String mxid,
    Contact contact,
  ) async {
    final response = await updateContactSettingWithHttpInfo(
      mxid,
      contact,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty &&
        response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(
        await _decodeBodyBytes(response),
        'Contact',
      ) as Contact;
    }
    return null;
  }
}
