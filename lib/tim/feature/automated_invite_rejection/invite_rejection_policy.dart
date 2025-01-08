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

import 'package:collection/collection.dart';
import 'package:matrix/matrix.dart';

/// Determines, which invites to automatically reject.
/// Ti-M Basis Berechtigungskonfiguration. See
/// https://gemspec.gematik.de/docs/gemSpec/gemSpec_TI-M_Basis/gemSpec_TI-M_Basis_V1.0.0/#A_25045
sealed class InviteRejectionPolicy {}

/// Do not automatically reject invites, except invites from explicitly listed users/domains.
class AllowAllInvites implements InviteRejectionPolicy {
  /// List of Matrix server names. Example ["matrix.org"]
  /// Invites from users on these domains are to be automatically rejected.
  final Set<String> blockedDomains;

  /// List of Matrix user IDs. Example ["@user:matrix.org"]
  /// Invites from these user are to be automatically rejected.
  final Set<String> blockedUsers;

  AllowAllInvites({
    required this.blockedDomains,
    required this.blockedUsers,
  });

  /// Create a AllowAllInvites policy without any blocked domains and users
  AllowAllInvites.blockingNone()
      : blockedDomains = {},
        blockedUsers = {};
}

/// Automatically reject all invites, except invites from explicitly listed users/domains.
class BlockAllInvites implements InviteRejectionPolicy {
  /// List of Matrix server names. Example ["matrix.org"]
  /// Invites from users on these domains are exempt from being automatically rejected.
  final Set<String> allowedDomains;

  /// List of Matrix user IDs. Example ["@user:matrix.org"]
  /// Invites from these user are exempt from being automatically rejected.
  final Set<String> allowedUsers;

  BlockAllInvites({
    required this.allowedDomains,
    required this.allowedUsers,
  });

  /// Create a BlockAllInvites policy without any allowed domains and users
  BlockAllInvites.allowingNone()
      : allowedDomains = {},
        allowedUsers = {};
}


/// Should an invitation from the given sender be rejected automatically?
bool doesReject(InviteRejectionPolicy policy, String invitationSender, String? senderDomain) {
  return switch (policy) {
    AllowAllInvites() => policy.blockedUsers.contains(invitationSender) || policy.blockedDomains.contains(senderDomain),
    BlockAllInvites() =>
    !policy.allowedUsers.contains(invitationSender) && !policy.allowedDomains.contains(senderDomain),
  };
}

/// Adds [exceptionEntry] to given policy
/// If the given [exceptionEntry] is a valid mxid it will be added to users else to domains
InviteRejectionPolicy addExceptionToPolicy(InviteRejectionPolicy policy, String exceptionEntry) {
  if (exceptionEntry.isEmpty) return policy;

  return switch (policy) {
    AllowAllInvites(blockedDomains: final domains, blockedUsers: final users) => exceptionEntry.isValidMatrixId
        ? AllowAllInvites(blockedDomains: domains, blockedUsers: {...users, exceptionEntry})
        : AllowAllInvites(blockedDomains: {...domains, exceptionEntry}, blockedUsers: users),
    BlockAllInvites(allowedDomains: final domains, allowedUsers: final users) => exceptionEntry.isValidMatrixId
        ? BlockAllInvites(allowedDomains: domains, allowedUsers: {...users, exceptionEntry})
        : BlockAllInvites(allowedDomains: {...domains, exceptionEntry}, allowedUsers: users),
  };
}

/// Removes [exceptionEntry] from given policy
/// If the given [exceptionEntry] is a valid mxid it will be removed from users else from domains
InviteRejectionPolicy removeExceptionFromPolicy(
  InviteRejectionPolicy policy,
  String exceptionEntry,
) {
  if (exceptionEntry.isEmpty) return policy;

  return switch (policy) {
    AllowAllInvites(blockedDomains: final domains, blockedUsers: final users) => exceptionEntry.isValidMatrixId
        ? AllowAllInvites(
            blockedDomains: domains,
            blockedUsers: users.whereNot((it) => it == exceptionEntry).toSet(),
          )
        : AllowAllInvites(
            blockedDomains: domains.whereNot((it) => it == exceptionEntry).toSet(),
            blockedUsers: users,
          ),
    BlockAllInvites(allowedDomains: final domains, allowedUsers: final users) => exceptionEntry.isValidMatrixId
        ? BlockAllInvites(
            allowedDomains: domains,
            allowedUsers: users.whereNot((it) => it == exceptionEntry).toSet(),
          )
        : BlockAllInvites(
            allowedDomains: domains.whereNot((it) => it == exceptionEntry).toSet(),
            allowedUsers: users,
          ),
  };
}

/// Removes all exceptions from given [policy]
InviteRejectionPolicy removeAllExceptionsFromPolicy(InviteRejectionPolicy policy) => switch (policy) {
      AllowAllInvites() => AllowAllInvites.blockingNone(),
      BlockAllInvites() => BlockAllInvites.allowingNone(),
    };
