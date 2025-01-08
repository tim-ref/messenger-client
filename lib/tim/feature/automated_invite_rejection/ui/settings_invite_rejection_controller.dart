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
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

class SettingsInviteRejectionController extends ChangeNotifier {
  final logger = Logger();
  final InviteRejectionPolicyRepository _inviteRejectionPolicyRepository;

  InviteRejectionPolicy? inviteRejectionPolicy;
  AllowAllInvites? _cachedAllowAllInvites;
  BlockAllInvites? _cachedBlockAllInvites;

  InviteRejectionPolicyType? get defaultSetting => switch (inviteRejectionPolicy) {
        AllowAllInvites() => InviteRejectionPolicyType.allowAll,
        BlockAllInvites() => InviteRejectionPolicyType.blockAll,
        null => null,
      };

  SettingsInviteRejectionController({
    required InviteRejectionPolicyRepository inviteRejectionPolicyRepository,
  }) : _inviteRejectionPolicyRepository = inviteRejectionPolicyRepository {
    loadInviteRejectionPolicy();
  }

  Set<String> get exceptionEntries => switch (inviteRejectionPolicy) {
        AllowAllInvites(blockedDomains: final domains, blockedUsers: final users) => {
            ...domains,
            ...users,
          },
        BlockAllInvites(allowedDomains: final domains, allowedUsers: final users) => {
            ...domains,
            ...users,
          },
        null => {},
      };

  Future<void> loadInviteRejectionPolicy() async {
    inviteRejectionPolicy = await _inviteRejectionPolicyRepository.getCurrentPolicy();

    notifyListeners();
  }

  Future<void> setDefaultSetting(InviteRejectionPolicyType newDefaultSetting) async {
    if (newDefaultSetting == defaultSetting) {
      logger.d("Default setting is already ${newDefaultSetting.name} -> nothing to change.");
      return; // Nothing to change here
    }

    InviteRejectionPolicy? newPolicy;

    switch (newDefaultSetting) {
      case InviteRejectionPolicyType.allowAll:
        if (_cachedAllowAllInvites != null) {
          newPolicy = _cachedAllowAllInvites;
        } else {
          newPolicy = AllowAllInvites.blockingNone();
        }
        _cachedBlockAllInvites = inviteRejectionPolicy as BlockAllInvites;
      case InviteRejectionPolicyType.blockAll:
        if (_cachedBlockAllInvites != null) {
          newPolicy = _cachedBlockAllInvites;
        } else {
          newPolicy = BlockAllInvites.allowingNone();
        }
        _cachedAllowAllInvites = inviteRejectionPolicy as AllowAllInvites;
    }

    await _updatePolicy(newPolicy);
  }

  Future<void> addExceptionEntry(String exceptionEntry) async {
    if (inviteRejectionPolicy == null) return;
    if (exceptionEntry.isEmpty) return;

    final newPolicy = addExceptionToPolicy(inviteRejectionPolicy!, exceptionEntry);

    await _updatePolicy(newPolicy);
  }

  Future<void> removeExceptionEntry(String exceptionEntry) async {
    if (inviteRejectionPolicy == null) return;
    if (exceptionEntry.isEmpty) return;

    final newPolicy = removeExceptionFromPolicy(inviteRejectionPolicy!, exceptionEntry);

    await _updatePolicy(newPolicy);
  }

  Future<void> removeAllExceptionEntries() async {
    if (inviteRejectionPolicy == null) return;

    final newPolicy = removeAllExceptionsFromPolicy(inviteRejectionPolicy!);

    await _updatePolicy(newPolicy);
  }

  Future<void> _updatePolicy(InviteRejectionPolicy? newPolicy) async {
    if (newPolicy == null) return;
    await _inviteRejectionPolicyRepository.setNewPolicy(newPolicy);
    inviteRejectionPolicy = newPolicy;
    notifyListeners();
  }
}

enum InviteRejectionPolicyType { allowAll, blockAll }
