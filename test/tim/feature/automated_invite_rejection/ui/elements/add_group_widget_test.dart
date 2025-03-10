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

import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_policy.dart';
import 'package:fluffychat/tim/feature/automated_invite_rejection/ui/elements/add_group_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../utils/prepare_widget_test_with_localization.dart';

void main() {
  group('AddGroupsDropdown should - ', () {
    testWidgets('returns correct value on tap', (WidgetTester tester) async {
      String? selectedValue;
      await prepareAppTestWithLocalization(
        tester: tester,
        child: Scaffold(
          body: AddGroupsDropdown(
            onGroupSelected: (value) {
              selectedValue = value;
            },
          ),
        ),
      );

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("GroupItemInsuredPerson")));
      await tester.pumpAndSettle();

      expect(selectedValue, equals(UserGroup.isInsuredPerson.name));
    });
  });
}
