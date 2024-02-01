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

import 'package:fluffychat/tim/test_driver/debug_dtos.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class RoomListDebugWidget extends StatelessWidget {
  const RoomListDebugWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Event>(
      stream: Matrix.of(context).client.onRoomState.stream,
      builder: (context, snapshot) {
        final List<RoomDebugDto> rooms =
            Matrix.of(context).client.rooms.map((r) => RoomDebugDto.fromMatrixRoom(r)).toList();

        return Text(
          const JsonEncoder().convert(rooms),
          overflow: TextOverflow.ellipsis,
          key: const ValueKey("roomsListDebug"),
        );
      },
    );
  }
}
