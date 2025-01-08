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
import 'package:fluffychat/tim/feature/automated_invite_rejection/ui/settings_invite_rejection_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'settings_invite_rejection_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Client>(), MockSpec<InviteRejectionPolicyRepository>()])
void main() {
  late InviteRejectionPolicyRepository inviteRejectionPolicyRepository;
  late SettingsInviteRejectionController controller;

  const user = "user";
  const domain = "domain";
  const mxid = "@$user:$domain";

  // Issue of Mockito when using mocks which depend on sealed classes
  // https://github.com/dart-lang/mockito/issues/675
  provideDummy<InviteRejectionPolicy>(AllowAllInvites(blockedDomains: {}, blockedUsers: {}));

  test("after creation of controller instance -> loads invite rejection policy", () async {
    final policy = AllowAllInvites(blockedDomains: {}, blockedUsers: {});
    inviteRejectionPolicyRepository = MockInviteRejectionPolicyRepository();
    when(inviteRejectionPolicyRepository.getCurrentPolicy())
        .thenAnswer((_) => Future.value(policy));

    controller = SettingsInviteRejectionController(
      inviteRejectionPolicyRepository: inviteRejectionPolicyRepository,
    );

    await untilCalled(inviteRejectionPolicyRepository.getCurrentPolicy());
    expect(controller.inviteRejectionPolicy, policy);
  });

  group("AllowAll", () {
    final policy = AllowAllInvites(blockedDomains: {}, blockedUsers: {});

    // always reinitialize controller for each test
    setUp(() {
      inviteRejectionPolicyRepository = MockInviteRejectionPolicyRepository();
      when(inviteRejectionPolicyRepository.getCurrentPolicy())
          .thenAnswer((_) => Future.value(policy));
      controller = SettingsInviteRejectionController(
        inviteRejectionPolicyRepository: inviteRejectionPolicyRepository,
      );
    });

    test("add homeserver to exceptions -> adds entry to blocked domains", () async {
      await controller.addExceptionEntry(domain);

      final blockedDomains = (controller.inviteRejectionPolicy as AllowAllInvites).blockedDomains;
      expect(blockedDomains, contains(domain));
    });

    test("add mxid to exceptions -> adds entry to blocked users", () async {
      await controller.addExceptionEntry(mxid);

      final blockedUsers = (controller.inviteRejectionPolicy as AllowAllInvites).blockedUsers;
      expect(blockedUsers, contains(mxid));
    });

    test("remove homeserver from exceptions -> removes entry from blocked domains", () async {
      await controller.addExceptionEntry(domain);
      await controller.removeExceptionEntry(domain);

      final blockedDomains = (controller.inviteRejectionPolicy as AllowAllInvites).blockedDomains;
      expect(blockedDomains, isEmpty);
    });

    test("remove mxid from exceptions -> removes entry from blocked users", () async {
      await controller.addExceptionEntry(mxid);
      await controller.removeExceptionEntry(mxid);

      final blockedUsers = (controller.inviteRejectionPolicy as AllowAllInvites).blockedUsers;
      expect(blockedUsers, isEmpty);
    });

    test("remove all exceptions -> removes all entries from exceptions", () async {
      await controller.addExceptionEntry(domain);
      await controller.addExceptionEntry(mxid);
      await controller.removeAllExceptionEntries();

      expect(controller.exceptionEntries, isEmpty);
    });

    test("set default setting to BlockAll -> changes policy to BlockAllInvites", () async {
      await controller.setDefaultSetting(InviteRejectionPolicyType.blockAll);

      expect(controller.inviteRejectionPolicy, (newPolicy) => newPolicy is BlockAllInvites);
    });

    test("set default setting from BlockAll back to AllowAll -> loads old exceptions", () async {
      await controller.addExceptionEntry(domain);
      await controller.addExceptionEntry(mxid);
      await controller.setDefaultSetting(InviteRejectionPolicyType.blockAll);
      await controller.setDefaultSetting(InviteRejectionPolicyType.allowAll);

      expect(controller.exceptionEntries, containsAll({domain, mxid}));
    });
  });

  group("BlockAll", () {
    final policy = BlockAllInvites(allowedDomains: {}, allowedUsers: {});

    // always reinitialize controller for each test
    setUp(() {
      inviteRejectionPolicyRepository = MockInviteRejectionPolicyRepository();
      when(inviteRejectionPolicyRepository.getCurrentPolicy())
          .thenAnswer((_) => Future.value(policy));
      controller = SettingsInviteRejectionController(
        inviteRejectionPolicyRepository: inviteRejectionPolicyRepository,
      );
    });

    test("add homeserver to exceptions -> adds entry to allowed domains", () async {
      await controller.addExceptionEntry(domain);

      final allowedDomains = (controller.inviteRejectionPolicy as BlockAllInvites).allowedDomains;
      expect(allowedDomains, contains(domain));
    });

    test("add mxid to exceptions -> adds entry to allowed users", () async {
      await controller.addExceptionEntry(mxid);

      final allowedUsers = (controller.inviteRejectionPolicy as BlockAllInvites).allowedUsers;
      expect(allowedUsers, contains(mxid));
    });

    test("remove homeserver from exceptions -> removes entry from allowed domains", () async {
      await controller.addExceptionEntry(domain);
      await controller.removeExceptionEntry(domain);

      final allowedDomains = (controller.inviteRejectionPolicy as BlockAllInvites).allowedDomains;
      expect(allowedDomains, isEmpty);
    });

    test("remove mxid from exceptions -> removes entry from allowed users", () async {
      await controller.addExceptionEntry(mxid);
      await controller.removeExceptionEntry(mxid);

      final allowedUsers = (controller.inviteRejectionPolicy as BlockAllInvites).allowedUsers;
      expect(allowedUsers, isEmpty);
    });

    test("remove all exceptions -> removes all entries from exceptions", () async {
      await controller.addExceptionEntry(domain);
      await controller.addExceptionEntry(mxid);
      await controller.removeAllExceptionEntries();

      expect(controller.exceptionEntries, isEmpty);
    });

    test("set default setting to AllowAll -> changes policy to AllowAllInvites", () async {
      await controller.setDefaultSetting(InviteRejectionPolicyType.allowAll);

      expect(controller.inviteRejectionPolicy, (newPolicy) => newPolicy is AllowAllInvites);
    });

    test("set default setting from AllowAll back to BlockAll -> loads old exceptions", () async {
      await controller.addExceptionEntry(domain);
      await controller.addExceptionEntry(mxid);
      await controller.setDefaultSetting(InviteRejectionPolicyType.allowAll);
      await controller.setDefaultSetting(InviteRejectionPolicyType.blockAll);

      expect(controller.exceptionEntries, containsAll({domain, mxid}));
    });
  });
}
