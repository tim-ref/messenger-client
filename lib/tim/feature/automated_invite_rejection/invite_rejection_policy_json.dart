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

/// Expected schema of json can be found here: see: https://github.com/gematik/api-ti-messenger/commit/9b9f21b87949e778de85dbbc19e25f53495871e2#diff-497ec6e8851cb404e681bc28551f0c288d09a3d496d05ee8a13643699a3f6798
InviteRejectionPolicy parseRejectionPolicyFromJson(Map<String, dynamic> json) {
  // each domain is an empty object, but for now only the mxid or Matrix server name (represented by key here) are needed.
  final domainExceptions = !json.containsKey('domainExceptions')
      ? <String>{}
      : ((json['domainExceptions'] as Map).keys).toSet().cast<String>();
  final userExceptions =
      !json.containsKey('userExceptions') ? <String>{} : ((json['userExceptions'] as Map).keys).toSet().cast<String>();

  switch (json['defaultSetting']) {
    case 'block all':
      return BlockAllInvites(allowedDomains: domainExceptions, allowedUsers: userExceptions);
    case 'allow all':
      return AllowAllInvites(blockedDomains: domainExceptions, blockedUsers: userExceptions);
    default:

      /// should always be one of the above cases, otherwise its a bug.
      throw Exception('Unexpected Rejection Policy Format');
  }
}

Map<String, dynamic> convertInviteRejectionPolicyToJson(InviteRejectionPolicy policy) {
  final defaultSetting = policy is AllowAllInvites ? 'allow all' : 'block all';

  final (userExceptions, domainExceptions) = switch (policy) {
    AllowAllInvites(blockedUsers: final blockedUsers, blockedDomains: final blockedDomains) => (
        blockedUsers,
        blockedDomains
      ),
    BlockAllInvites(allowedUsers: final allowedUsers, allowedDomains: final allowedDomains) => (
        allowedUsers,
        allowedDomains
      ),
  };

  return {
    'defaultSetting': defaultSetting,
    'domainExceptions': {for (final item in domainExceptions) item: {}},
    'userExceptions': {for (final item in userExceptions) item: {}},
  };
}
