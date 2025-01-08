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

import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_policy.dart';
import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_policy_repository.dart';
import 'package:fluffychat/tim/feature/tim_version/tim_version_service.dart';
import 'package:fluffychat/tim/shared/matrix/tim_matrix_client.dart';
import 'package:logger/logger.dart';
import 'package:matrix/matrix.dart';

/// A_25046 - Durchsetzung der Berechtigungskonfiguration - Client
///
/// https://gemspec.gematik.de/docs/gemSpec/gemSpec_TI-M_Basis/gemSpec_TI-M_Basis_V1.0.0/#A_25046
class InviteRejectionService {
  final TimVersionService _timVersionService;
  final InviteRejectionPolicyRepository _inviteRejectionPolicyRepository;

  final TimMatrixClient _client;

  /// StreamSubscription auf [matrix.Client.onEvent] soll in der [dispose] Funktion eines
  /// StatefulWidgets über [.cancel()] beendet werden.
  StreamSubscription<EventUpdate>? _onEventStreamSubscription;

  final _logger = Logger();

  /// A_25046 - Durchsetzung der Berechtigungskonfiguration - Client
  ///
  /// https://gemspec.gematik.de/docs/gemSpec/gemSpec_TI-M_Basis/gemSpec_TI-M_Basis_V1.0.0/#A_25046
  InviteRejectionService({
    required TimVersionService timVersionService,
    required InviteRejectionPolicyRepository inviteRejectionPolicyRepository,
    required TimMatrixClient client,
  })  : _timVersionService = timVersionService,
        _inviteRejectionPolicyRepository = inviteRejectionPolicyRepository,
        _client = client;

  /// Registrieren des onEventUpdate Handlers
  void initInviteRejectOnEventStream() {
    _onEventStreamSubscription ??= _client.onEventUpdate.stream.where(_isInviteEventType).listen(
          handleInviteEvent,
          onError: _logEventStreamError,
        );
  }

  bool _isInviteEventType(EventUpdate event) => event.type == EventUpdateType.inviteState;


  // for each invite action, multiple events with type EventUpdateType.inviteState are received.
  // This method filters out the correct event, where the receiving user is in the state key.
  bool _isCorrectInviteEvent(EventUpdate event) {
    try {
      if (event.content['type'] != "m.room.member") throw Exception();

      if (event.content['content']['membership'] != "invite") throw Exception();

      if (event.content['state_key'] != _client.userID) throw Exception();
      return true;
    } catch (e) {
      return false;
    }
  }

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
  Future<void> handleInviteEvent(EventUpdate event) async {

    final doClientSideInviteRejection =
        await _timVersionService.versionFeaturesClientSideInviteRejection();
    if (doClientSideInviteRejection == false) return;

    _logger.i("Handle incoming invite event -> reject if necessary");

    if (!_isCorrectInviteEvent(event)) {
      _logger.i("InviteRejectionService can only handle invite events.\n"
          "Event type was ${event.type}");
      return;
    }

    final roomID = event.roomID;

    final sender = event.content["sender"] as String?;

    if (sender == null || !sender.isValidMatrixId) {
      _logger.i("The invite event sender $sender is not a valid mxid");
      return;
    }

    final inviteRejectionPolicy = await _inviteRejectionPolicyRepository.getCurrentPolicy();

    if (doesReject(inviteRejectionPolicy, sender, sender.domain)) {
      _logger.i("Reject invitation from $sender with roomID: $roomID");
      _blockInvitation(roomID);
    }
  }

  Future<void> _blockInvitation(String roomID) async {
    Future.delayed(const Duration(milliseconds: 1500)).then(
      (value) => _client.leaveRoom(roomID),
    );
  }

  Future<void> dispose() async {
    await _onEventStreamSubscription?.cancel();
  }
}
