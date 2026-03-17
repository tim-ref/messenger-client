/*
 * TIM-Referenzumgebung
 * Copyright (C) 2025-2026 - akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pages/chat/chat_view.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:matrix/src/utils/cached_stream_controller.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../tim/feature/automated_invite_rejection/settings_invite_rejection_controller_test.mocks.dart';
import '../../utils/test_client.dart';
import '../../utils/prepare_app_test_with_matrix_client.dart';
import 'chat_view_test.mocks.dart';
import 'events/html_message_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ChatController>(),
  MockSpec<Matrix>(),
])
void main() {
  const testUser = 'exampleSender';

  final testEvent = Event(
    content: {},
    type: 'message',
    eventId: '1',
    senderId: testUser,
    originServerTs: DateTime.now(),
    room: Room(
      id: 'exampleRoomId',
      client: MockClient(),
    ),
  );
  final testEvent2 = Event(
    content: {},
    type: 'message',
    eventId: '2',
    senderId: testUser,
    originServerTs: DateTime.now(),
    room: Room(
      id: 'exampleRoomId',
      client: MockClient(),
    ),
  );
  group('ChatView edit icon visibility', () {
    late MockChatController mockController;
    late MockClient mockClient;
    late MockRoom mockRoom;
    late Client testClient;

    setUp(() async {
      mockController = MockChatController();
      mockRoom = MockRoom();
      mockClient = MockClient();
      testClient = await prepareTestClient();

      when(mockClient.userID).thenReturn(
        testUser,
      );
      when(mockController.selectedEvents).thenReturn([testEvent]);
      when(mockController.matrixClient).thenReturn(
        mockClient,
      );
      when(mockController.room).thenReturn(
        mockRoom,
      );

      when(mockRoom.onUpdate).thenAnswer((_) => CachedStreamController());
    });

    testWidgets('shows edit icon when selecting a single own message', (WidgetTester tester) async {
      when(mockController.selectMode).thenReturn(true);

      await prepareAppTestWithMatrixClient(
          child: ChatView(mockController), tester: tester, client: testClient);

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets(
        'should not show edit icon when selecting a single message, which was not sent by self',
        (WidgetTester tester) async {
      when(mockClient.userID).thenReturn(
        'a_different_user',
      );
      when(mockController.selectMode).thenReturn(true);

      await prepareAppTestWithMatrixClient(
          child: ChatView(mockController), tester: tester, client: testClient);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.edit), findsNothing);
    });
    testWidgets('should not show edit icon when selecting multiple messages',
        (WidgetTester tester) async {
      when(mockController.selectedEvents).thenReturn([testEvent, testEvent2]);

      when(mockController.selectMode).thenReturn(true);

      await prepareAppTestWithMatrixClient(
          child: ChatView(mockController), tester: tester, client: testClient);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.edit), findsNothing);
    });
  });

  group('ChatView redact icon visibility', () {
    late MockChatController mockController;
    late MockClient mockClient;
    late MockRoom mockRoom;
    late Client testClient;

    setUp(() async {
      mockController = MockChatController();
      mockRoom = MockRoom();
      mockClient = MockClient();
      testClient = await prepareTestClient();

      when(mockClient.userID).thenReturn(
        testUser,
      );
      when(mockController.selectedEvents).thenReturn([testEvent]);
      when(mockController.matrixClient).thenReturn(
        mockClient,
      );
      when(mockController.room).thenReturn(
        mockRoom,
      );

      when(mockRoom.onUpdate).thenAnswer((_) => CachedStreamController());
    });

    testWidgets('should show redact icon during 24h after timestamp', (WidgetTester tester) async {
      when(mockController.selectMode).thenReturn(true);
      when(mockController.canRedactSelectedEvents).thenReturn(true);

      await prepareAppTestWithMatrixClient(
          child: ChatView(mockController), tester: tester, client: testClient);

      expect(find.byIcon(Icons.delete_outlined), findsOneWidget);
    });

    testWidgets('should not show redact icon after more than 24h after timestamp',
        (WidgetTester tester) async {
      when(mockController.selectedEvents).thenReturn([testEvent, testEvent2]);

      when(mockController.selectMode).thenReturn(true);
      when(mockController.canRedactSelectedEvents).thenReturn(false);

      await prepareAppTestWithMatrixClient(
          child: ChatView(mockController), tester: tester, client: testClient);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.delete_outlined), findsNothing);
    });
  });

  group('A_25562-01 Display public room icon', () {
    late MockChatController mockController;
    late MockClient mockClient;
    late MockRoom mockRoom;
    late Client testClient;

    setUp(() async {
      // Disable visibility detector timer to prevent pending timer issues in tests
      VisibilityDetectorController.instance.updateInterval = Duration.zero;

      mockController = MockChatController();
      mockRoom = MockRoom();
      mockClient = MockClient();
      testClient = await prepareTestClient();

      when(mockClient.userID).thenReturn(
        testUser,
      );
      when(mockController.selectedEvents).thenReturn([testEvent]);
      when(mockController.matrixClient).thenReturn(
        mockClient,
      );
      when(mockController.room).thenReturn(
        mockRoom,
      );

      when(mockRoom.onUpdate).thenAnswer((_) => CachedStreamController());
    });

    testWidgets('shows publicity icon if room encryption is false', (WidgetTester tester) async {
      when(mockRoom.encrypted).thenReturn(false);
      when(mockRoom.historyVisibility).thenReturn(HistoryVisibility.invited);
      when(mockRoom.joinRules).thenReturn(JoinRules.private);

      await prepareAppTestWithMatrixClient(
        child: ChatView(mockController),
        tester: tester,
        client: testClient,
      );

      expect(find.byIcon(Icons.public), findsOneWidget);
    });

    testWidgets('shows publicity icon if historyVisibility is worldReadable',
        (WidgetTester tester) async {
      when(mockRoom.encrypted).thenReturn(true);
      when(mockRoom.historyVisibility).thenReturn(HistoryVisibility.worldReadable);
      when(mockRoom.joinRules).thenReturn(JoinRules.private);

      await prepareAppTestWithMatrixClient(
        child: ChatView(mockController),
        tester: tester,
        client: testClient,
      );

      expect(find.byIcon(Icons.public), findsOneWidget);
    });

    testWidgets('shows publicity icon if joinRules are public', (WidgetTester tester) async {
      when(mockRoom.encrypted).thenReturn(true);
      when(mockRoom.historyVisibility).thenReturn(HistoryVisibility.invited);
      when(mockRoom.joinRules).thenReturn(JoinRules.public);

      await prepareAppTestWithMatrixClient(
        child: ChatView(mockController),
        tester: tester,
        client: testClient,
      );

      expect(find.byIcon(Icons.public), findsOneWidget);
    });

    testWidgets('does not show publicity icon if none of the above conditions are met',
        (WidgetTester tester) async {
      when(mockRoom.encrypted).thenReturn(true);
      when(mockRoom.historyVisibility).thenReturn(HistoryVisibility.invited);
      when(mockRoom.joinRules).thenReturn(JoinRules.private);

      await prepareAppTestWithMatrixClient(
        child: ChatView(mockController),
        tester: tester,
        client: testClient,
      );

      expect(find.byIcon(Icons.public), findsNothing);
    });
  });
}
