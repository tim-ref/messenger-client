// Mocks generated by Mockito 5.4.2 from annotations
// in fluffychat/test/tim/share_room_archive_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:fluffychat/tim/shared/matrix/tim_matrix_client.dart' as _i3;
import 'package:fluffychat/tim/shared/matrix/tim_matrix_crypto.dart' as _i5;
import 'package:matrix/matrix.dart' as _i2;
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

class _FakeGetRoomEventsResponse_1 extends _i1.SmartFake implements _i2.GetRoomEventsResponse {
  _FakeGetRoomEventsResponse_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeEvent_2 extends _i1.SmartFake implements _i2.Event {
  _FakeEvent_2(
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
class MockTimMatrixClient extends _i1.Mock implements _i3.TimMatrixClient {
  MockTimMatrixClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get userID => (super.noSuchMethod(
        Invocation.getter(#userID),
        returnValue: '',
      ) as String);
  @override
  String get accessToken => (super.noSuchMethod(
        Invocation.getter(#accessToken),
        returnValue: '',
      ) as String);
  @override
  Uri get homeserver => (super.noSuchMethod(
        Invocation.getter(#homeserver),
        returnValue: _FakeUri_0(
          this,
          Invocation.getter(#homeserver),
        ),
      ) as Uri);
  @override
  _i4.Future<String?> getDisplayName(String? userId) => (super.noSuchMethod(
        Invocation.method(
          #getDisplayName,
          [userId],
        ),
        returnValue: _i4.Future<String?>.value(),
      ) as _i4.Future<String?>);
  @override
  _i2.Room? getRoomById(String? id) => (super.noSuchMethod(Invocation.method(
        #getRoomById,
        [id],
      )) as _i2.Room?);
  @override
  _i4.Future<_i2.GetRoomEventsResponse> getRoomEvents(
    String? roomId,
    _i2.Direction? dir, {
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
        returnValue: _i4.Future<_i2.GetRoomEventsResponse>.value(_FakeGetRoomEventsResponse_1(
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
      ) as _i4.Future<_i2.GetRoomEventsResponse>);
  @override
  _i4.Future<String> startDirectChat(
    String? mxid, {
    bool? enableEncryption,
    List<_i2.StateEvent>? initialState,
    bool? waitForSync = true,
    Map<String, dynamic>? powerLevelContentOverride,
    _i2.CreateRoomPreset? preset = _i2.CreateRoomPreset.trustedPrivateChat,
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
        returnValue: _i4.Future<String>.value(''),
      ) as _i4.Future<String>);
  @override
  _i4.Future<String> startDirectChatWithCustomRoomType(
    String? mxid, {
    bool? isCaseReference = false,
    Map<String, dynamic>? creationContent,
    List<_i2.Invite3pid>? invite3pid,
    String? name,
    String? roomAliasName,
    String? roomVersion,
    String? topic,
    _i2.Visibility? visibility,
    bool? enableEncryption,
    List<_i2.StateEvent>? initialState,
    bool? waitForSync = true,
    Map<String, dynamic>? powerLevelContentOverride,
    _i2.CreateRoomPreset? preset = _i2.CreateRoomPreset.trustedPrivateChat,
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
        returnValue: _i4.Future<String>.value(''),
      ) as _i4.Future<String>);
  @override
  _i4.Future<String> createGroupChatWithCustomRoomType({
    bool? isCaseReference = false,
    String? name,
    bool? enableEncryption,
    List<String>? invite,
    _i2.CreateRoomPreset? preset = _i2.CreateRoomPreset.privateChat,
    List<_i2.StateEvent>? initialState,
    _i2.Visibility? visibility,
    bool? waitForSync = true,
    bool? groupCall = false,
    Map<String, dynamic>? powerLevelContentOverride,
    Map<String, dynamic>? creationContent,
    List<_i2.Invite3pid>? invite3pid,
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
        returnValue: _i4.Future<String>.value(''),
      ) as _i4.Future<String>);
}

/// A class which mocks [TimMatrixCrypto].
///
/// See the documentation for Mockito's code generation for more information.
class MockTimMatrixCrypto extends _i1.Mock implements _i5.TimMatrixCrypto {
  MockTimMatrixCrypto() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.Event> decryptRoomEvent(
    String? roomId,
    _i2.Event? event,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #decryptRoomEvent,
          [
            roomId,
            event,
          ],
        ),
        returnValue: _i4.Future<_i2.Event>.value(_FakeEvent_2(
          this,
          Invocation.method(
            #decryptRoomEvent,
            [
              roomId,
              event,
            ],
          ),
        )),
      ) as _i4.Future<_i2.Event>);
}
