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

import 'package:fluffychat/tim/shared/errors/tim_bad_state_exception.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:matrix/matrix.dart';

/// Abstraction to access Matrix data.
abstract class TimMatrixClient {
  String get userID;

  String get accessToken;

  Uri get homeserver;

  Future<String?> getDisplayName(String userId);

  Room? getRoomById(String id);

  /// See [Client.getRoomEvents].
  Future<matrix.GetRoomEventsResponse> getRoomEvents(
    String roomId,
    matrix.Direction dir, {
    String? from,
    String? to,
    int? limit,
    String? filter,
  });

  Future<String> startDirectChat(
    String mxid, {
    bool? enableEncryption,
    List<StateEvent>? initialState,
    bool waitForSync = true,
    Map<String, dynamic>? powerLevelContentOverride,
    CreateRoomPreset? preset = CreateRoomPreset.trustedPrivateChat,
  });
}

class TimMatrixClientImpl implements TimMatrixClient {
  final matrix.Client client;

  TimMatrixClientImpl({required this.client});

  @override
  String get userID {
    if (client.userID == null || client.userID!.isEmpty) {
      throw (TimBadStateException('client.userID must not be null or empty'));
    }
    return client.userID!;
  }

  @override
  String get accessToken {
    if (client.accessToken == null || client.accessToken!.isEmpty) {
      throw (TimBadStateException(
        'client.accessToken must not be null or empty',
      ));
    }
    return client.accessToken!;
  }

  @override
  Uri get homeserver {
    if (client.homeserver == null) {
      throw (TimBadStateException('client.accessToken must not be null'));
    }
    return client.homeserver!;
  }

  @override
  Future<String?> getDisplayName(String userId) {
    return client.getDisplayName(userId);
  }

  @override
  Room? getRoomById(String id) {
    return client.getRoomById(id);
  }

  @override
  Future<matrix.GetRoomEventsResponse> getRoomEvents(
    String roomId,
    matrix.Direction dir, {
    String? from,
    String? to,
    int? limit,
    String? filter,
  }) =>
      client.getRoomEvents(
        roomId,
        dir,
        from: from,
        to: to,
        limit: limit,
        filter: filter,
      );

  @override
  Future<String> startDirectChat(
    String mxid, {
    bool? enableEncryption,
    List<StateEvent>? initialState,
    bool waitForSync = true,
    Map<String, dynamic>? powerLevelContentOverride,
    CreateRoomPreset? preset = CreateRoomPreset.trustedPrivateChat,
  }) {
    return client.startDirectChat(
      mxid,
      enableEncryption: enableEncryption,
      initialState: initialState,
      waitForSync: waitForSync,
      powerLevelContentOverride: powerLevelContentOverride,
      preset: preset,
    );
  }
}
