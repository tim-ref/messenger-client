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
import 'package:fluffychat/utils/get_label_for_user_group.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:test/test.dart';

void main() {
  group('getDisplayValueForUserGroup', () {
    late FakeL10n fakeL10n;

    setUp(() {
      fakeL10n = FakeL10n();
    });

    test('returns localized value when value equals UserGroup.isInsuredPerson.name', () {
      final result = getLabelForUserGroup(fakeL10n, UserGroup.isInsuredPerson.name);
      expect(result, equals('Group: Insured Person'));
    });

    test('throws UnsupportedError when value is invalid and throwOnNonExisting is true', () {
      expect(
        () => getLabelForUserGroup(fakeL10n, 'invalid_group'),
        throwsUnsupportedError,
      );
    });

    test('returns input value when value is invalid and throwOnNonExisting is false', () {
      const invalidValue = 'invalid_group';
      final result = getLabelForUserGroup(fakeL10n, invalidValue, throwOnNonExisting: false);
      expect(result, equals(invalidValue));
    });
  });
}

class FakeL10n extends L10n {
  FakeL10n() : super('');

  @override
  String get userGroupInsuredPerson => 'Group: Insured Person';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
