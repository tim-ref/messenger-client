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

import 'package:collection/collection.dart';
import 'package:matrix/matrix.dart';

/// Determines, which invites to automatically reject.
/// Ti-M Basis Berechtigungskonfiguration. See
/// [#A_25045](https://gemspec.gematik.de/docs/gemSpec/gemSpec_TI-M_Basis/gemSpec_TI-M_Basis_V1.0.0/#A_25045)
sealed class InviteRejectionPolicy {}

enum UserGroup { isInsuredPerson }

typedef SetMapping = Set<String> Function(Set<String> v);
typedef GroupMapping = Set<UserGroup> Function(Set<UserGroup> v);

/// Do not automatically reject invites, except invites from explicitly listed users, servers and groups.
/// [A_26390](https://gemspec.gematik.de/docs/gemSpec/gemSpec_TI-M_Pro/gemSpec_TI-M_Pro_V1.0.1/#A_26390)
/// [Schema der Berechtigungskonfiguration]( https://github.com/gematik/api-ti-messenger/blob/tim-pro-1.0.0/src/schema/TI-M_Pro/permissionConfig_V1.json)
class AllowAllInvites implements InviteRejectionPolicy {
  /// List of Matrix server names. Example ["matrix.org"]
  /// Invites from users on these domains are to be automatically rejected.
  final Set<String> blockedServers;

  /// List of Matrix user IDs. Example ["@user:matrix.org"]
  /// Invites from these user are to be automatically rejected.
  final Set<String> blockedUsers;

  /// List of TI-M user groups. Example [Group.isInsuredPerson]
  /// Invites from user in these groups are to be automatically rejected.
  final Set<UserGroup> blockedUserGroups;

  AllowAllInvites({
    required this.blockedServers,
    required this.blockedUsers,
    required this.blockedUserGroups,
  });

  /// Creates an AllowAllInvites policy without any blocked servers, users or groups.
  AllowAllInvites.blockingNone()
      : blockedServers = {},
        blockedUsers = {},
        blockedUserGroups = {};

  /// Creates a modified copy of a policy.
  AllowAllInvites.clone(
    AllowAllInvites orig, {
    SetMapping? updateServers,
    SetMapping? updateUsers,
    GroupMapping? updateGroups,
  })  : blockedServers = updateServers?.call(orig.blockedServers) ?? orig.blockedServers,
        blockedUsers = updateUsers?.call(orig.blockedServers) ?? orig.blockedServers,
        blockedUserGroups = updateGroups?.call(orig.blockedUserGroups) ?? orig.blockedUserGroups;
}

/// Automatically reject all invites, except invites from explicitly listed users, servers and groups.
class BlockAllInvites implements InviteRejectionPolicy {
  /// List of Matrix server names. Example ["matrix.org"]
  /// Invites from users on these domains are exempt from being automatically rejected.
  final Set<String> allowedServers;

  /// List of Matrix user IDs. Example ["@user:matrix.org"]
  /// Invites from these user are exempt from being automatically rejected.
  final Set<String> allowedUsers;

  /// List of TI-M user groups. Example [Group.isInsuredPerson]
  /// Invites from user in these groups are exempt from being automatically rejected.
  final Set<UserGroup> allowedUserGroups;

  BlockAllInvites({
    required this.allowedServers,
    required this.allowedUsers,
    required this.allowedUserGroups,
  });

  /// Creates a BlockAllInvites policy without any allowed servers, users or groups.
  BlockAllInvites.allowingNone()
      : allowedServers = {},
        allowedUsers = {},
        allowedUserGroups = {};

  /// Creates a modified copy of a policy.
  BlockAllInvites.clone(
    BlockAllInvites orig, {
    SetMapping? updateServers,
    SetMapping? updateUsers,
    GroupMapping? updateGroups,
  })  : allowedServers = updateServers?.call(orig.allowedServers) ?? orig.allowedServers,
        allowedUsers = updateUsers?.call(orig.allowedServers) ?? orig.allowedServers,
        allowedUserGroups = updateGroups?.call(orig.allowedUserGroups) ?? orig.allowedUserGroups;
}

/// Should an invitation from the given sender be rejected automatically?
bool doesReject(
  InviteRejectionPolicy policy,
  String invitationSender,
  String? senderDomain, {
  bool? isSenderAnInsuredPerson,
}) {
  return switch (policy) {
    AllowAllInvites() => policy.blockedServers.contains(senderDomain) ||
        policy.blockedUsers.contains(invitationSender) ||
        (policy.blockedUserGroups.contains(UserGroup.isInsuredPerson) &&
            isSenderAnInsuredPerson == true),
    BlockAllInvites() => !policy.allowedServers.contains(senderDomain) &&
        !policy.allowedUsers.contains(invitationSender) &&
        !(policy.allowedUserGroups.contains(UserGroup.isInsuredPerson) &&
            isSenderAnInsuredPerson == true),
  };
}

/// Does the given policy reject all invites without exception?
bool rejectsEveryone(InviteRejectionPolicy? policy) => switch (policy) {
      BlockAllInvites(
        allowedUsers: Map(isEmpty: true),
        allowedServers: Map(isEmpty: true),
        allowedUserGroups: Map(isEmpty: true),
      ) =>
        true,
      _ => false,
    };

/// Adds [exceptionEntry] to given policy.
/// If the given [exceptionEntry] is a valid mxid it will be added to users else to domains.
InviteRejectionPolicy addExceptionToPolicy(InviteRejectionPolicy policy, String exceptionEntry) {
  if (exceptionEntry.isEmpty) return policy;

  Set<String> addItem(Set<String> set) => {...set, exceptionEntry};

  if (exceptionEntry.isValidMatrixId) {
    return switch (policy) {
      AllowAllInvites() => AllowAllInvites.clone(policy, updateUsers: addItem),
      BlockAllInvites() => BlockAllInvites.clone(policy, updateUsers: addItem),
    };
  } else if (UserGroup.values.asNameMap().containsKey(exceptionEntry)) {
    final group = UserGroup.values.asNameMap()[exceptionEntry]!;
    Set<UserGroup> addGroup(Set<UserGroup> set) => {...set, group};
    return switch (policy) {
      AllowAllInvites() => AllowAllInvites.clone(policy, updateGroups: addGroup),
      BlockAllInvites() => BlockAllInvites.clone(policy, updateGroups: addGroup),
    };
  } else {
    return switch (policy) {
      BlockAllInvites() => BlockAllInvites.clone(policy, updateServers: addItem),
      AllowAllInvites() => AllowAllInvites.clone(policy, updateServers: addItem),
    };
  }
}

/// Removes [exceptionEntry] from given policy.
/// If the given [exceptionEntry] is a valid mxid, it will be removed from users, if it is a group will
/// be removed from groups, and else it will be removed from servers.
InviteRejectionPolicy removeExceptionFromPolicy(
  InviteRejectionPolicy policy,
  String exceptionEntry,
) {
  if (exceptionEntry.isEmpty) return policy;

  Set<String> removeItem(Set<String> set) => set.whereNot((item) => item == exceptionEntry).toSet();
  if (exceptionEntry.isValidMatrixId) {
    return switch (policy) {
      AllowAllInvites() => AllowAllInvites.clone(policy, updateUsers: removeItem),
      BlockAllInvites() => BlockAllInvites.clone(policy, updateUsers: removeItem),
    };
  } else if (UserGroup.values.asNameMap().containsKey(exceptionEntry)) {
    Set<UserGroup> removeGroup(Set<UserGroup> set) =>
        set.whereNot((item) => item.name == exceptionEntry).toSet();
    return switch (policy) {
      AllowAllInvites() => AllowAllInvites.clone(policy, updateGroups: removeGroup),
      BlockAllInvites() => BlockAllInvites.clone(policy, updateGroups: removeGroup),
    };
  } else {
    return switch (policy) {
      AllowAllInvites() => AllowAllInvites.clone(policy, updateServers: removeItem),
      BlockAllInvites() => BlockAllInvites.clone(policy, updateServers: removeItem),
    };
  }
}

/// Removes all exceptions from given [policy].
InviteRejectionPolicy removeAllExceptionsFromPolicy(InviteRejectionPolicy policy) =>
    switch (policy) {
      AllowAllInvites() => AllowAllInvites.blockingNone(),
      BlockAllInvites() => BlockAllInvites.allowingNone(),
    };
