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

import 'dart:async';
import 'dart:convert';

import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_policy.dart';
import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_policy_json.dart';
import 'package:logger/logger.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/matrix/tim_matrix_client.dart';

const permissionConfigNameSpace = 'de.gematik.tim.account.permissionconfig.pro.v1';

/// [A_25043 - Berechtigungskonfiguration in Accountdaten speichern](https://gemspec.gematik.de/docs/gemSpec/gemSpec_TI-M_Basis/gemSpec_TI-M_Basis_V1.0.0/#A_25043)
/// [A_25044 - Namespace für Berechtigungskonfiguration](https://gemspec.gematik.de/docs/gemSpec/gemSpec_TI-M_Basis/gemSpec_TI-M_Basis_V1.0.0/#A_25044)
/// [A_25258 - Schema der Berechtigungskonfiguration](https://gemspec.gematik.de/docs/gemSpec/gemSpec_TI-M_Basis/gemSpec_TI-M_Basis_V1.0.0/#A_25258)
abstract class InviteRejectionPolicyRepository {
  void listenToNewRejectionPolicy();

  Future<void> setNewPolicy(InviteRejectionPolicy newPolicy);

  Future<InviteRejectionPolicy> getCurrentPolicy();
}

class InviteRejectionPolicyRepositoryImpl implements InviteRejectionPolicyRepository {
  InviteRejectionPolicyRepositoryImpl(this._timClient);

  final _targetEventType = permissionConfigNameSpace;

  final TimMatrixClient _timClient;
  final _logger = Logger();

  InviteRejectionPolicy? _inviteRejectionPolicy;
  StreamSubscription<BasicEvent>? _onEventStreamSubscription;

  /// listens to updates concerning the rejection policy through the user´s account data.
  /// Is also triggered when a user logs in.
  @override
  void listenToNewRejectionPolicy() {
    _onEventStreamSubscription ??= _timClient
        .onAccountDataChange()
        .stream
        .where((event) => event.type == _targetEventType)
        .listen(
      (event) {
        _inviteRejectionPolicy = parseRejectionPolicyFromJson(event.content);
      },
      onError: (error, stackTrace) {
        _logger.e("Error occured while listening to [client.onEvent.stream]: $error\n"
            "\n"
            "$stackTrace");
      },
    );
  }

  /// Saves [InviteRejectionPolicy] to the matrix homeserver.
  @override
  Future<void> setNewPolicy(InviteRejectionPolicy policy) {
    final data = convertInviteRejectionPolicyToJson(policy);
    return _timClient.setAccountData(_timClient.userID, _targetEventType, data);
  }

  /// Retrieves [InviteRejectionPolicy] from the loaded policy. If there is no policy cached, load from
  /// matrix homeserver.
  @override
  Future<InviteRejectionPolicy> getCurrentPolicy() async {
    if (_inviteRejectionPolicy != null) return _inviteRejectionPolicy!;

    final res = await _timClient.getAccountData(_timClient.userID, _targetEventType);

    _inviteRejectionPolicy = parseRejectionPolicyFromJson(res);
    return _inviteRejectionPolicy!;
  }
}

class InviteRejectionPolicyRepositoryFakeImpl implements InviteRejectionPolicyRepository {
  InviteRejectionPolicy _inviteRejectionPolicy = AllowAllInvites(
    blockedServers: {'homeserverA', 'homeserverB', 'nochEinHomeserver', 'bibup'},
    blockedUsers: {
      '@test:homeserver',
      '@test123:homeserverA',
      '@grafa:vonhausen',
      '@nochmal:test',
    },
    blockedUserGroups: {},
  );

  final _preferencesKey = 'inviteRejectionPolicy';

  final TimMatrixClient _timClient;

  InviteRejectionPolicyRepositoryFakeImpl(this._timClient);

  @override
  Future<InviteRejectionPolicy> getCurrentPolicy() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final inviteRejectionPolicyJson = sharedPreferences.getString(_preferencesKey);
    if (inviteRejectionPolicyJson != null) {
      _inviteRejectionPolicy = parseRejectionPolicyFromJson(jsonDecode(inviteRejectionPolicyJson));
    }
    return _inviteRejectionPolicy;
  }

  @override
  void listenToNewRejectionPolicy() {
    // to simulate testing for the debug widget
    final data = convertInviteRejectionPolicyToJson(_inviteRejectionPolicy);
    _timClient.setAccountData(_timClient.userID, permissionConfigNameSpace, data);
  }

  @override
  Future<void> setNewPolicy(InviteRejectionPolicy newPolicy) async {
    _inviteRejectionPolicy = newPolicy;
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
      _preferencesKey,
      jsonEncode(convertInviteRejectionPolicyToJson(newPolicy)),
    );
  }
}
