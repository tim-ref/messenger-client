/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - 2025 – akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:async';

import 'package:matrix/src/utils/cached_stream_controller.dart';

/// A modified copy of the matrix package's [CachedStreamController].
/// Calling [add] will immediately run [Stream.listen].
class SyncCachedStreamController<T> implements CachedStreamController<T> {
  T? _value;
  Object? _lastError;
  final StreamController<T> _streamController = StreamController.broadcast(sync: true);

  SyncCachedStreamController([T? value]) : _value = value;

  @override
  T? get value => _value;

  @override
  Object? get lastError => _lastError;

  @override
  Stream<T> get stream => _streamController.stream;

  @override
  void add(T value) {
    _value = value;
    _streamController.add(value);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _lastError = value;
    _streamController.addError(error, stackTrace);
  }

  @override
  Future close() => _streamController.close();

  @override
  bool get isClosed => _streamController.isClosed;
}
