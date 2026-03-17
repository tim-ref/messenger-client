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
import 'package:fluffychat/pages/new_group/new_group_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils/prepare_widget_test_with_localization.dart';
import 'new_group_view_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<NewGroupController>(),
])
void main() {
  group('NewGroupView encryption toggle', () {
    late MockNewGroupController mockController;

    setUp(() {
      mockController = MockNewGroupController();
      when(mockController.controller).thenReturn(TextEditingController());
      when(mockController.isCaseReference).thenReturn(false);
    });

    testWidgets(
      'encryption toggle is disabled and locked on when publicGroup is false',
      (WidgetTester tester) async {
        when(mockController.publicGroup).thenReturn(false);
        when(mockController.enableEncryption).thenReturn(true);

        await prepareAppTestWithLocalization(
          child: NewGroupView(mockController),
          tester: tester,
        );

        final switchFinder = find.byWidgetPredicate(
          (widget) =>
              widget is SwitchListTile &&
              widget.secondary is Icon &&
              (widget.secondary as Icon).icon == Icons.lock_outlined,
        );
        expect(switchFinder, findsOneWidget);

        final switchTile = tester.widget<SwitchListTile>(switchFinder);
        expect(switchTile.value, isTrue);
        expect(switchTile.onChanged, isNull);
      },
    );

    testWidgets(
      'encryption toggle is interactive when publicGroup is true',
      (WidgetTester tester) async {
        when(mockController.publicGroup).thenReturn(true);
        when(mockController.enableEncryption).thenReturn(true);

        await prepareAppTestWithLocalization(
          child: NewGroupView(mockController),
          tester: tester,
        );

        final switchFinder = find.byWidgetPredicate(
          (widget) =>
              widget is SwitchListTile &&
              widget.secondary is Icon &&
              (widget.secondary as Icon).icon == Icons.lock_outlined,
        );
        expect(switchFinder, findsOneWidget);

        final switchTile = tester.widget<SwitchListTile>(switchFinder);
        expect(switchTile.value, isTrue);
        expect(switchTile.onChanged, isNotNull);
      },
    );

    testWidgets(
      'encryption toggle reflects enableEncryption=false when group is public',
      (WidgetTester tester) async {
        when(mockController.publicGroup).thenReturn(true);
        when(mockController.enableEncryption).thenReturn(false);

        await prepareAppTestWithLocalization(
          child: NewGroupView(mockController),
          tester: tester,
        );

        final switchFinder = find.byWidgetPredicate(
          (widget) =>
              widget is SwitchListTile &&
              widget.secondary is Icon &&
              (widget.secondary as Icon).icon == Icons.lock_outlined,
        );
        expect(switchFinder, findsOneWidget);

        final switchTile = tester.widget<SwitchListTile>(switchFinder);
        expect(switchTile.value, isFalse);
        expect(switchTile.onChanged, isNotNull);
      },
    );
  });

  group('NewGroup encryption toggle state transitions', () {
    Finder encryptionSwitch() => find.byWidgetPredicate(
          (widget) =>
              widget is SwitchListTile &&
              widget.secondary is Icon &&
              (widget.secondary as Icon).icon == Icons.lock_outlined,
        );

    Finder publicSwitch() => find.bySemanticsLabel('groupPrivateToggle');

    testWidgets(
      'toggling public off and back on resets encryption to true',
      (WidgetTester tester) async {
        await prepareAppTestWithLocalization(
          child: const NewGroup(),
          tester: tester,
        );

        // Step 1: enable public group
        await tester.tap(publicSwitch());
        await tester.pumpAndSettle();
        expect(
          tester.widget<SwitchListTile>(encryptionSwitch()).value,
          isTrue,
        );

        // Step 2: disable encryption
        await tester.tap(encryptionSwitch());
        await tester.pumpAndSettle();
        expect(
          tester.widget<SwitchListTile>(encryptionSwitch()).value,
          isFalse,
        );

        // Step 3: disable public group -> encryption forced to true
        await tester.tap(publicSwitch());
        await tester.pumpAndSettle();
        expect(
          tester.widget<SwitchListTile>(encryptionSwitch()).value,
          isTrue,
        );

        // Step 4: re-enable public group -> encryption should be true
        await tester.tap(publicSwitch());
        await tester.pumpAndSettle();
        expect(
          tester.widget<SwitchListTile>(encryptionSwitch()).value,
          isTrue,
        );
      },
    );
  });
}
