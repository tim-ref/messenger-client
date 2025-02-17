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

import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pages/chat/chat_view.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:matrix/src/utils/cached_stream_controller.dart';

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
    originServerTs: DateTime(2025, 1, 1),
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
    originServerTs: DateTime(2025, 1, 1),
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
}
