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

import 'package:fluffychat/tim/feature/automated_invite_rejection/insurer_information_repository.dart';
import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_policy.dart';
import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_policy_repository.dart';
import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_service.dart';
import 'package:fluffychat/tim/feature/tim_version/tim_version_service.dart';
import 'package:fluffychat/tim/shared/matrix/tim_matrix_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:matrix/matrix.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../utils/sync_cached_stream_controller.dart';
@GenerateNiceMocks([
  MockSpec<TimVersionService>(),
  MockSpec<InviteRejectionPolicyRepository>(),
  MockSpec<TimMatrixClient>(),
  MockSpec<InsurerInformationRepository>(),
])
import 'invite_rejection_service_test.mocks.dart';

void main() {
  group("InviteRejectionService", () {
    late MockTimVersionService mockTimVersionService;
    late MockInviteRejectionPolicyRepository mockInviteRejectionPolicyRepository;
    late MockTimMatrixClient mockClient;
    late InviteRejectionService service;
    late SyncCachedStreamController<EventUpdate> eventStream;
    late MockInsurerInformationRepository mockTimInformationRepository;

    setUp(() {
      provideDummy<InviteRejectionPolicy>(AllowAllInvites.blockingNone());
      provideDummy<Option<bool?>>(some(false));
      mockTimVersionService = MockTimVersionService();
      mockInviteRejectionPolicyRepository = MockInviteRejectionPolicyRepository();
      mockTimInformationRepository = MockInsurerInformationRepository();
      mockClient = MockTimMatrixClient();
      service = InviteRejectionService(
          timVersionService: mockTimVersionService,
          inviteRejectionPolicyRepository: mockInviteRejectionPolicyRepository,
          client: mockClient,
          blockDelay: null,
          timInformationRepository: mockTimInformationRepository);

      eventStream = SyncCachedStreamController<EventUpdate>();
      when(mockClient.onEventUpdate).thenReturn(eventStream);
      service.initInviteRejectOnEventStream();
    });

    tearDown(() {
      service.dispose();
    });

    test("should block invites forbidden by policy", () async {
      when(mockTimVersionService.versionFeaturesClientSideInviteRejection())
          .thenAnswer((_) async => true);
      when(mockClient.userID).thenReturn("Maike");
      when(mockTimInformationRepository.doesServerBelongToInsurer(any))
          .thenAnswer((_) async => some(false));
      when(mockInviteRejectionPolicyRepository.getCurrentPolicy())
          .thenAnswer((_) async => BlockAllInvites.allowingNone());

      verifyNever(mockClient.leaveRoom(any));

      eventStream.add(
        EventUpdate(
          type: EventUpdateType.inviteState,
          roomID: 'room id',
          content: {
            'content': {'membership': "invite"},
            'sender': "@user:domain",
            'state_key': "Maike",
            'type': 'm.room.member',
          },
        ),
      );

      await untilCalled(mockClient.leaveRoom('room id'));
    });

    test("should ignore non-invite events", () async {
      eventStream.add(
        EventUpdate(
          type: EventUpdateType.history,
          roomID: 'room id',
          content: {},
        ),
      );

      verifyNever(mockTimVersionService.versionFeaturesClientSideInviteRejection());
      verifyNever(mockClient.leaveRoom(any));
    });

    test("should ignore invites when client-side invite rejection is disabled", () async {
      when(mockTimVersionService.versionFeaturesClientSideInviteRejection())
          .thenAnswer((_) async => false);

      verifyNever(mockTimVersionService.versionFeaturesClientSideInviteRejection());

      eventStream.add(
        EventUpdate(
          type: EventUpdateType.inviteState,
          roomID: 'room id',
          content: {
            'content': {'membership': "invite"},
            'sender': "@user:domain",
            'state_key': "Maike",
            'type': 'm.room.member',
          },
        ),
      );

      await untilCalled(mockTimVersionService.versionFeaturesClientSideInviteRejection());
      verifyNever(mockClient.leaveRoom(any));
    });

    test("should ignore invites for other users", () async {
      when(mockTimVersionService.versionFeaturesClientSideInviteRejection())
          .thenAnswer((_) async => true);
      when(mockClient.userID).thenReturn("Maike");

      verifyNever(mockClient.userID);

      eventStream.add(
        EventUpdate(
          type: EventUpdateType.inviteState,
          roomID: 'room id',
          content: {
            'content': {'membership': "invite"},
            'sender': "@user:domain",
            'state_key': "Oliver",
            'type': 'm.room.member',
          },
        ),
      );

      await untilCalled(mockClient.userID);
      verifyNever(mockClient.leaveRoom(any));
    });
  });

  group("InviteRejectionService - Validation", () {
    test("should recognize a correct invite event", () {
      final result = InviteRejectionService.isCorrectInviteEvent(
        EventUpdate(
          type: EventUpdateType.inviteState,
          roomID: 'room id',
          content: {
            'content': {'membership': "invite"},
            'sender': "@user:domain",
            'state_key': "Maike",
            'type': 'm.room.member',
          },
        ),
        "Maike",
      );

      expect(result, true);
    });

    test("should recognize an invite event for another user", () {
      final result = InviteRejectionService.isCorrectInviteEvent(
        EventUpdate(
          type: EventUpdateType.inviteState,
          roomID: 'room id',
          content: {
            'content': {'membership': "invite"},
            'sender': "@user:domain",
            'state_key': "Maike",
            'type': 'm.room.member',
          },
        ),
        "Maik",
      );

      expect(result, false);
    });

    test("should recognize a non-invite event (membership)", () {
      final result = InviteRejectionService.isCorrectInviteEvent(
        EventUpdate(
          type: EventUpdateType.inviteState,
          roomID: 'room id',
          content: {
            'content': {'membership': "leave"},
            'sender': "@user:domain",
            'state_key': "Maike",
            'type': 'm.room.member',
          },
        ),
        "Maike",
      );

      expect(result, false);
    });

    test("should recognize a non-invite event (type)", () {
      final result = InviteRejectionService.isCorrectInviteEvent(
        EventUpdate(
          type: EventUpdateType.inviteState,
          roomID: 'room id',
          content: {
            'content': {'membership': "invite"},
            'sender': "@user:domain",
            'state_key': "Maike",
            'type': 'cake',
          },
        ),
        "Maike",
      );

      expect(result, false);
    });
  });
}
