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
import 'package:fluffychat/pages/chat/chat_input_row.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../utils/prepare_app_test_with_matrix_client.dart';
import '../../utils/test_client.dart';
import 'chat_input_row_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ChatController>(),
  MockSpec<Matrix>(),
  MockSpec<Room>(),
])
void main() {
  group('A_28355 Replace with Empty String', () {
    late MockChatController mockController;
    late MockRoom mockRoom;
    late Client testClient;

    setUp(() async {
      VisibilityDetectorController.instance.updateInterval = Duration.zero;

      mockController = MockChatController();
      mockRoom = MockRoom();
      testClient = await prepareTestClient();

      when(mockController.room).thenReturn(
        mockRoom,
      );

      when(mockController.selectMode).thenReturn(false);
      when(mockController.inputFocus).thenReturn(FocusNode());
      when(mockController.sendController).thenReturn(TextEditingController());
    });

    testWidgets('on Mobile shows sendMessage Icon, when editing a message with empty text field',
        (WidgetTester tester) async {
      // send button is always displayed non-mobile platforms
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      when(mockController.inputText).thenReturn('');
      when(mockController.isEditEvent).thenReturn(true);
      await prepareAppTestWithMatrixClient(
        child: ChatInputRow(mockController),
        tester: tester,
        client: testClient,
      );

      expect(find.byIcon(Icons.send_outlined), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'on Mobile does not show sendMessage Icon, when writing a message with empty text field',
        (WidgetTester tester) async {
      // send button is always displayed non-mobile platforms
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      when(mockController.inputText).thenReturn('');
      when(mockController.isEditEvent).thenReturn(false);
      await prepareAppTestWithMatrixClient(
        child: ChatInputRow(mockController),
        tester: tester,
        client: testClient,
      );

      expect(find.byIcon(Icons.send_outlined), findsNothing);

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
