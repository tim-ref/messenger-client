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

import 'dart:async';

import 'package:fluffychat/tim/feature/automated_invite_rejection/insurer_information_repository.dart';
import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_policy.dart';
import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_policy_repository.dart';
import 'package:fluffychat/tim/feature/tim_version/tim_version_service.dart';
import 'package:fluffychat/tim/shared/matrix/tim_matrix_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:matrix/matrix.dart';

/// [A_25046 - Durchsetzung der Berechtigungskonfiguration - Client](https://gemspec.gematik.de/docs/gemSpec/gemSpec_TI-M_Basis/gemSpec_TI-M_Basis_V1.0.0/#A_25046)
class InviteRejectionService {
  final _logger = Logger();

  final TimVersionService _timVersionService;
  final InviteRejectionPolicyRepository _inviteRejectionPolicyRepository;
  final InsurerInformationRepository _timInformationRepository;
  final TimMatrixClient _client;

  /// Delay between receiving an invite and leaving the room the user is invited to.
  /// Defaults to 1,500 ms.
  final Duration? _blockDelay;

  /// StreamSubscription auf [matrix.Client.onEvent] soll in der [dispose] Funktion eines
  /// StatefulWidgets über [StreamSubscription.cancel] beendet werden.
  StreamSubscription<EventUpdate>? _onEventStreamSubscription;

  /// [A_25046 - Durchsetzung der Berechtigungskonfiguration - Client](https://gemspec.gematik.de/docs/gemSpec/gemSpec_TI-M_Basis/gemSpec_TI-M_Basis_V1.0.0/#A_25046)
  InviteRejectionService({
    required TimVersionService timVersionService,
    required InviteRejectionPolicyRepository inviteRejectionPolicyRepository,
    required TimMatrixClient client,
    required InsurerInformationRepository timInformationRepository,
    Duration? blockDelay = const Duration(milliseconds: 1500),
  })  : _timVersionService = timVersionService,
        _inviteRejectionPolicyRepository = inviteRejectionPolicyRepository,
        _client = client,
        _blockDelay = blockDelay,
        _timInformationRepository = timInformationRepository;

  /// Registrieren des onEventUpdate Handlers
  void initInviteRejectOnEventStream() {
    _onEventStreamSubscription ??= _client.onEventUpdate.stream.where(_isInviteEventType).listen(
          _handleInviteEvent,
          onError: _logEventStreamError,
        );
  }

  bool _isInviteEventType(EventUpdate event) => event.type == EventUpdateType.inviteState;

  // for each invite action, multiple events with type EventUpdateType.inviteState are received.
  // This method filters out the correct event, where the receiving user is in the state key.
  static bool isCorrectInviteEvent(EventUpdate event, String currentUserId) => switch (event) {
        EventUpdate(
          type: EventUpdateType.inviteState,
          content: {
            'content': {'membership': "invite"},
            'sender': String _,
            'state_key': final stateKey,
            'type': 'm.room.member',
          },
        ) =>
          stateKey == currentUserId,
        _ => false
      };

  void _logEventStreamError(Object error, StackTrace stackTrace) {
    _logger.e(
      "Error occurred while listening to [client.onEventUpdate.stream]: $error\n"
      "\n"
      "$stackTrace",
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Prüfen und Behandeln von Einladungen
  Future<void> _handleInviteEvent(EventUpdate event) async {
    final doClientSideInviteRejection =
        await _timVersionService.versionFeaturesClientSideInviteRejection();
    if (doClientSideInviteRejection == false) return;

    _logger.i("Handle incoming invite event -> reject if necessary");

    if (!isCorrectInviteEvent(event, _client.userID)) {
      _logger.i("InviteRejectionService can only handle invite events.\n"
          "Event type was ${event.type}");
      return;
    }

    final roomID = event.roomID;

    final sender = event.content["sender"] as String;

    if (!sender.isValidMatrixId) {
      _logger.i("The invite event sender $sender is not a valid mxid");
      return;
    }

    final inviteRejectionPolicy = await _inviteRejectionPolicyRepository.getCurrentPolicy();

    final serverName = sender.domain;
    if (serverName == null) {
      _logger.e('Could not extract Servername From Mxid.');
      return;
    }
    final isSenderInsuranceResult =
        await _timInformationRepository.doesServerBelongToInsurer(serverName);

    final isInsuredPerson = isSenderInsuranceResult.getOrElse(() => null);

    if (doesReject(inviteRejectionPolicy, sender, sender.domain,
        isSenderAnInsuredPerson: isInsuredPerson)) {
      _logger.i("Reject invitation from $sender with roomID: $roomID");
      await _blockInvitation(roomID);
    }
  }

  Future<void> _blockInvitation(String roomID) async {
    if (_blockDelay != null) {
      await Future.delayed(_blockDelay);
    }
    _client.leaveRoom(roomID);
  }

  Future<void> dispose() async {
    await _onEventStreamSubscription?.cancel();
  }
}
