/*
 * TIM-Referenzumgebung
 * Copyright (C) 2026 – akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/pages/chat_encryption_settings/chat_encryption_settings.dart';
import 'package:fluffychat/pages/chat_encryption_settings/chat_encryption_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix/src/utils/cached_stream_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils/prepare_widget_test_with_localization.dart';
import 'chat_encryption_settings_view_test.mocks.dart';

/// MockRoom does not generate an override for the [Room.joinRules] getter
/// (nullable computed property), so [when] stubs do not take effect.
/// This subclass provides an explicit override.
class _TestRoom extends MockRoom {
  JoinRules? stubbedJoinRules;

  @override
  JoinRules? get joinRules => stubbedJoinRules;
}

@GenerateNiceMocks([
  MockSpec<ChatEncryptionSettingsController>(),
  MockSpec<Room>(),
  MockSpec<Client>(),
])
void main() {
  group('ChatEncryptionSettingsView encryption toggle', () {
    late MockChatEncryptionSettingsController mockController;
    late _TestRoom mockRoom;
    late MockClient mockClient;
    late CachedStreamController<SyncUpdate> cachedSyncController;
    late CachedStreamController<String> roomUpdateController;

    setUp(() {
      mockController = MockChatEncryptionSettingsController();
      mockRoom = _TestRoom();
      mockClient = MockClient();
      cachedSyncController = CachedStreamController<SyncUpdate>();
      roomUpdateController = CachedStreamController<String>();

      when(mockController.room).thenReturn(mockRoom);
      when(mockController.roomId).thenReturn('!testroom:example.com');
      when(mockRoom.id).thenReturn('!testroom:example.com');
      when(mockRoom.client).thenReturn(mockClient);
      when(mockClient.onSync).thenReturn(cachedSyncController);
      when(mockRoom.isDirectChat).thenReturn(false);
      when(mockRoom.onUpdate).thenReturn(roomUpdateController);
    });

    tearDown(() {
      cachedSyncController.close();
      roomUpdateController.close();
    });

    Future<void> pumpView(WidgetTester tester) async {
      await prepareAppTestWithLocalization(
        child: ChatEncryptionSettingsView(mockController),
        tester: tester,
        path: '/rooms/:roomid/encryption',
        initialUrl: '/rooms/!testroom:example.com/encryption',
      );
    }

    testWidgets(
      'toggle is enabled for public encrypted room without subtitle',
      (WidgetTester tester) async {
        mockRoom.stubbedJoinRules = JoinRules.public;
        when(mockRoom.encrypted).thenReturn(true);
        when(mockRoom.getUserDeviceKeys()).thenAnswer((_) async => <DeviceKeys>[]);

        await pumpView(tester);

        final switchFinder = find.byWidgetPredicate(
          (widget) => widget is SwitchListTile && widget.secondary is CircleAvatar,
        );
        expect(switchFinder, findsOneWidget);

        final switchTile = tester.widget<SwitchListTile>(switchFinder);
        expect(switchTile.value, isTrue);
        expect(switchTile.onChanged, isNotNull);
        expect(switchTile.subtitle, isNull);
      },
    );

    testWidgets(
      'toggle is enabled for private room without subtitle',
      (WidgetTester tester) async {
        mockRoom.stubbedJoinRules = JoinRules.invite;
        when(mockRoom.encrypted).thenReturn(false);

        await pumpView(tester);

        final switchFinder = find.byWidgetPredicate(
          (widget) => widget is SwitchListTile && widget.secondary is CircleAvatar,
        );
        expect(switchFinder, findsOneWidget);

        final switchTile = tester.widget<SwitchListTile>(switchFinder);
        expect(switchTile.value, isFalse);
        expect(switchTile.onChanged, isNotNull);
        expect(switchTile.subtitle, isNull);
      },
    );
  });
}
