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
import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_policy_json.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('block all policy', () {
    final exampleJsonBlockAll = {
      'defaultSetting': 'block all',
      'serverExceptions': {'domain1': {}, 'domain2': {}},
      'userExceptions': {'@test1:domain1': {}, '@test2:domain1': {}},
      'groupExceptions': ['isInsuredPerson'],
    };

    test('given valid json data to parseRejectionPolicyFromJson should parse correctly', () {
      final res = parseRejectionPolicyFromJson(exampleJsonBlockAll);

      expect(
        res,
        isA<BlockAllInvites>().having(
          (e) => e.allowedUsers,
          'allowedUsers',
          {'@test1:domain1', '@test2:domain1'},
        ).having((e) => e.allowedServers, 'allowedServers', {'domain1', 'domain2'}).having(
          (e) => e.allowedUserGroups,
          'allowedUserGroups',
          {UserGroup.isInsuredPerson},
        ),
      );
    });

    test('should parse minimal policy correctly', () {
      final res = parseRejectionPolicyFromJson({'defaultSetting': 'block all'});

      expect(res, isA<BlockAllInvites>());
    });

    test('given RejectionPolicy should convert to expected Json', () {
      final policy = BlockAllInvites(
        allowedServers: {'domain1', 'domain2'},
        allowedUsers: {'@test1:domain1', '@test2:domain1'},
        allowedUserGroups: {UserGroup.isInsuredPerson},
      );

      final res = convertInviteRejectionPolicyToJson(policy);

      expect(res, exampleJsonBlockAll);
    });

    test('given RejectionPolicy should serialize and deserialize correctly', () {
      final policy = BlockAllInvites(
        allowedServers: {'domain1', 'domain2'},
        allowedUsers: {'@test1:domain1', '@test2:domain1'},
        allowedUserGroups: {UserGroup.isInsuredPerson},
      );
      expect(
        parseRejectionPolicyFromJson(convertInviteRejectionPolicyToJson(policy)),
        isA<BlockAllInvites>()
            .having((e) => e.allowedUsers, 'allowedUsers', policy.allowedUsers)
            .having((e) => e.allowedServers, 'allowedServers', policy.allowedServers)
            .having((e) => e.allowedUserGroups, 'allowedUserGroups', policy.allowedUserGroups),
      );
    });
  });

  group('allow all policy', () {
    final exampleJsonAllowAll = {
      'defaultSetting': 'allow all',
      'userExceptions': {'@blocked1:domain1': {}, '@blocked2:domain2': {}},
      'serverExceptions': {'domain1': {}, 'domain2': {}},
      'groupExceptions': ['isInsuredPerson'],
    };

    test(
        'given valid json data to parseRejectionPolicyFromJson should parse AllowAllInvites correctly',
        () {
      final res = parseRejectionPolicyFromJson(exampleJsonAllowAll);

      expect(
        res,
        isA<AllowAllInvites>().having(
          (e) => e.blockedUsers,
          'blockedUsers',
          {'@blocked1:domain1', '@blocked2:domain2'},
        ).having(
          (e) => e.blockedServers,
          'blockedServers',
          {'domain1', 'domain2'},
        ).having((e) => e.blockedUserGroups, 'blockedUserGroups', {UserGroup.isInsuredPerson}),
      );
    });

    test('should parse minimal policy correctly', () {
      final res = parseRejectionPolicyFromJson({'defaultSetting': 'allow all'});

      expect(res, isA<AllowAllInvites>());
    });

    test('given AllowAllInvites should convert to expected JSON', () {
      final policy = AllowAllInvites(
        blockedServers: {'domain1', 'domain2'},
        blockedUsers: {'@blocked1:domain1', '@blocked2:domain2'},
        blockedUserGroups: {UserGroup.isInsuredPerson},
      );

      final res = convertInviteRejectionPolicyToJson(policy);

      expect(res, exampleJsonAllowAll);
    });

    test('given AllowAllInvites should serialize and deserialize correctly', () {
      final policy = AllowAllInvites(
        blockedServers: {'domain1', 'domain2'},
        blockedUsers: {'@blocked1:domain1', '@blocked2:domain2'},
        blockedUserGroups: {UserGroup.isInsuredPerson},
      );

      final serialized = convertInviteRejectionPolicyToJson(policy);
      final deserialized = parseRejectionPolicyFromJson(serialized);

      expect(
        deserialized,
        isA<AllowAllInvites>()
            .having((e) => e.blockedUsers, 'blockedUsers', policy.blockedUsers)
            .having((e) => e.blockedServers, 'blockedServers', policy.blockedServers)
            .having((e) => e.blockedUserGroups, 'blockedUserGroups', {UserGroup.isInsuredPerson}),
      );
    });
  });
}
