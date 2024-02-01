// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debug_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomDebugDto _$RoomDebugDtoFromJson(Map<String, dynamic> json) => RoomDebugDto(
      json['roomId'] as String,
      json['name'] as String?,
      json['roomAccess'] as String,
      json['isEncrypted'] as bool,
      (json['members'] as List<dynamic>)
          .map((e) => MemberDebugDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['directChatMatrixID'] as String?,
      (json['states'] as List<dynamic>)
          .map((e) => StateDebugDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RoomDebugDtoToJson(RoomDebugDto instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'name': instance.name,
      'roomAccess': instance.roomAccess,
      'isEncrypted': instance.isEncrypted,
      'members': instance.members,
      'directChatMatrixID': instance.directChatMatrixID,
      'states': instance.states,
    };

MemberDebugDto _$MemberDebugDtoFromJson(Map<String, dynamic> json) =>
    MemberDebugDto(
      json['mxid'] as String,
      json['membershipState'] as String,
    );

Map<String, dynamic> _$MemberDebugDtoToJson(MemberDebugDto instance) =>
    <String, dynamic>{
      'mxid': instance.mxid,
      'membershipState': instance.membershipState,
    };

StateDebugDto _$StateDebugDtoFromJson(Map<String, dynamic> json) =>
    StateDebugDto(
      json['content'] as String,
      json['eventId'] as String,
      json['roomId'] as String?,
      json['sender'] as String,
      json['stateKey'] as String?,
      json['type'] as String,
    );

Map<String, dynamic> _$StateDebugDtoToJson(StateDebugDto instance) =>
    <String, dynamic>{
      'content': instance.content,
      'eventId': instance.eventId,
      'roomId': instance.roomId,
      'sender': instance.sender,
      'stateKey': instance.stateKey,
      'type': instance.type,
    };

Map<String, dynamic> _$MessageDebugDtoToJson(MessageDebugDto instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'timestamp': instance.timestamp,
      'body': instance.body,
      'sender': instance.sender,
      'type': instance.type,
      'debugString': instance.debugString,
      'fileId': instance.fileId,
    };

Map<String, dynamic> _$UserSearchResultDebugDtoToJson(
        UserSearchResultDebugDto instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'mxId': instance.mxId,
    };
