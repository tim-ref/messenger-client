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

  final matrixClient = MockClient();
  final timMatrixClient = TimMatrixClientImpl(client: matrixClient);

  setUp(() {
    reset(matrixClient);
    when(
      matrixClient.createRoom(
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
    when(matrixClient.getDirectChatFromUserId(any)).thenReturn(null);
    when(matrixClient.encryptionEnabled).thenReturn(true);
    when(matrixClient.userOwnsEncryptionKeys(any)).thenAnswer((_) async => true);
    when(matrixClient.getRoomById(roomId)).thenAnswer((realInvocation) => null);
    when(matrixClient.waitForRoomInSync(roomId, join: true, invite: false, leave: false))
        .thenAnswer((realInvocation) async => SyncUpdate(nextBatch: ''));
    when(matrixClient.directChats).thenReturn({
      userId: [roomId],
    });
  });

  test('startDirectChat should create room with TIM default room type and default room events',
      () async {
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
      matrixClient.createRoom(
        isDirect: true,
        preset: CreateRoomPreset.trustedPrivateChat,
        name: '',
        topic: '',
        creationContent: {'type': TimRoomType.defaultValue.value},
        initialState: argThat(
          pairwiseCompare<StateEvent, StateEvent>(
            expectedInitialStates,
            compareStateEvents,
            'compare state events',
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

  test(
      'startDirectChat with casereference should create room with TIM casereference room type and casereference room events',
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
      matrixClient.createRoom(
        isDirect: true,
        preset: CreateRoomPreset.trustedPrivateChat,
        name: '',
        topic: '',
        creationContent: {'type': TimRoomType.caseReference.value},
        initialState: argThat(
          pairwiseCompare<StateEvent, StateEvent>(
            expectedInitialStates,
            compareStateEvents,
            'compare state events',
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

  test('create group chat should create room with TIM default room type and default room events',
      () async {
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
    ];

    expect(
      await timMatrixClient.createGroupChatWithCustomRoomType(
        name: name,
        topic: topic,
      ),
      roomId,
    );

    verify(
      matrixClient.createRoom(
        isDirect: false,
        preset: CreateRoomPreset.privateChat,
        name: '',
        topic: '',
        creationContent: {'type': TimRoomType.defaultValue.value},
        initialState: argThat(
          pairwiseCompare<StateEvent, StateEvent>(
            expectedInitialStates,
            compareStateEvents,
            'compare state events',
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

  test(
      'create group chat with casereference should create room with TIM casereference room type and casereference room events',
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
      matrixClient.createRoom(
        isDirect: false,
        preset: CreateRoomPreset.privateChat,
        name: '',
        topic: '',
        creationContent: {'type': TimRoomType.caseReference.value},
        initialState: argThat(
          pairwiseCompare<StateEvent, StateEvent>(
            expectedInitialStates,
            compareStateEvents,
            'compare state events',
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
}

bool compareStateEvents(StateEvent expected, StateEvent actual) =>
    expected.type == actual.type && expected.content.toString() == actual.content.toString();
