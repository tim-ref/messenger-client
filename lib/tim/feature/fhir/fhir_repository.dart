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

import 'package:fluffychat/tim/feature/fhir/dto/bundle.dart';
import 'package:fluffychat/tim/feature/fhir/dto/entry.dart';
import 'package:fluffychat/tim/feature/fhir/dto/link_relation.dart';
import 'package:fluffychat/tim/feature/fhir/dto/resource_type.dart';
import 'package:fluffychat/tim/feature/fhir/fhir_config.dart';
import 'package:fluffychat/tim/shared/tim_auth_repository.dart';
import 'package:fluffychat/tim/shared/tim_auth_token.dart';
import 'package:fluffychat/tim/shared/tim_rest_repository.dart';

class FhirRepository extends TimRestRepository {
  final FhirConfig _config;
  final TimAuthRepository _tokenService;

  FhirRepository(http.Client httpClient, this._tokenService, this._config)
      : super(httpClient);

  Future<List<Entry>?> search(ResourceType resourceType, String query) async {
    final buildUri = _buildUri(resourceType, query);
    final headers = await _buildHeaders();
    final response = await get(
      buildUri,
      headers: headers,
    );
    _handleErroneousResponse(response);
    final bundle = Bundle.fromJson(jsonDecode(response.body));
    final bundles = [bundle];
    if (_bundleHasNext(bundle)) {
      await _loadNext(bundles, _getNextUrl(bundle), recursively: true);
    }

    final entries = bundles
        .where((bundle) => bundle.entry != null && bundle.entry!.isNotEmpty)
        .expand((bundle) => bundle.entry!)
        .toList();
    return entries;
  }

  Future<Map<String, dynamic>> ownerSearch(
    String query,
    TimAuthToken token,
  ) async {
    final uri = Uri.parse(
      '${_config.host}${_config.ownerBase}/${ResourceType.PractitionerRole.name}?$query',
    );
    final response = await get(
      uri,
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ${token.accessToken}',
      },
    );
    _handleErroneousResponse(response);
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createResource(
    ResourceType resourceType,
    TimAuthToken token,
    String bodyJson,
  ) async {
    final uri =
        Uri.parse('${_config.host}${_config.ownerBase}/${resourceType.name}');
    final response = await post(
      uri,
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ${token.accessToken}',
      },
      body: bodyJson,
    );
    _handleErroneousResponse(response);
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateResource(
    ResourceType resourceType,
    String resourceId,
    TimAuthToken token,
    String bodyJson,
  ) async {
    final uri = Uri.parse(
      '${_config.host}${_config.ownerBase}/${resourceType.name}/$resourceId',
    );
    final response = await put(
      uri,
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ${token.accessToken}',
      },
      body: bodyJson,
    );
    _handleErroneousResponse(response);
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteResource(
    ResourceType resourceType,
    String resourceId,
    TimAuthToken token,
  ) async {
    final uri = Uri.parse(
      '${_config.host}${_config.ownerBase}/${resourceType.name}/$resourceId',
    );
    final response = await delete(
      uri,
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ${token.accessToken}',
      },
    );
    _handleErroneousResponse(response);
    return jsonDecode(response.body);
  }

  bool _bundleHasNext(Bundle bundle) {
    return bundle.link != null &&
        bundle.link!
            .where((link) => link.relation == LinkRelation.next)
            .isNotEmpty;
  }

  Future<void> _loadNext(
    List<Bundle> bundles,
    Uri url, {
    bool? recursively = false,
  }) async {
    final headers = await _buildHeaders();
    final response = await get(
      url,
      headers: headers,
    );
    final bundle = Bundle.fromJson(jsonDecode(response.body));
    bundles.add(bundle);
    if (_bundleHasNext(bundle) && recursively == true) {
      await _loadNext(bundles, _getNextUrl(bundle));
    }
  }

  Uri _getNextUrl(Bundle bundle) {
    return bundle.link!
        .where((element) => element.relation == LinkRelation.next)
        .first
        .url;
  }

  Uri _buildUri(ResourceType resourceType, String query) {
    return Uri.parse('${_config.fhirServer()}/${resourceType.name}?$query');
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    };
    final fhirToken = await _tokenService.getFhirToken();
    headers.putIfAbsent(
      HttpHeaders.authorizationHeader,
      () => 'Bearer ${fhirToken.accessToken}',
    );
    return headers;
  }

  void _handleErroneousResponse(http.Response response) {
    if (response.statusCode >= 400) {
      throw HttpException("unexpected status ${response.statusCode}");
    }
  }
}
