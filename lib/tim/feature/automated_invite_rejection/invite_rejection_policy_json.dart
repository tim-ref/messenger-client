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

const _defaultSetting = 'defaultSetting';
const _blockAll = 'block all';
const _allowAll = 'allow all';
const _userExceptions = 'userExceptions';
const _serverExceptions = 'serverExceptions';
const _groupExceptions = 'groupExceptions';
const _inInsuredPerson = 'isInsuredPerson';

// each domain is an empty object, but for now only the mxid or Matrix server name (represented by key here) are needed.
Set<String> _parseKeys(dynamic value) =>
    value == null ? <String>{} : ((value as Map).keys).toSet().cast<String>();

Set<UserGroup> _parseGroups(dynamic json) => {
      if (json?.contains(_inInsuredPerson) ?? false) UserGroup.isInsuredPerson,
    };

List<String> _convertGroupsToJson(Iterable<UserGroup> groups) => [
      if (groups.contains(UserGroup.isInsuredPerson)) _inInsuredPerson,
    ];

/// Expected schema of json can be found here: see: https://github.com/gematik/api-ti-messenger/commit/9b9f21b87949e778de85dbbc19e25f53495871e2#diff-497ec6e8851cb404e681bc28551f0c288d09a3d496d05ee8a13643699a3f6798
InviteRejectionPolicy parseRejectionPolicyFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {_defaultSetting: _blockAll} => BlockAllInvites(
        allowedServers: _parseKeys(json[_serverExceptions]),
        allowedUsers: _parseKeys(json[_userExceptions]),
        allowedUserGroups: _parseGroups(json[_groupExceptions]),
      ),
    {_defaultSetting: _allowAll} => AllowAllInvites(
        blockedServers: _parseKeys(json[_serverExceptions]),
        blockedUsers: _parseKeys(json[_userExceptions]),
        blockedUserGroups: _parseGroups(json[_groupExceptions]),
      ),

    /// should always be one of the above cases, otherwise its a bug.
    _ => throw Exception('Unexpected Rejection Policy Format')
  };
}

Map<String, dynamic> convertInviteRejectionPolicyToJson(InviteRejectionPolicy policy) =>
    switch (policy) {
      AllowAllInvites(:final blockedUsers, :final blockedServers, :final blockedUserGroups) => {
          _defaultSetting: _allowAll,
          if (blockedServers.isNotEmpty)
            _serverExceptions: {for (final item in blockedServers) item: {}},
          if (blockedUsers.isNotEmpty) _userExceptions: {for (final item in blockedUsers) item: {}},
          if (blockedUserGroups.isNotEmpty)
            _groupExceptions: _convertGroupsToJson(blockedUserGroups),
        },
      BlockAllInvites(:final allowedUsers, :final allowedServers, :final allowedUserGroups) => {
          _defaultSetting: _blockAll,
          if (allowedServers.isNotEmpty)
            _serverExceptions: {for (final item in allowedServers) item: {}},
          if (allowedUsers.isNotEmpty) _userExceptions: {for (final item in allowedUsers) item: {}},
          if (allowedUserGroups.isNotEmpty)
            _groupExceptions: _convertGroupsToJson(allowedUserGroups),
        },
    };
