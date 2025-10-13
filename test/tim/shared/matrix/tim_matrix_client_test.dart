/*
 * TIM-Referenzumgebung
 * Copyright (C) 2025 - akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/tim/shared/matrix/tim_case_reference_content_blob.dart';
import 'package:fluffychat/tim/shared/matrix/tim_matrix_client.dart';
import 'package:fluffychat/tim/tim_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([Client])
import 'tim_matrix_client_test.mocks.dart';

void main() {
  const roomId = 'roomId';
  const userId = 'userId';

  final mockMatrixClient = MockClient();
  final timMatrixClient = TimMatrixClientImpl(client: mockMatrixClient);

  setUp(() {
    reset(mockMatrixClient);
    when(
      mockMatrixClient.createRoom(
        isDirect: anyNamed('isDirect'),
        preset: anyNamed('preset'),
        name: anyNamed('name'),
        topic: anyNamed('topic'),
        creationContent: anyNamed('creationContent'),
        initialState: anyNamed('initialState'),
        invite: anyNamed('invite'),
        invite3pid: anyNamed('invite3pid'),
        powerLevelContentOverride: anyNamed('powerLevelContentOverride'),
        roomAliasName: anyNamed('roomAliasName'),
        roomVersion: anyNamed('roomVersion'),
        visibility: anyNamed('visibility'),
      ),
    ).thenAnswer((_) async => roomId);
    when(mockMatrixClient.getDirectChatFromUserId(any)).thenReturn(null);
    when(mockMatrixClient.encryptionEnabled).thenReturn(true);
    when(mockMatrixClient.userOwnsEncryptionKeys(any)).thenAnswer((_) async => true);
    when(mockMatrixClient.getRoomById(roomId)).thenAnswer((realInvocation) => null);
    when(mockMatrixClient.waitForRoomInSync(roomId, join: true, invite: false, leave: false))
        .thenAnswer((realInvocation) async => SyncUpdate(nextBatch: ''));
    when(mockMatrixClient.directChats).thenReturn({
      userId: [roomId],
    });
  });

  group("startDirectChatWithCustomRoomType", () {
    test('should create room with TIM default room type and default room events', () async {
      const name = 'roomName';
      const topic = 'roomTopic';

      final expectedInitialStates = [
        StateEvent(
          content: {},
          type: TimRoomStateEventType.defaultValue.value,
        ),
        StateEvent(
          content: {
            'algorithm': Client.supportedGroupEncryptionAlgorithms.first,
          },
          type: EventTypes.Encryption,
        ),
        StateEvent(
          content: {
            'name': name,
          },
          type: TimRoomStateEventType.roomName.value,
        ),
        StateEvent(
          content: {
            'topic': topic,
          },
          type: TimRoomStateEventType.roomTopic.value,
        ),
        StateEvent(
          content: {
            'history_visibility': defaultHistoryVisibility,
          },
          type: EventTypes.HistoryVisibility,
        ),
      ];

      expect(
        await timMatrixClient.startDirectChatWithCustomRoomType(
          userId,
          name: name,
          topic: topic,
        ),
        roomId,
      );

      verify(
        mockMatrixClient.createRoom(
          isDirect: true,
          preset: CreateRoomPreset.trustedPrivateChat,
          name: name,
          topic: topic,
          creationContent: {'type': TimRoomType.defaultValue.value},
          initialState: argThat(
            pairwiseCompare<StateEvent, StateEvent>(
              expectedInitialStates,
              compareStateEvents,
              'initialState',
            ),
            named: 'initialState',
          ),
          invite: anyNamed('invite'),
          invite3pid: anyNamed('invite3pid'),
          powerLevelContentOverride: anyNamed('powerLevelContentOverride'),
          roomAliasName: anyNamed('roomAliasName'),
          roomVersion: anyNamed('roomVersion'),
          visibility: anyNamed('visibility'),
        ),
      ).called(1);
    });

    test('can create room without name or topic', () async {
      expect(
        await timMatrixClient.startDirectChatWithCustomRoomType(userId),
        roomId,
      );

      final verificationResult = verify(
        mockMatrixClient.createRoom(
          isDirect: true,
          preset: CreateRoomPreset.trustedPrivateChat,
          name: null,
          topic: null,
          creationContent: {'type': TimRoomType.defaultValue.value},
          initialState: captureAnyNamed('initialState'),
          invite: anyNamed('invite'),
          invite3pid: anyNamed('invite3pid'),
          powerLevelContentOverride: anyNamed('powerLevelContentOverride'),
          roomAliasName: anyNamed('roomAliasName'),
          roomVersion: anyNamed('roomVersion'),
          visibility: anyNamed('visibility'),
        ),
      );
      verificationResult.called(1);
      expect(
        verificationResult.captured.single,
        isNot(
          contains(
            anyOf(
              isA<StateEvent>().having((e) => e.type, 'type', TimRoomStateEventType.roomName.value),
              isA<StateEvent>()
                  .having((e) => e.type, 'type', TimRoomStateEventType.roomTopic.value),
            ),
          ),
        ),
      );
    });

    test(
        'with casereference should create room with TIM casereference room type and casereference room events',
        () async {
      const name = 'roomName';
      const topic = 'roomTopic';

      final expectedInitialStates = [
        StateEvent(
          content: timCaseReferenceContentBlob,
          type: TimRoomStateEventType.caseReference.value,
        ),
        StateEvent(
          content: {
            'algorithm': Client.supportedGroupEncryptionAlgorithms.first,
          },
          type: EventTypes.Encryption,
        ),
        StateEvent(
          content: {
            'name': name,
          },
          type: TimRoomStateEventType.roomName.value,
        ),
        StateEvent(
          content: {
            'topic': topic,
          },
          type: TimRoomStateEventType.roomTopic.value,
        ),
        StateEvent(
          content: {
            'history_visibility': defaultHistoryVisibility,
          },
          type: EventTypes.HistoryVisibility,
        ),
      ];

      expect(
        await timMatrixClient.startDirectChatWithCustomRoomType(
          userId,
          name: name,
          topic: topic,
          isCaseReference: true,
        ),
        roomId,
      );

      verify(
        mockMatrixClient.createRoom(
          isDirect: true,
          preset: CreateRoomPreset.trustedPrivateChat,
          name: name,
          topic: topic,
          creationContent: {'type': TimRoomType.caseReference.value},
          initialState: argThat(
            pairwiseCompare<StateEvent, StateEvent>(
              expectedInitialStates,
              compareStateEvents,
              'initialState',
            ),
            named: 'initialState',
          ),
          invite: anyNamed('invite'),
          invite3pid: anyNamed('invite3pid'),
          powerLevelContentOverride: anyNamed('powerLevelContentOverride'),
          roomAliasName: anyNamed('roomAliasName'),
          roomVersion: anyNamed('roomVersion'),
          visibility: anyNamed('visibility'),
        ),
      ).called(1);
    });
  });

  group("createGroupChatWithCustomRoomType", () {
    test('should create room with TIM default room type and default room events', () async {
      const name = 'roomName';
      const topic = 'roomTopic';

      final expectedInitialStates = [
        StateEvent(
          content: {},
          type: TimRoomStateEventType.defaultValue.value,
        ),
        StateEvent(
          content: {
            'algorithm': Client.supportedGroupEncryptionAlgorithms.first,
          },
          type: EventTypes.Encryption,
        ),
        StateEvent(
          content: {
            'name': name,
          },
          type: TimRoomStateEventType.roomName.value,
        ),
        StateEvent(
          content: {
            'topic': topic,
          },
          type: TimRoomStateEventType.roomTopic.value,
        ),
        StateEvent(
          content: {
            'history_visibility': defaultHistoryVisibility,
          },
          type: EventTypes.HistoryVisibility,
        ),
      ];

      expect(
        await timMatrixClient.createGroupChatWithCustomRoomType(
          name: name,
          topic: topic,
        ),
        roomId,
      );

      verify(
        mockMatrixClient.createRoom(
          isDirect: false,
          preset: CreateRoomPreset.privateChat,
          name: name,
          topic: topic,
          creationContent: {'type': TimRoomType.defaultValue.value},
          initialState: argThat(
            pairwiseCompare<StateEvent, StateEvent>(
              expectedInitialStates,
              compareStateEvents,
              'initialState',
            ),
            named: 'initialState',
          ),
          invite: anyNamed('invite'),
          invite3pid: anyNamed('invite3pid'),
          powerLevelContentOverride: anyNamed('powerLevelContentOverride'),
          roomAliasName: anyNamed('roomAliasName'),
          roomVersion: anyNamed('roomVersion'),
          visibility: anyNamed('visibility'),
        ),
      ).called(1);
    });

    test('can create room without name or topic', () async {
      expect(
        await timMatrixClient.createGroupChatWithCustomRoomType(),
        roomId,
      );

      final verificationResult = verify(
        mockMatrixClient.createRoom(
          isDirect: false,
          preset: CreateRoomPreset.privateChat,
          name: null,
          topic: null,
          creationContent: {'type': TimRoomType.defaultValue.value},
          initialState: captureAnyNamed('initialState'),
          invite: anyNamed('invite'),
          invite3pid: anyNamed('invite3pid'),
          powerLevelContentOverride: anyNamed('powerLevelContentOverride'),
          roomAliasName: anyNamed('roomAliasName'),
          roomVersion: anyNamed('roomVersion'),
          visibility: anyNamed('visibility'),
        ),
      );
      verificationResult.called(1);
      expect(
        verificationResult.captured.single,
        isNot(
          contains(
            anyOf(
              isA<StateEvent>().having((e) => e.type, 'type', TimRoomStateEventType.roomName.value),
              isA<StateEvent>()
                  .having((e) => e.type, 'type', TimRoomStateEventType.roomTopic.value),
            ),
          ),
        ),
      );
    });

    test(
        'with casereference should create room with TIM casereference room type and casereference room events',
        () async {
      const name = 'roomName';
      const topic = 'roomTopic';

      final expectedInitialStates = [
        StateEvent(
          content: timCaseReferenceContentBlob,
          type: TimRoomStateEventType.caseReference.value,
        ),
        StateEvent(
          content: {
            'algorithm': Client.supportedGroupEncryptionAlgorithms.first,
          },
          type: EventTypes.Encryption,
        ),
        StateEvent(
          content: {
            'name': name,
          },
          type: TimRoomStateEventType.roomName.value,
        ),
        StateEvent(
          content: {
            'topic': topic,
          },
          type: TimRoomStateEventType.roomTopic.value,
        ),
        StateEvent(
          content: {
            'history_visibility': defaultHistoryVisibility,
          },
          type: EventTypes.HistoryVisibility,
        ),
      ];

      expect(
        await timMatrixClient.createGroupChatWithCustomRoomType(
          name: name,
          topic: topic,
          isCaseReference: true,
        ),
        roomId,
      );

      verify(
        mockMatrixClient.createRoom(
          isDirect: false,
          preset: CreateRoomPreset.privateChat,
          name: name,
          topic: topic,
          creationContent: {'type': TimRoomType.caseReference.value},
          initialState: argThat(
            pairwiseCompare<StateEvent, StateEvent>(
              expectedInitialStates,
              compareStateEvents,
              'initialState',
            ),
            named: 'initialState',
          ),
          invite: anyNamed('invite'),
          invite3pid: anyNamed('invite3pid'),
          powerLevelContentOverride: anyNamed('powerLevelContentOverride'),
          roomAliasName: anyNamed('roomAliasName'),
          roomVersion: anyNamed('roomVersion'),
          visibility: anyNamed('visibility'),
        ),
      ).called(1);
    });
  });
}

bool compareStateEvents(StateEvent expected, StateEvent actual) =>
    expected.type == actual.type && expected.content.toString() == actual.content.toString();
