/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - 2025 - akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:convert';

import 'package:fluffychat/tim/test_driver/debug_dtos.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';


/// A JSON encoded list of available chat rooms, which is used with the test driver
class RoomListDebugWidget extends StatelessWidget {
  /// default constructor
  const RoomListDebugWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncUpdate>(
      stream: Matrix.of(context).client.onSync.stream,
      builder: (context, snapshot) {
        return FutureBuilder<Text>(
          future: _buildWidget(context),
          builder: (context, futureSnapshot) {
            return futureSnapshot.data ??
                const Text(
                  "Loading room info...",
                  overflow: TextOverflow.ellipsis,
                  key: ValueKey("loadingRoomsListDebug"),
                );
          },
        );
      },
    );
  }

  Future<Text> _buildWidget(BuildContext context) async {
    final client = Matrix.of(context).client;
    final rooms = client.rooms;

    final List<RoomDebugDto> roomDebugDtos = [];
    for (final room in rooms) {
      room.postLoad();

      final roomDebugDto = await RoomDebugDto.getDtoFromMatrixRoom(room, Matrix.of(context).client);

      roomDebugDtos.add(roomDebugDto);
    }

    final roomDebugDtoJSON = const JsonEncoder().convert(roomDebugDtos);

    return Text(
      roomDebugDtoJSON,
      overflow: TextOverflow.ellipsis,
      key: const ValueKey("roomsListDebug"),
    );
  }
}
