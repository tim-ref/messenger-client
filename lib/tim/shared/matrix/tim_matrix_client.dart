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
import 'package:fluffychat/tim/shared/matrix/tim_case_reference_content_blob.dart';
import 'package:fluffychat/tim/tim_constants.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix/src/utils/cached_stream_controller.dart';

/// Abstraction to access Matrix data.
abstract class TimMatrixClient {
  String get userID;

  String get accessToken;

  Uri get homeserver;

  /// Lauschen auf neue EventUpdates aus Matrix.Client
  CachedStreamController<EventUpdate> get onEventUpdate;

  Future<String?> getDisplayName(String userId);

  Room? getRoomById(String id);

  /// See [Client.getRoomEvents].
  Future<GetRoomEventsResponse> getRoomEvents(
    String roomId,
    Direction dir, {
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

  Future<String> startDirectChatWithCustomRoomType(
    String mxid, {
    bool isCaseReference = false,
    Map<String, dynamic>? creationContent,
    List<Invite3pid>? invite3pid,
    String? name,
    String? roomAliasName,
    String? roomVersion,
    String? topic,
    Visibility? visibility,
    bool? enableEncryption,
    List<StateEvent>? initialState,
    bool waitForSync = true,
    Map<String, dynamic>? powerLevelContentOverride,
    CreateRoomPreset? preset = CreateRoomPreset.trustedPrivateChat,
  });

  Future<String> createGroupChatWithCustomRoomType({
    bool isCaseReference = false,
    String? name,
    bool? enableEncryption,
    List<String>? invite,
    CreateRoomPreset preset = CreateRoomPreset.privateChat,
    List<StateEvent>? initialState,
    Visibility? visibility,
    bool waitForSync = true,
    bool groupCall = false,
    Map<String, dynamic>? powerLevelContentOverride,
    Map<String, dynamic>? creationContent,
    List<Invite3pid>? invite3pid,
    bool? isDirect = false,
    String? roomAliasName,
    String? roomVersion,
    String? topic,
  });

  CachedStreamController<BasicEvent> onAccountDataChange();

  Future<void> setAccountData(String userId, String type, Map<String, dynamic> content);

  Future<Map<String, dynamic>> getAccountData(String userId, String type);

  /// Verlasse Raum mit ID [roomId] (OPTIONAL: , aus folgenden Grund: [reason])
  void leaveRoom(String roomId, {String? reason});
}

class TimMatrixClientImpl implements TimMatrixClient {
  final Client _client;

  TimMatrixClientImpl({required Client client}) : _client = client;

  @override
  String get userID {
    if (_client.userID == null || _client.userID!.isEmpty) {
      throw (TimBadStateException('client.userID must not be null or empty'));
    }
    return _client.userID!;
  }

  @override
  String get accessToken {
    if (_client.accessToken == null || _client.accessToken!.isEmpty) {
      throw (TimBadStateException(
        'client.accessToken must not be null or empty',
      ));
    }
    return _client.accessToken!;
  }

  @override
  Uri get homeserver {
    if (_client.homeserver == null) {
      throw (TimBadStateException('client.accessToken must not be null'));
    }
    return _client.homeserver!;
  }

  @override
  CachedStreamController<EventUpdate> get onEventUpdate => _client.onEvent;

  @override
  Future<String?> getDisplayName(String userId) => _client.getDisplayName(userId);

  @override
  Room? getRoomById(String id) => _client.getRoomById(id);

  @override
  Future<GetRoomEventsResponse> getRoomEvents(
    String roomId,
    Direction dir, {
    String? from,
    String? to,
    int? limit,
    String? filter,
  }) =>
      _client.getRoomEvents(
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
  }) =>
      _client.startDirectChat(
        mxid,
        enableEncryption: enableEncryption,
        initialState: initialState,
        waitForSync: waitForSync,
        powerLevelContentOverride: powerLevelContentOverride,
        preset: preset,
      );

  /// Returns an existing direct room ID with this user or creates a new one.
  /// By default encryption will be enabled if the client supports encryption
  /// and the other user has uploaded any encryption keys.
  @override
  Future<String> startDirectChatWithCustomRoomType(
    String mxid, {
    bool isCaseReference = false,
    Map<String, dynamic>? creationContent,
    List<Invite3pid>? invite3pid,
    String? name,
    String? roomAliasName,
    String? roomVersion,
    String? topic,
    Visibility? visibility,
    bool? enableEncryption,
    List<StateEvent>? initialState,
    bool waitForSync = true,
    Map<String, dynamic>? powerLevelContentOverride,
    CreateRoomPreset? preset = CreateRoomPreset.trustedPrivateChat,
  }) async {
    // Try to find an existing direct chat
    final directChatRoomId = _client.getDirectChatFromUserId(mxid);
    if (directChatRoomId != null) return directChatRoomId;

    creationContent ??= {};
    initialState ??= [];

    if (!creationContent.containsKey('type')) {
      creationContent['type'] =
          isCaseReference ? TimRoomType.caseReference.value : TimRoomType.defaultValue.value;

      if (!initialState.any(
        (element) =>
            element.type == TimRoomStateEventType.caseReference.value ||
            element.type == TimRoomStateEventType.defaultValue.value,
      )) {
        initialState.add(
          isCaseReference
              ? StateEvent(
                  content: timCaseReferenceContentBlob,
                  type: TimRoomStateEventType.caseReference.value,
                )
              : StateEvent(
                  content: {},
                  type: TimRoomStateEventType.defaultValue.value,
                ),
        );
      }
    }

    enableEncryption ??= _client.encryptionEnabled && await _client.userOwnsEncryptionKeys(mxid);
    if (enableEncryption) {
      if (!initialState.any((s) => s.type == EventTypes.Encryption)) {
        initialState.add(
          StateEvent(
            content: {
              'algorithm': Client.supportedGroupEncryptionAlgorithms.first,
            },
            type: EventTypes.Encryption,
          ),
        );
      }
    }

    if (name != null &&
        !initialState.any(
          (element) => element.type == TimRoomStateEventType.roomName.value,
        )) {
      initialState.add(
        StateEvent(content: {'name': name}, type: TimRoomStateEventType.roomName.value),
      );
    }

    if (topic != null &&
        !initialState.any(
          (element) => element.type == TimRoomStateEventType.roomTopic.value,
        )) {
      initialState.add(
        StateEvent(content: {'topic': topic}, type: TimRoomStateEventType.roomTopic.value),
      );
    }

    // Start a new direct chat
    final roomId = await _client.createRoom(
      isDirect: true,
      invite: [mxid],
      name: "",
      topic: "",
      creationContent: creationContent,
      initialState: initialState,
      invite3pid: invite3pid,
      roomAliasName: roomAliasName,
      roomVersion: roomVersion,
      visibility: visibility,
      preset: preset,
      powerLevelContentOverride: powerLevelContentOverride,
    );

    if (waitForSync && getRoomById(roomId) == null) {
      // Wait for room actually appears in sync
      await _client.waitForRoomInSync(roomId, join: true);
    }

    await Room(id: roomId, client: _client).addToDirectChat(mxid);

    return roomId;
  }

  /// Simplified method to create a new group chat. By default it is a private
  /// chat. The encryption is enabled if this client supports encryption and
  /// the preset is not a public chat.
  @override
  Future<String> createGroupChatWithCustomRoomType({
    bool isCaseReference = false,
    String? name,
    bool? enableEncryption,
    List<String>? invite,
    CreateRoomPreset preset = CreateRoomPreset.privateChat,
    List<StateEvent>? initialState,
    Visibility? visibility,
    bool waitForSync = true,
    bool groupCall = false,
    Map<String, dynamic>? powerLevelContentOverride,
    Map<String, dynamic>? creationContent,
    List<Invite3pid>? invite3pid,
    bool? isDirect = false,
    String? roomAliasName,
    String? roomVersion,
    String? topic,
  }) async {
    creationContent ??= {};
    initialState ??= [];

    if (!creationContent.containsKey('type')) {
      creationContent['type'] =
          isCaseReference ? TimRoomType.caseReference.value : TimRoomType.defaultValue.value;

      if (!initialState.any(
        (element) =>
            element.type == TimRoomStateEventType.caseReference.value ||
            element.type == TimRoomStateEventType.defaultValue.value,
      )) {
        initialState.add(
          isCaseReference
              ? StateEvent(
                  content: timCaseReferenceContentBlob,
                  type: TimRoomStateEventType.caseReference.value,
                )
              : StateEvent(
                  content: {},
                  type: TimRoomStateEventType.defaultValue.value,
                ),
        );
      }
    }

    enableEncryption ??= _client.encryptionEnabled && preset != CreateRoomPreset.publicChat;
    if (enableEncryption && !initialState.any((s) => s.type == EventTypes.Encryption)) {
      initialState.add(
        StateEvent(
          content: {
            'algorithm': Client.supportedGroupEncryptionAlgorithms.first,
          },
          type: EventTypes.Encryption,
        ),
      );
    }

    if (groupCall) {
      powerLevelContentOverride ??= {};
      powerLevelContentOverride['events'] ??= {};
      powerLevelContentOverride['events'][EventTypes.GroupCallMember] ??=
          powerLevelContentOverride['events_default'] ?? 0;
    }

    if (name != null &&
        !initialState.any(
          (element) => element.type == TimRoomStateEventType.roomName.value,
        )) {
      initialState.add(
        StateEvent(content: {'name': name}, type: TimRoomStateEventType.roomName.value),
      );
    }

    if (topic != null &&
        !initialState.any(
          (element) => element.type == TimRoomStateEventType.roomTopic.value,
        )) {
      initialState.add(
        StateEvent(content: {'topic': topic}, type: TimRoomStateEventType.roomTopic.value),
      );
    }

    final roomId = await _client.createRoom(
      invite: invite,
      preset: preset,
      name: "",
      initialState: initialState,
      visibility: visibility,
      powerLevelContentOverride: powerLevelContentOverride,
      creationContent: creationContent,
      invite3pid: invite3pid,
      isDirect: isDirect,
      roomAliasName: roomAliasName,
      roomVersion: roomVersion,
      topic: "",
    );

    if (waitForSync && getRoomById(roomId) == null) {
      // Wait for room actually appears in sync
      await _client.waitForRoomInSync(roomId, join: true);
    }
    return roomId;
  }

  @override
  void leaveRoom(String roomId, {String? reason}) => _client.leaveRoom(roomId, reason: reason);

  @override
  CachedStreamController<BasicEvent> onAccountDataChange() => _client.onAccountData;

  @override
  Future<void> setAccountData(String userId, String type, Map<String, dynamic> content) =>
      _client.setAccountData(userId, type, content);

  @override
  Future<Map<String, dynamic>> getAccountData(String userId, String type) =>
      _client.getAccountData(userId, type);
}
