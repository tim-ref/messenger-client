/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - 2025 – akquinet GmbH
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
import 'package:matrix/matrix_api_lite/model/basic_event.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<TimMatrixClient>()])
import 'invite_rejection_policy_repository_test.mocks.dart';
import '../../../utils/sync_cached_stream_controller.dart';

void main() {
  final Map<String, dynamic> exampleBlockAllPolicy = {
    'defaultSetting': 'block all',
    'serverExceptions': {'server #1': {}},
  };

  late MockTimMatrixClient mockClient;
  late InviteRejectionPolicyRepositoryImpl repo;

  setUp(() {
    mockClient = MockTimMatrixClient();
    repo = InviteRejectionPolicyRepositoryImpl(mockClient);

    when(mockClient.userID).thenReturn("Maike");
  });

  group("Invite Rejection Policy Repository - ", () {
    test("should load data from server, if no account data is cached", () async {
      when(mockClient.getAccountData("Maike", "de.gematik.tim.account.permissionconfig.pro.v1"))
          .thenAnswer((_) async => exampleBlockAllPolicy);

      final policy = await repo.getCurrentPolicy();

      expect(
        policy,
        isA<BlockAllInvites>().having((e) => e.allowedServers, 'allowedServers', {'server #1'}),
      );
    });

    test("can set a policy", () async {
      await repo.setNewPolicy(AllowAllInvites.blockingNone());

      verify(
        mockClient.setAccountData("Maike", "de.gematik.tim.account.permissionconfig.pro.v1", any),
      );
    });

    test("should cache policies pushed from server to client", () async {
      final eventStream = SyncCachedStreamController<BasicEvent>();
      when(mockClient.onAccountDataChange()).thenReturn(eventStream);

      repo.listenToNewRejectionPolicy();
      eventStream.add(
        BasicEvent(
          type: "de.gematik.tim.account.permissionconfig.pro.v1",
          content: exampleBlockAllPolicy,
        ),
      );

      final policy = await repo.getCurrentPolicy();

      verifyNever(mockClient.getAccountData(any, any));

      expect(
        policy,
        isA<BlockAllInvites>().having((e) => e.allowedServers, 'allowedServers', {'server #1'}),
      );
    });
  });
}
