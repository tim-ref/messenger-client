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

import 'package:json_annotation/json_annotation.dart';
import 'package:matrix/matrix.dart';

part 'debug_dtos.g.dart';

@JsonSerializable()
class RoomDebugDto {
  String roomId;
  String? name;
  String roomAccess;
  bool isEncrypted;
  List<MemberDebugDto> members;
  String? directChatMatrixID;
  List<StateDebugDto> states;

  RoomDebugDto(
    this.roomId,
    this.name,
    this.roomAccess,
    this.isEncrypted,
    this.members,
    this.directChatMatrixID,
    this.states,
  );

  Map<String, dynamic> toJson() => _$RoomDebugDtoToJson(this);

  factory RoomDebugDto.fromJson(Map<String, dynamic> json) =>
      _$RoomDebugDtoFromJson(json);

  factory RoomDebugDto.fromMatrixRoom(Room r) {
    final members = r
        .getParticipants()
        .map((e) => MemberDebugDto(e.id, _getMemberState(e)))
        .toList();
    final roomAccess = r.joinRules == JoinRules.public ? "public" : "private";
    final roomStates = generateListFromStates(r.states)
        .map((e) => StateDebugDto(
              e.content.toString(),
              e.eventId,
              e.roomId,
              e.senderId,
              e.stateKey,
              e.type,
            ))
        .toList();

    return RoomDebugDto(
      r.id,
      r.name,
      roomAccess,
      r.encrypted,
      members,
      r.directChatMatrixID,
      roomStates,
    );
  }
}

String _getMemberState(User e) {
  if (e.content['membership'] != null) {
    return e.membership.toString();
  } else {
    return Membership.invite.toString();
  }
}

@JsonSerializable()
class MemberDebugDto {
  String mxid;
  String membershipState;

  MemberDebugDto(this.mxid, this.membershipState);

  Map<String, dynamic> toJson() => _$MemberDebugDtoToJson(this);

  factory MemberDebugDto.fromJson(Map<String, dynamic> json) =>
      _$MemberDebugDtoFromJson(json);
}

@JsonSerializable()
class StateDebugDto {
  String content;
  String eventId;
  String? roomId;
  String sender;
  String? stateKey;
  String type;

  StateDebugDto(
    this.content,
    this.eventId,
    this.roomId,
    this.sender,
    this.stateKey,
    this.type,
  );

  Map<String, dynamic> toJson() => _$StateDebugDtoToJson(this);

  factory StateDebugDto.fromJson(Map<String, dynamic> json) =>
      _$StateDebugDtoFromJson(json);
}

List<Event> generateListFromStates(Map<String, Map<String, Event>> states) {
  // first turn the outer map into a list of all inner maps
  final outerMapAsList = states.entries.map((entry) => entry.value).toList();
  // then turn all the inner maps into lists
  final innerMapsAsLists = outerMapAsList
      .map((m) => m.entries.map((e) => e.value).toList())
      .toList();
  // then flatten the list of lists to get all events as a list
  final flattenedList = innerMapsAsLists.flatten();
  return flattenedList;
}

extension Flatten<T> on List<List<T>> {
  List<T> flatten() {
    return expand((i) => i).toList();
  }
}

String timelineToMessageJsonString(Timeline t) {
  final List<MessageDebugDto> dtos = keepMessageEvents(t)
      .map(
        (e) => MessageDebugDto(
          e.eventId,
          e.originServerTs.toUtc().toIso8601String(),
          e.content["msgtype"] == "m.text" ? e.text : e.content["fileName"],
          e.senderId,
          e.content["msgtype"] ?? "",
          const JsonEncoder().convert(e),
          e.content["fileId"],
        ),
      )
      .toList();
  return const JsonEncoder().convert(dtos);
}

List<Event> keepMessageEvents(Timeline timeline) {
  return timeline.events
      .where((event) => event.type == "m.room.message")
      .toList();
}

@JsonSerializable(createFactory: false)
class MessageDebugDto {
  String messageId;
  String timestamp;
  String body;
  String sender;
  String type;
  String debugString;
  String? fileId;

  MessageDebugDto(
    this.messageId,
    this.timestamp,
    this.body,
    this.sender,
    this.type,
    this.debugString,
    this.fileId,
  );

  Map<String, dynamic> toJson() => _$MessageDebugDtoToJson(this);
}

@JsonSerializable(createFactory: false)
class UserSearchResultDebugDto {
  String? displayName;
  String mxId;

  UserSearchResultDebugDto(this.displayName, this.mxId);

  Map<String, dynamic> toJson() => _$UserSearchResultDebugDtoToJson(this);
}
