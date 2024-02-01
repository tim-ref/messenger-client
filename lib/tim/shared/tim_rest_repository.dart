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

import 'dart:io';

import 'package:http/http.dart' as http;

abstract class TimRestRepository {
  final http.Client _client;

  TimRestRepository(this._client);

  Future<http.Response> get(
    Uri uri, {
    required Map<String, String> headers,
  }) async {
    final response = await _client.get(
      uri,
      headers: headers,
    );
    if (response.statusCode >= 400) {
      throw HttpException(
          "Unexpected status ${response.statusCode} for call to URI: $uri \n Response body was: ${response.body}");
    }
    return response;
  }

  Future<http.Response> post(
    Uri uri, {
    required Map<String, String> headers,
    String? body,
  }) async {
    final response = await _client.post(
      uri,
      body: body,
      headers: headers,
    );
    if (response.statusCode >= 400) {
      throw HttpException(
          "Unexpected status ${response.statusCode} for call to URI: $uri \n Response body was: ${response.body}");
    }
    return response;
  }

  Future<http.Response> put(
    Uri uri, {
    required Map<String, String> headers,
    String? body,
  }) async {
    final response = await _client.put(
      uri,
      body: body,
      headers: headers,
    );
    if (response.statusCode >= 400) {
      throw HttpException(
          "Unexpected status ${response.statusCode} for call to URI: $uri \n Response body was: ${response.body}");
    }
    return response;
  }

  Future<http.Response> delete(
    Uri uri, {
    required Map<String, String> headers,
    String? body,
  }) async {
    final response = await _client.delete(
      uri,
      body: body,
      headers: headers,
    );
    if (response.statusCode >= 400) {
      throw HttpException(
          "Unexpected status ${response.statusCode} for call to URI: $uri \n Response body was: ${response.body}");
    }
    return response;
  }
}
