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

import 'package:fluffychat/utils/matrix_sdk_extensions/room_extension.dart';
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
  String? topic;
  String roomType;
  bool isCaseReference;
  Map<String, dynamic>? caseReferenceContent;

  RoomDebugDto(
    this.roomId,
    this.name,
    this.roomAccess,
    this.isEncrypted,
    this.members,
    this.directChatMatrixID,
    this.states,
    this.topic,
    this.roomType,
    this.isCaseReference,
    this.caseReferenceContent,
  );

  Map<String, dynamic> toJson() => _$RoomDebugDtoToJson(this);

  factory RoomDebugDto.fromJson(Map<String, dynamic> json) => _$RoomDebugDtoFromJson(json);

  static final _inviteMembership = Membership.invite.toString();
  static final _joinMembership = Membership.join.toString();

  static Future<RoomDebugDto> getDtoFromMatrixRoom(Room r, Client client) async {
    final roomStates = generateListFromStates(r.states);
    // https://spec.matrix.org/v1.11/rooms/v11/#event-format
    // „Clients should no longer depend on the creator property in the content of m.room.create events.
    //  In all room versions, clients can rely on sender instead to determine a room creator.”
    final senderId = roomStates.firstWhere((e) => e.type == EventTypes.RoomCreate).senderId;
    final roomAccess = r.joinRules == JoinRules.public ? "public" : "private";

    final members =
        r.getParticipants().map((e) => MemberDebugDto(e.id, getMemberState(e, senderId))).toList();

    for (int i = 0; i < members.length; i++) {
      final dbUser = await client.database?.getUser(members[i].mxid, r);
      if (dbUser != null) {
        final userIndex = members.indexWhere((element) => element.mxid == dbUser.id);

        members[userIndex] = MemberDebugDto(dbUser.id, getMemberState(dbUser, senderId));
      }
    }

    // sender of room create event is invite which should be join
    if (members.any(
      (member) => member.mxid == senderId && member.membershipState == _inviteMembership,
    )) {
      members.firstWhere((member) => member.mxid == senderId).membershipState = _joinMembership;
    }

    final roomStateDebugDtos = roomStates.map((e) {
      String? eventId;
      String? roomId;
      if (e.runtimeType is Event) {
        eventId = (e as Event).eventId;
        roomId = e.roomId;
      }

      return StateDebugDto(
        e.content.toString(),
        eventId,
        roomId,
        e.senderId,
        e.stateKey,
        e.type,
      );
    }).toList();

    return RoomDebugDto(
      r.id,
      r.displayName,
      roomAccess,
      r.encrypted,
      members,
      r.directChatMatrixID,
      roomStateDebugDtos,
      r.displayTopic,
      r.roomType,
      r.isCaseReferenceRoom,
      r.caseReferenceContent,
    );
  }
}

// Fix membership state issue
//
// User.membership returns membership.join as default if missing =>
// invited member is joined before join was triggered
String getMemberState(User e, String senderId) {
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

  factory MemberDebugDto.fromJson(Map<String, dynamic> json) => _$MemberDebugDtoFromJson(json);
}

@JsonSerializable()
class StateDebugDto {
  String content;
  String? eventId;
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

  factory StateDebugDto.fromJson(Map<String, dynamic> json) => _$StateDebugDtoFromJson(json);
}

List<StrippedStateEvent> generateListFromStates(
    Map<String, Map<String, StrippedStateEvent>> states) {
  // first turn the outer map into a list of all inner maps
  final outerMapAsList = states.entries.map((entry) => entry.value).toList();
  // then turn all the inner maps into lists
  final innerMapsAsLists =
      outerMapAsList.map((m) => m.entries.map((e) => e.value).toList()).toList();
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
          e.messageType == "m.text" ? e.text : e.content.tryGet("fileName") ?? e.text,
          e.senderId,
          e.messageType,
          const JsonEncoder().convert(e),
          e.messageType == "m.text" ? null : (e.content.tryGet("fileId") ?? e.text),
        ),
      )
      .toList();
  return const JsonEncoder().convert(dtos);
}

List<Event> keepMessageEvents(Timeline timeline) {
  return timeline.events.where((event) => event.type == "m.room.message").toList();
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
