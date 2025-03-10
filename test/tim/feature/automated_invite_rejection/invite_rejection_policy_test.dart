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
import 'package:flutter_test/flutter_test.dart';

void main() {
  const user = "user";
  const domain = "domain";
  const mxid = "@$user:$domain";
  const userGroup = UserGroup.isInsuredPerson;

  const validMxid = '@user:domain.com';
  final validGroupName = UserGroup.isInsuredPerson.name;
  const domainEntry = 'matrix.org';
  const emptyEntry = '';

  group("allow all policy", () {
    test("invite from user who is not blocked -> should not be rejected", () async {
      final inviteRejectionPolicy = AllowAllInvites.blockingNone();
      final result = doesReject(inviteRejectionPolicy, mxid, domain);

      expect(result, isFalse);
    });

    test("invite from user who is blocked by mxid -> should be rejected", () async {
      final inviteRejectionPolicy = AllowAllInvites(
        blockedUsers: {mxid},
        blockedServers: {},
        blockedUserGroups: {},
      );
      final result = doesReject(inviteRejectionPolicy, mxid, domain);

      expect(result, isTrue);
    });

    test("invite from user who is blocked by domain -> should be rejected", () async {
      final inviteRejectionPolicy = AllowAllInvites(
        blockedUsers: {},
        blockedServers: {domain},
        blockedUserGroups: {},
      );
      final result = doesReject(inviteRejectionPolicy, mxid, domain);

      expect(result, isTrue);
    });

    test("invite from user who is blocked by mxid and domain -> should be rejected", () async {
      final inviteRejectionPolicy = AllowAllInvites(
        blockedUsers: {mxid},
        blockedServers: {domain},
        blockedUserGroups: {},
      );
      final result = doesReject(inviteRejectionPolicy, mxid, domain);

      expect(result, isTrue);
    });

    test("invite from user who is blocked by User Group -> should be rejected", () async {
      final inviteRejectionPolicy = AllowAllInvites(
        blockedUsers: {},
        blockedServers: {},
        blockedUserGroups: {userGroup},
      );
      final result = doesReject(inviteRejectionPolicy, mxid, domain, isSenderAnInsuredPerson: true);

      expect(result, isTrue);
    });

    test("invite from user who is not blocked by User Group -> should not be rejected", () async {
      final inviteRejectionPolicy = AllowAllInvites(
        blockedUsers: {},
        blockedServers: {},
        blockedUserGroups: {userGroup},
      );
      final result =
          doesReject(inviteRejectionPolicy, mxid, domain, isSenderAnInsuredPerson: false);

      expect(result, isFalse);
    });
  });

  group("block all policy", () {
    test("invite from user who is not allowed -> should be rejected", () async {
      final inviteRejectionPolicy = BlockAllInvites.allowingNone();
      final result =
          doesReject(inviteRejectionPolicy, mxid, domain, isSenderAnInsuredPerson: false);

      expect(result, isTrue);
    });

    test("invite from user who is allowed by mxid -> should not be rejected", () async {
      final inviteRejectionPolicy = BlockAllInvites(
        allowedUsers: {mxid},
        allowedServers: {},
        allowedUserGroups: {},
      );
      final result =
          doesReject(inviteRejectionPolicy, mxid, domain, isSenderAnInsuredPerson: false);

      expect(result, isFalse);
    });

    test("invite from user who is allowed by domain -> should not be rejected", () async {
      final inviteRejectionPolicy = BlockAllInvites(
        allowedUsers: {},
        allowedServers: {domain},
        allowedUserGroups: {},
      );
      final result =
          doesReject(inviteRejectionPolicy, mxid, domain, isSenderAnInsuredPerson: false);

      expect(result, isFalse);
    });

    test("invite from user who is allowed by user group -> should not be rejected", () async {
      final inviteRejectionPolicy = BlockAllInvites(
        allowedUsers: {},
        allowedServers: {},
        allowedUserGroups: {userGroup},
      );
      final result = doesReject(inviteRejectionPolicy, mxid, domain, isSenderAnInsuredPerson: true);

      expect(result, isFalse);
    });

    test("invite from user who is not allowed by user group -> should be rejected", () async {
      final inviteRejectionPolicy = BlockAllInvites(
        allowedUsers: {},
        allowedServers: {},
        allowedUserGroups: {userGroup},
      );
      final result =
          doesReject(inviteRejectionPolicy, mxid, domain, isSenderAnInsuredPerson: false);

      expect(result, isTrue);
    });
  });

  group('addExceptionToPolicy', () {
    group('AllowAllInvites', () {
      test('empty exceptionEntry returns unchanged policy', () {
        final policy = AllowAllInvites.blockingNone();
        final updatedPolicy = addExceptionToPolicy(policy, emptyEntry) as AllowAllInvites;

        expect(updatedPolicy.blockedServers, equals(policy.blockedServers));
        expect(updatedPolicy.blockedUsers, equals(policy.blockedUsers));
        expect(updatedPolicy.blockedUserGroups, equals(policy.blockedUserGroups));
      });

      test('adding valid Matrix ID adds to blockedUsers', () {
        final policy = AllowAllInvites.blockingNone();
        final updatedPolicy = addExceptionToPolicy(policy, validMxid) as AllowAllInvites;

        expect(updatedPolicy.blockedUsers.contains(validMxid), isTrue);
      });

      test('adding valid group name adds to blockedUserGroups', () {
        final policy = AllowAllInvites.blockingNone();
        final updatedPolicy = addExceptionToPolicy(policy, validGroupName) as AllowAllInvites;

        expect(updatedPolicy.blockedUserGroups, contains(UserGroup.isInsuredPerson));
      });

      test('adding non-mxid and non-group adds to blockedServers', () {
        final policy = AllowAllInvites.blockingNone();
        final updatedPolicy = addExceptionToPolicy(policy, domainEntry) as AllowAllInvites;

        expect(updatedPolicy.blockedServers.contains(domainEntry), isTrue);
      });
    });

    group('BlockAllInvites', () {
      test('empty exceptionEntry returns unchanged policy', () {
        final policy = BlockAllInvites.allowingNone();
        final updatedPolicy = addExceptionToPolicy(policy, emptyEntry) as BlockAllInvites;

        expect(updatedPolicy.allowedServers, equals(policy.allowedServers));
        expect(updatedPolicy.allowedUsers, equals(policy.allowedUsers));
        expect(updatedPolicy.allowedUserGroups, equals(policy.allowedUserGroups));
      });

      test('adding valid Matrix ID adds to allowedUsers', () {
        final policy = BlockAllInvites.allowingNone();
        final updatedPolicy = addExceptionToPolicy(policy, validMxid) as BlockAllInvites;

        expect(updatedPolicy.allowedUsers.contains(validMxid), isTrue);
      });

      test('adding valid group name adds to allowedUserGroups', () {
        final policy = BlockAllInvites.allowingNone();
        final updatedPolicy = addExceptionToPolicy(policy, validGroupName) as BlockAllInvites;

        expect(updatedPolicy.allowedUserGroups, contains(UserGroup.isInsuredPerson));
      });

      test('adding non-mxid and non-group adds to allowedServers', () {
        final policy = BlockAllInvites.allowingNone();
        final updatedPolicy = addExceptionToPolicy(policy, domainEntry) as BlockAllInvites;

        expect(updatedPolicy.allowedServers.contains(domainEntry), isTrue);
      });
    });
  });

  group('removeExceptionFromPolicy', () {
    group('AllowAllInvites', () {
      test('empty exceptionEntry returns unchanged policy', () {
        final policy = AllowAllInvites(
          blockedUsers: {validMxid},
          blockedServers: {domainEntry},
          blockedUserGroups: {UserGroup.isInsuredPerson},
        );
        final updatedPolicy = removeExceptionFromPolicy(policy, emptyEntry) as AllowAllInvites;

        expect(updatedPolicy.blockedUsers, equals(policy.blockedUsers));
        expect(updatedPolicy.blockedServers, equals(policy.blockedServers));
        expect(updatedPolicy.blockedUserGroups, equals(policy.blockedUserGroups));
      });

      test('removing valid Matrix ID removes it from blockedUsers', () {
        final policy = AllowAllInvites(
          blockedUsers: {validMxid},
          blockedServers: {},
          blockedUserGroups: {},
        );
        final updatedPolicy = removeExceptionFromPolicy(policy, validMxid) as AllowAllInvites;

        expect(updatedPolicy.blockedUsers.contains(validMxid), isFalse);
      });

      test('removing valid group name removes it from blockedUserGroups', () {
        final policy = AllowAllInvites(
          blockedUsers: {},
          blockedServers: {},
          blockedUserGroups: {UserGroup.isInsuredPerson},
        );
        final updatedPolicy = removeExceptionFromPolicy(policy, validGroupName) as AllowAllInvites;

        expect(updatedPolicy.blockedUserGroups, isNot(contains(UserGroup.isInsuredPerson)));
      });

      test('removing non-mxid and non-group removes it from blockedServers', () {
        final policy = AllowAllInvites(
          blockedUsers: {},
          blockedServers: {domainEntry},
          blockedUserGroups: {},
        );
        final updatedPolicy = removeExceptionFromPolicy(policy, domainEntry) as AllowAllInvites;

        expect(updatedPolicy.blockedServers.contains(domainEntry), isFalse);
      });
    });

    group('BlockAllInvites', () {
      test('empty exceptionEntry returns unchanged policy', () {
        final policy = BlockAllInvites(
          allowedUsers: {validMxid},
          allowedServers: {domainEntry},
          allowedUserGroups: {UserGroup.isInsuredPerson},
        );
        final updatedPolicy = removeExceptionFromPolicy(policy, emptyEntry) as BlockAllInvites;

        expect(updatedPolicy.allowedUsers, equals(policy.allowedUsers));
        expect(updatedPolicy.allowedServers, equals(policy.allowedServers));
        expect(updatedPolicy.allowedUserGroups, equals(policy.allowedUserGroups));
      });

      test('removing valid Matrix ID removes it from allowedUsers', () {
        final policy = BlockAllInvites(
          allowedUsers: {validMxid},
          allowedServers: {},
          allowedUserGroups: {},
        );
        final updatedPolicy = removeExceptionFromPolicy(policy, validMxid) as BlockAllInvites;

        expect(updatedPolicy.allowedUsers.contains(validMxid), isFalse);
      });

      test('removing valid group name removes it from allowedUserGroups', () {
        final policy = BlockAllInvites(
          allowedUsers: {},
          allowedServers: {},
          allowedUserGroups: {UserGroup.isInsuredPerson},
        );
        final updatedPolicy = removeExceptionFromPolicy(policy, validGroupName) as BlockAllInvites;

        expect(updatedPolicy.allowedUserGroups, isNot(contains(UserGroup.isInsuredPerson)));
      });

      test('removing non-mxid and non-group removes it from allowedServers', () {
        final policy = BlockAllInvites(
          allowedUsers: {},
          allowedServers: {domainEntry},
          allowedUserGroups: {},
        );
        final updatedPolicy = removeExceptionFromPolicy(policy, domainEntry) as BlockAllInvites;

        expect(updatedPolicy.allowedServers.contains(domainEntry), isFalse);
      });
    });
  });

  group('removeAllExceptionsFromPolicy', () {
    test('removes all exceptions from AllowAllInvites', () {
      final policy = AllowAllInvites(
        blockedUsers: {validMxid},
        blockedServers: {domainEntry},
        blockedUserGroups: {UserGroup.isInsuredPerson},
      );
      final updatedPolicy = removeAllExceptionsFromPolicy(policy) as AllowAllInvites;

      expect(updatedPolicy.blockedUsers, isEmpty);
      expect(updatedPolicy.blockedServers, isEmpty);
      expect(updatedPolicy.blockedUserGroups, isEmpty);
    });

    test('removes all exceptions from BlockAllInvites', () {
      final policy = BlockAllInvites(
        allowedUsers: {validMxid},
        allowedServers: {domainEntry},
        allowedUserGroups: {UserGroup.isInsuredPerson},
      );
      final updatedPolicy = removeAllExceptionsFromPolicy(policy) as BlockAllInvites;

      expect(updatedPolicy.allowedUsers, isEmpty);
      expect(updatedPolicy.allowedServers, isEmpty);
      expect(updatedPolicy.allowedUserGroups, isEmpty);
    });
  });
}
