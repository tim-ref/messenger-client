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

import 'package:matrix/matrix.dart';
import 'package:http/http.dart';

// Default is about 20 seconds total.
const defaultFutureRetryDelays = [
  Duration(seconds: 0),
  Duration(seconds: 1),
  Duration(seconds: 3),
  Duration(seconds: 5),
  Duration(seconds: 11),
];

Future<T> runFutureWithRetries<T>(
  Future<T> Function() call, {
  List<Duration> retryDelays = defaultFutureRetryDelays,
  String? errorMessage,
}) async {
  Exception? lastException;
  for (final delay in retryDelays) {
    await Future.delayed(delay);
    try {
      return await call();
    } on Exception catch (e) {
      Logs().w('Error while retrying future:', e);
      lastException = e;
    }
    Logs().i('Retrying future..');
  }
  const defaultErrorMessage = "Failed to resolve future with retries!";
  final exception = lastException ?? TimeoutException(defaultErrorMessage);
  Logs().e(errorMessage ?? defaultErrorMessage, exception);
  throw exception;
}

Future<Response> runRequestWithRetries(
  Future<Response> Function() call, {
  List<Duration> retryDelays = defaultFutureRetryDelays,
}) async {
  Response? response;
  Exception? lastException;
  for (final delay in retryDelays) {
    await Future.delayed(delay);
    try {
      response = await call();
      switch (response.statusCode) {
        case >= 200 && < 300:
          return response;
        case >= 400 && < 500:
          lastException = HttpException("unexpected status ${response.statusCode}");
          break;
      }
    } on Exception catch (e) {
      Logs().w('Error while retrying request:', e);
      lastException = e;
    }
    Logs().i('Retrying request after response: ${response?.statusCode} ${response?.body}');
  }
  throw lastException ?? TimeoutException("unexpected status ${response?.statusCode}");
}
