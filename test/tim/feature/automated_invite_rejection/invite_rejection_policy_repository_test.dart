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

import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_policy.dart';
import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_policy_repository.dart';
import 'package:fluffychat/tim/shared/matrix/tim_matrix_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'invite_rejection_policy_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<TimMatrixClient>()])
void main() {
  final Map<String, dynamic> exampleResponse = {
    'defaultSetting': 'block all',
    'domainExceptions': {},
    'userExceptions': {}
  };

  late MockTimMatrixClient mockTimMatrixClient;
  setUp(() {
    mockTimMatrixClient = MockTimMatrixClient();
  });
  group("Invite Rejection Policy Repository - ", () {
    test("should load data from server, if no account data is cached", () async {
      final repo = InviteRejectionPolicyRepositoryImpl(mockTimMatrixClient);
      when(mockTimMatrixClient.getAccountData(any, any)).thenAnswer((_) async => exampleResponse);

      final res = await repo.getCurrentPolicy();

      verify(mockTimMatrixClient.getAccountData(any, permissionConfigNameSpace));

      expect(
        res,
        isA<BlockAllInvites>().having(
          (e) => e.allowedUsers,
          'parsed blocked user list correctly',
          <String>{},
        ).having(
          (e) => e.allowedDomains,
          'parsed blocked domain list correctly',
          <String>{},
        ),
      );
    });
  });
}
