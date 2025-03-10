//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class LookUpServerApi {
  LookUpServerApi([ApiClient? apiClient])
      : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Resolve an IK number to the associated TI-Messenger server name.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] ikNumber (required):
  ///   IK number to look up.
  Future<Response> v1ServerFindByIkGetWithHttpInfo(
    String ikNumber,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/server/findByIk';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    queryParams.addAll(_queryParams('', 'ikNumber', ikNumber));

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

  /// Resolve an IK number to the associated TI-Messenger server name.
  ///
  /// Parameters:
  ///
  /// * [String] ikNumber (required):
  ///   IK number to look up.
  Future<V1ServerFindByIkGet200Response?> v1ServerFindByIkGet(
    String ikNumber,
  ) async {
    final response = await v1ServerFindByIkGetWithHttpInfo(
      ikNumber,
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
        'V1ServerFindByIkGet200Response',
      ) as V1ServerFindByIkGet200Response;
    }
    return null;
  }

  /// Check whether a TI-Messenger server name represents an insurance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverName (required):
  ///   The server name to query.
  Future<Response> v1ServerIsInsuranceGetWithHttpInfo(
    String serverName,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/server/isInsurance';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    queryParams.addAll(_queryParams('', 'serverName', serverName));

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

  /// Check whether a TI-Messenger server name represents an insurance.
  ///
  /// Parameters:
  ///
  /// * [String] serverName (required):
  ///   The server name to query.
  Future<V1ServerIsInsuranceGet200Response?> v1ServerIsInsuranceGet(
    String serverName,
  ) async {
    final response = await v1ServerIsInsuranceGetWithHttpInfo(
      serverName,
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
        'V1ServerIsInsuranceGet200Response',
      ) as V1ServerIsInsuranceGet200Response;
    }
    return null;
  }
}
