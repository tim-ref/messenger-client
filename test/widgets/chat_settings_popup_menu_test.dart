/*
 * TIM-Referenzumgebung
 * Copyright (C) 2025 – akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/widgets/chat_settings_popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:vrouter/vrouter.dart';

import '../utils/prepare_app_test_with_matrix_client.dart';
import '../utils/test_client.dart';
import 'chat_settings_popup_menu_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<Room>(),
])
void main() {
  group('ChatSettingsPopupMenu leave_and_forget', () {
    late MockRoom mockRoom;
    late Client testClient;

    setUp(() async {
      VisibilityDetectorController.instance.updateInterval = Duration.zero;

      mockRoom = MockRoom();
      testClient = await prepareTestClient();

      when(mockRoom.id).thenReturn('!testroom:example.com');
      when(mockRoom.pushRuleState).thenReturn(PushRuleState.notify);
      when(mockRoom.client).thenReturn(testClient);
    });

    testWidgets('displays leave_and_forget menu option',
        (WidgetTester tester) async {
      await prepareAppTestWithMatrixClient(
        child: Scaffold(
          body: ChatSettingsPopupMenu(mockRoom, false),
        ),
        tester: tester,
        client: testClient,
      );

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Verify menu option is displayed
      expect(find.text('Leave and forget'), findsOneWidget);
    });

    testWidgets('calls leave() and forget() when confirmed',
        (WidgetTester tester) async {
      when(mockRoom.leave()).thenAnswer((_) async => {});
      when(mockRoom.forget()).thenAnswer((_) async => {});

      await prepareAppTestWithMatrixClient(
        child: Scaffold(
          body: ChatSettingsPopupMenu(mockRoom, false),
        ),
        tester: tester,
        client: testClient,
        additionalRoutes: [
          VWidget(
            path: '/rooms',
            widget: const Scaffold(body: Text('Rooms')),
          ),
        ],
      );

      // Open menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leave and forget'));
      await tester.pumpAndSettle();

      // Confirm
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify both methods called
      verify(mockRoom.leave()).called(1);
      verify(mockRoom.forget()).called(1);
    });

    testWidgets('does not call methods when cancelled',
        (WidgetTester tester) async {
      when(mockRoom.leave()).thenAnswer((_) async => {});
      when(mockRoom.forget()).thenAnswer((_) async => {});

      await prepareAppTestWithMatrixClient(
        child: Scaffold(
          body: ChatSettingsPopupMenu(mockRoom, false),
        ),
        tester: tester,
        client: testClient,
        additionalRoutes: [
          VWidget(
            path: '/rooms',
            widget: const Scaffold(body: Text('Rooms')),
          ),
        ],
      );

      // Open menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leave and forget'));
      await tester.pumpAndSettle();

      // Cancel - tap outside dialog to dismiss it (barrier dismissible)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Verify methods not called
      verifyNever(mockRoom.leave());
      verifyNever(mockRoom.forget());
    });

    testWidgets(
      'does not call forget() if leave() fails',
      (WidgetTester tester) async {
        when(mockRoom.leave()).thenThrow(Exception('Leave failed'));
        when(mockRoom.forget()).thenAnswer((_) async => {});

        await prepareAppTestWithMatrixClient(
          child: Scaffold(
            body: ChatSettingsPopupMenu(mockRoom, false),
          ),
          tester: tester,
          client: testClient,
        );

        // Open menu
        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Leave and forget'));
        await tester.pumpAndSettle();

        // Confirm
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Verify leave called but not forget
        verify(mockRoom.leave()).called(1);
        verifyNever(mockRoom.forget());
      },
    ); // Dialog interaction has timing issues with test environment
  });
}
