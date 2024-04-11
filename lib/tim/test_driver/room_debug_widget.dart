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

import 'package:collection/collection.dart';
import 'package:fluffychat/tim/test_driver/debug_dtos.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import 'package:vrouter/vrouter.dart';

class RoomDebugWidget extends StatelessWidget {
  const RoomDebugWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncUpdate>(
        stream: Matrix.of(context).client.onSync.stream.where((sync) => sync.rooms != null),
        builder: (context, snapshot) {
          return FutureBuilder<Text>(
              future: buildWidget(context, snapshot),
              builder: (c, s) {
                return s.data ?? _noRoomInfoTextWidget();
              },);
        },);
  }

  Future<Text> buildWidget(
      BuildContext context, AsyncSnapshot<SyncUpdate> snapshot,) async {
    final String? roomId = context.vRouter.pathParameters['roomid'];
    if (roomId == null) {
      return _noRoomInfoTextWidget();
    }

    final client = Matrix.of(context).client;
    final Room? room = client.getRoomById(roomId);
    if (room == null) {
      return _noRoomInfoTextWidget();
    }

    final roomDebugDto = RoomDebugDto.fromMatrixRoom(room);

    final userId = client.userID ?? "";

    // Need to check if user is invited to update widget
    // Joined sync state is not synchronized by the member who joins, needs to load room history, to force state update
    if (_currentMemberIsInvited(roomDebugDto, userId) &&
        _currentMemberIsNotJoined(roomDebugDto, userId)) {
      room.prev_batch = "";
      await room.requestHistory();
    }

    final roomDebugDtoJSON = const JsonEncoder().convert(RoomDebugDto.fromMatrixRoom(room));

    return _debugTextWidget(roomDebugDtoJSON);
  }

  Text _noRoomInfoTextWidget() {
    return const Text(
      "no room info..",
      overflow: TextOverflow.ellipsis,
      key: ValueKey("noRoomInfo"),
    );
  }

  Text _debugTextWidget(String json) {
    return Text(
      json,
      overflow: TextOverflow.ellipsis,
      key: const ValueKey("roomInfo"),
    );
  }

  bool _currentMemberIsInvited(RoomDebugDto roomDebugDto, String userId) {
    final member = _getCurrentMemberByUserId(roomDebugDto, userId);
    return member == null ? false : _isInvited(member);
  }

  bool _currentMemberIsNotJoined(RoomDebugDto roomDebugDto, String userId) {
    final member = _getCurrentMemberByUserId(roomDebugDto, userId);
    return member == null ? true : _isNotJoined(member);
  }

  MemberDebugDto? _getCurrentMemberByUserId(
      RoomDebugDto roomDebugDto, String userId,) {
    return roomDebugDto.members
        .firstWhereOrNull((member) => member.mxid == userId);
  }

  bool _isNotJoined(MemberDebugDto member) {
    return member.membershipState != Membership.join.toString();
  }

  bool _isInvited(MemberDebugDto member) {
    return member.membershipState == Membership.invite.toString();
  }
}
