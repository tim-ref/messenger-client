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

import 'package:fluffychat/pages/new_group/new_group.dart';
import 'package:fluffychat/tim/shared/matrix/tim_matrix.dart';
import 'package:fluffychat/tim/shared/matrix/tim_matrix_client.dart';
import 'package:fluffychat/tim/shared/tim_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as sdk;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:vrouter/vrouter.dart';

import 'new_group_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<TimServices>(),
  MockSpec<TimMatrix>(),
  MockSpec<TimMatrixClient>(),
])
void main() {
  // A_25324-02: unverschlüsselte Räume nur anlegen wenn joinRule=public UND
  // historyVisibility=world_readable|shared. Das public-Preset setzt beides.
  group('NewGroupController.submitAction – A_25324-02', () {
    late MockTimServices mockTimServices;
    late MockTimMatrix mockTimMatrix;
    late MockTimMatrixClient mockTimMatrixClient;

    const roomId = '!newroom:example.com';

    setUp(() {
      mockTimServices = MockTimServices();
      mockTimMatrix = MockTimMatrix();
      mockTimMatrixClient = MockTimMatrixClient();

      when(mockTimServices.matrix()).thenReturn(mockTimMatrix);
      when(mockTimMatrix.client()).thenReturn(mockTimMatrixClient);
      when(
        mockTimMatrixClient.createGroupChatWithCustomRoomType(
          visibility: anyNamed('visibility'),
          preset: anyNamed('preset'),
          name: anyNamed('name'),
          isCaseReference: anyNamed('isCaseReference'),
          enableEncryption: anyNamed('enableEncryption'),
        ),
      ).thenAnswer((_) async => roomId);
    });

    Future<void> pumpWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          localizationsDelegates: L10n.localizationsDelegates,
          key: GlobalKey<VRouterState>(),
          supportedLocales: L10n.supportedLocales,
          routes: [
            VWidget(
              path: '/',
              widget: Provider<TimServices>(
                create: (_) => mockTimServices,
                child: const NewGroup(),
              ),
            ),
            VWidget(path: '/rooms/:roomid/invite', widget: const SizedBox()),
          ],
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }

    Finder createButton() => find.bySemanticsLabel('createGroupButton');

    Finder publicSwitch() => find.bySemanticsLabel('groupPrivateToggle');

    Finder encryptionSwitch() => find.byWidgetPredicate(
          (widget) =>
              widget is SwitchListTile &&
              widget.secondary is Icon &&
              (widget.secondary as Icon).icon == Icons.lock_outlined,
        );

    Future<bool?> captureEnableEncryption(WidgetTester tester) async {
      await tester.tap(createButton());
      await tester.pumpAndSettle();

      final result = verify(
        mockTimMatrixClient.createGroupChatWithCustomRoomType(
          visibility: anyNamed('visibility'),
          preset: anyNamed('preset'),
          name: anyNamed('name'),
          isCaseReference: anyNamed('isCaseReference'),
          enableEncryption: captureAnyNamed('enableEncryption'),
        ),
      );
      result.called(1);
      return result.captured.single as bool?;
    }

    testWidgets(
      'public group with encryption enabled passes enableEncryption=true',
      (WidgetTester tester) async {
        await pumpWidget(tester);

        await tester.tap(publicSwitch());
        await tester.pumpAndSettle();

        // Encryption toggle defaults to true when public is enabled — do not change it
        final enableEncryption = await captureEnableEncryption(tester);
        expect(enableEncryption, isTrue);
      },
    );

    testWidgets(
      're-enabling public after disabling resets enableEncryption to true',
      (WidgetTester tester) async {
        await pumpWidget(tester);

        // Enable public, disable encryption, disable public, re-enable public
        await tester.tap(publicSwitch());
        await tester.pumpAndSettle();
        await tester.tap(encryptionSwitch());
        await tester.pumpAndSettle();
        await tester.tap(publicSwitch());
        await tester.pumpAndSettle();
        await tester.tap(publicSwitch());
        await tester.pumpAndSettle();

        // setPublicGroup(true) must reset enableEncryption to true
        final enableEncryption = await captureEnableEncryption(tester);
        expect(enableEncryption, isTrue);
      },
    );

    testWidgets(
      'passes correct visibility and preset for public group',
      (WidgetTester tester) async {
        await pumpWidget(tester);

        await tester.tap(publicSwitch());
        await tester.pumpAndSettle();
        await tester.tap(encryptionSwitch());
        await tester.pumpAndSettle();
        await tester.tap(createButton());
        await tester.pumpAndSettle();

        verify(
          mockTimMatrixClient.createGroupChatWithCustomRoomType(
            visibility: sdk.Visibility.public,
            preset: sdk.CreateRoomPreset.publicChat,
            name: anyNamed('name'),
            isCaseReference: anyNamed('isCaseReference'),
            enableEncryption: false,
          ),
        ).called(1);
      },
    );

    testWidgets(
      'passes correct visibility and preset for private group',
      (WidgetTester tester) async {
        await pumpWidget(tester);

        await tester.tap(createButton());
        await tester.pumpAndSettle();

        verify(
          mockTimMatrixClient.createGroupChatWithCustomRoomType(
            visibility: sdk.Visibility.private,
            preset: sdk.CreateRoomPreset.privateChat,
            name: anyNamed('name'),
            isCaseReference: anyNamed('isCaseReference'),
            enableEncryption: true,
          ),
        ).called(1);
      },
    );
  });
}
