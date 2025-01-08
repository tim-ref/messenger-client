// Mocks generated by Mockito 5.4.2 from annotations
// in fluffychat/test/tim/feature/automated_invite_rejection/invite_rejection_policy_repository_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;

import 'package:fluffychat/tim/shared/matrix/tim_matrix_client.dart' as _i4;
import 'package:matrix/matrix.dart' as _i3;
import 'package:matrix/src/utils/cached_stream_controller.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeUri_0 extends _i1.SmartFake implements Uri {
  _FakeUri_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeCachedStreamController_1<T> extends _i1.SmartFake
    implements _i2.CachedStreamController<T> {
  _FakeCachedStreamController_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeGetRoomEventsResponse_2 extends _i1.SmartFake
    implements _i3.GetRoomEventsResponse {
  _FakeGetRoomEventsResponse_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [TimMatrixClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockTimMatrixClient extends _i1.Mock implements _i4.TimMatrixClient {
  @override
  String get userID => (super.noSuchMethod(
        Invocation.getter(#userID),
        returnValue: '',
        returnValueForMissingStub: '',
      ) as String);
  @override
  String get accessToken => (super.noSuchMethod(
        Invocation.getter(#accessToken),
        returnValue: '',
        returnValueForMissingStub: '',
      ) as String);
  @override
  Uri get homeserver => (super.noSuchMethod(
        Invocation.getter(#homeserver),
        returnValue: _FakeUri_0(
          this,
          Invocation.getter(#homeserver),
        ),
        returnValueForMissingStub: _FakeUri_0(
          this,
          Invocation.getter(#homeserver),
        ),
      ) as Uri);
  @override
  _i2.CachedStreamController<_i3.EventUpdate> get onEventUpdate =>
      (super.noSuchMethod(
        Invocation.getter(#onEventUpdate),
        returnValue: _FakeCachedStreamController_1<_i3.EventUpdate>(
          this,
          Invocation.getter(#onEventUpdate),
        ),
        returnValueForMissingStub:
            _FakeCachedStreamController_1<_i3.EventUpdate>(
          this,
          Invocation.getter(#onEventUpdate),
        ),
      ) as _i2.CachedStreamController<_i3.EventUpdate>);
  @override
  _i5.Future<String?> getDisplayName(String? userId) => (super.noSuchMethod(
        Invocation.method(
          #getDisplayName,
          [userId],
        ),
        returnValue: _i5.Future<String?>.value(),
        returnValueForMissingStub: _i5.Future<String?>.value(),
      ) as _i5.Future<String?>);
  @override
  _i3.Room? getRoomById(String? id) => (super.noSuchMethod(
        Invocation.method(
          #getRoomById,
          [id],
        ),
        returnValueForMissingStub: null,
      ) as _i3.Room?);
  @override
  _i5.Future<_i3.GetRoomEventsResponse> getRoomEvents(
    String? roomId,
    _i3.Direction? dir, {
    String? from,
    String? to,
    int? limit,
    String? filter,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getRoomEvents,
          [
            roomId,
            dir,
          ],
          {
            #from: from,
            #to: to,
            #limit: limit,
            #filter: filter,
          },
        ),
        returnValue: _i5.Future<_i3.GetRoomEventsResponse>.value(
            _FakeGetRoomEventsResponse_2(
          this,
          Invocation.method(
            #getRoomEvents,
            [
              roomId,
              dir,
            ],
            {
              #from: from,
              #to: to,
              #limit: limit,
              #filter: filter,
            },
          ),
        )),
        returnValueForMissingStub: _i5.Future<_i3.GetRoomEventsResponse>.value(
            _FakeGetRoomEventsResponse_2(
          this,
          Invocation.method(
            #getRoomEvents,
            [
              roomId,
              dir,
            ],
            {
              #from: from,
              #to: to,
              #limit: limit,
              #filter: filter,
            },
          ),
        )),
      ) as _i5.Future<_i3.GetRoomEventsResponse>);
  @override
  _i5.Future<String> startDirectChat(
    String? mxid, {
    bool? enableEncryption,
    List<_i3.StateEvent>? initialState,
    bool? waitForSync = true,
    Map<String, dynamic>? powerLevelContentOverride,
    _i3.CreateRoomPreset? preset = _i3.CreateRoomPreset.trustedPrivateChat,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #startDirectChat,
          [mxid],
          {
            #enableEncryption: enableEncryption,
            #initialState: initialState,
            #waitForSync: waitForSync,
            #powerLevelContentOverride: powerLevelContentOverride,
            #preset: preset,
          },
        ),
        returnValue: _i5.Future<String>.value(''),
        returnValueForMissingStub: _i5.Future<String>.value(''),
      ) as _i5.Future<String>);
  @override
  _i5.Future<String> startDirectChatWithCustomRoomType(
    String? mxid, {
    bool? isCaseReference = false,
    Map<String, dynamic>? creationContent,
    List<_i3.Invite3pid>? invite3pid,
    String? name,
    String? roomAliasName,
    String? roomVersion,
    String? topic,
    _i3.Visibility? visibility,
    bool? enableEncryption,
    List<_i3.StateEvent>? initialState,
    bool? waitForSync = true,
    Map<String, dynamic>? powerLevelContentOverride,
    _i3.CreateRoomPreset? preset = _i3.CreateRoomPreset.trustedPrivateChat,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #startDirectChatWithCustomRoomType,
          [mxid],
          {
            #isCaseReference: isCaseReference,
            #creationContent: creationContent,
            #invite3pid: invite3pid,
            #name: name,
            #roomAliasName: roomAliasName,
            #roomVersion: roomVersion,
            #topic: topic,
            #visibility: visibility,
            #enableEncryption: enableEncryption,
            #initialState: initialState,
            #waitForSync: waitForSync,
            #powerLevelContentOverride: powerLevelContentOverride,
            #preset: preset,
          },
        ),
        returnValue: _i5.Future<String>.value(''),
        returnValueForMissingStub: _i5.Future<String>.value(''),
      ) as _i5.Future<String>);
  @override
  _i5.Future<String> createGroupChatWithCustomRoomType({
    bool? isCaseReference = false,
    String? name,
    bool? enableEncryption,
    List<String>? invite,
    _i3.CreateRoomPreset? preset = _i3.CreateRoomPreset.privateChat,
    List<_i3.StateEvent>? initialState,
    _i3.Visibility? visibility,
    bool? waitForSync = true,
    bool? groupCall = false,
    Map<String, dynamic>? powerLevelContentOverride,
    Map<String, dynamic>? creationContent,
    List<_i3.Invite3pid>? invite3pid,
    bool? isDirect = false,
    String? roomAliasName,
    String? roomVersion,
    String? topic,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #createGroupChatWithCustomRoomType,
          [],
          {
            #isCaseReference: isCaseReference,
            #name: name,
            #enableEncryption: enableEncryption,
            #invite: invite,
            #preset: preset,
            #initialState: initialState,
            #visibility: visibility,
            #waitForSync: waitForSync,
            #groupCall: groupCall,
            #powerLevelContentOverride: powerLevelContentOverride,
            #creationContent: creationContent,
            #invite3pid: invite3pid,
            #isDirect: isDirect,
            #roomAliasName: roomAliasName,
            #roomVersion: roomVersion,
            #topic: topic,
          },
        ),
        returnValue: _i5.Future<String>.value(''),
        returnValueForMissingStub: _i5.Future<String>.value(''),
      ) as _i5.Future<String>);
  @override
  _i2.CachedStreamController<_i3.BasicEvent> onAccountDataChange() =>
      (super.noSuchMethod(
        Invocation.method(
          #onAccountDataChange,
          [],
        ),
        returnValue: _FakeCachedStreamController_1<_i3.BasicEvent>(
          this,
          Invocation.method(
            #onAccountDataChange,
            [],
          ),
        ),
        returnValueForMissingStub:
            _FakeCachedStreamController_1<_i3.BasicEvent>(
          this,
          Invocation.method(
            #onAccountDataChange,
            [],
          ),
        ),
      ) as _i2.CachedStreamController<_i3.BasicEvent>);
  @override
  _i5.Future<void> setAccountData(
    String? userId,
    String? type,
    Map<String, dynamic>? content,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #setAccountData,
          [
            userId,
            type,
            content,
          ],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<Map<String, dynamic>> getAccountData(
    String? userId,
    String? type,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #getAccountData,
          [
            userId,
            type,
          ],
        ),
        returnValue:
            _i5.Future<Map<String, dynamic>>.value(<String, dynamic>{}),
        returnValueForMissingStub:
            _i5.Future<Map<String, dynamic>>.value(<String, dynamic>{}),
      ) as _i5.Future<Map<String, dynamic>>);
  @override
  void leaveRoom(
    String? roomId, {
    String? reason,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #leaveRoom,
          [roomId],
          {#reason: reason},
        ),
        returnValueForMissingStub: null,
      );
}
