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
import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_policy_json.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final exampleJsonBlockAll = {
    'defaultSetting': 'block all',
    'domainExceptions': {'domain1': {}, 'domain2': {}},
    'userExceptions': {'@test1:domain1': {}, '@test2:domain1': {}, '@test3:domain2': {}},
  };
  final exampleJsonAllowAll = {
    'defaultSetting': 'allow all',
    'userExceptions': {'@blocked1:domain1': {}, '@blocked2:domain2': {}},
    'domainExceptions': {'domain1': {}, 'domain2': {}},
  };

  test('given valid json data to parseRejectionPolicyFromJson should parse correctly', () {
    final res = parseRejectionPolicyFromJson(exampleJsonBlockAll);

    expect(
      res,
      isA<BlockAllInvites>().having(
        (e) => e.allowedUsers,
        'parsed user list correctly',
        {'@test1:domain1', '@test2:domain1', '@test3:domain2'},
      ).having(
        (e) => e.allowedDomains,
        'parsed domain list correctly',
        {'domain1', 'domain2'},
      ),
    );
  });

  test('given RejectionPolicy should convert to expected Json schema', () {
    final policy = BlockAllInvites(
      allowedDomains: {'domain1', 'domain2'},
      allowedUsers: {'@test1:domain1', '@test2:domain1', '@test3:domain2'},
    );

    final res = convertInviteRejectionPolicyToJson(policy);

    expect(res, exampleJsonBlockAll);
  });

  test('given RejectionPolicy should serialize and deserialize correctly', () {
    final policy = BlockAllInvites(
      allowedDomains: {'domain1', 'domain2'},
      allowedUsers: {'@test1:domain1', '@test2:domain1', '@test3:domain2'},
    );
    expect(
      parseRejectionPolicyFromJson(convertInviteRejectionPolicyToJson(policy)),
      isA<BlockAllInvites>().having((e) => e.allowedUsers, 'parsed user list correctly', policy.allowedUsers).having(
            (e) => e.allowedDomains,
            'parsed domain list correctly',
            policy.allowedDomains,
          ),
    );
  });

  test('given valid json data to parseRejectionPolicyFromJson should parse AllowAllInvites correctly', () {
    final res = parseRejectionPolicyFromJson(exampleJsonAllowAll);

    expect(
      res,
      isA<AllowAllInvites>().having(
        (e) => e.blockedUsers,
        'parsed blocked user list correctly',
        {'@blocked1:domain1', '@blocked2:domain2'},
      ).having(
        (e) => e.blockedDomains,
        'parsed blocked domain list correctly',
        {'domain1', 'domain2'},
      ),
    );
  });

  test('given AllowAllInvites should convert to expected JSON schema', () {
    final policy = AllowAllInvites(
      blockedDomains: {'domain1', 'domain2'},
      blockedUsers: {'@blocked1:domain1', '@blocked2:domain2'},
    );

    final res = convertInviteRejectionPolicyToJson(policy);

    expect(res, exampleJsonAllowAll);
  });

  test('given AllowAllInvites should serialize and deserialize correctly', () {
    final policy = AllowAllInvites(
        blockedDomains: {'domain1', 'domain2'}, blockedUsers: {'@blocked1:domain1', '@blocked2:domain2'});

    final serialized = convertInviteRejectionPolicyToJson(policy);
    final deserialized = parseRejectionPolicyFromJson(serialized);

    expect(
      deserialized,
      isA<AllowAllInvites>()
          .having((e) => e.blockedUsers, 'parsed blocked user list correctly', policy.blockedUsers)
          .having(
            (e) => e.blockedDomains,
            'parsed blocked domain list correctly',
            policy.blockedDomains,
          ),
    );
  });
}
