/*
 * TIM-Referenzumgebung
 * Copyright (C) 2026 akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/pages/chat/event_info_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';

import '../tim/utils/test_factory.dart';
import '../utils/prepare_app_test_with_matrix_client.dart';
import '../utils/test_client.dart';

void main() {
  late Client testClient;

  setUp(() async {
    testClient = await prepareTestClient();
  });

  Event makeEvent({Map<String, Object?>? unsigned}) {
    const senderId = '@alice:example.com';
    final room = TestFactory.room(client: testClient);
    // Pre-populate sender membership so UserAvatar finds the user in memory
    // without triggering an async network fetch (which leaves pending timers).
    room.states[EventTypes.RoomMember] = {
      senderId: Event.fromMatrixEvent(
        MatrixEvent(
          type: EventTypes.RoomMember,
          stateKey: senderId,
          content: {'membership': 'join', 'displayname': 'Alice'},
          senderId: senderId,
          eventId: '\$member-event',
          originServerTs: DateTime.now(),
        ),
        room,
      ),
    };
    return Event.fromMatrixEvent(
      MatrixEvent(
        type: EventTypes.Message,
        content: {'msgtype': 'm.text', 'body': 'test'},
        senderId: senderId,
        eventId: '\$test-event-id',
        originServerTs: DateTime.now(),
        unsigned: unsigned,
      ),
      room,
    );
  }

  Widget dialogFor(Event event) => Builder(
        builder: (context) => EventInfoDialog(l10n: L10n.of(context)!, event: event),
      );

  group('EventInfoDialog redactedTime tile', () {
    testWidgets('hidden when event has no unsigned', (tester) async {
      await prepareAppTestWithMatrixClient(
        child: dialogFor(makeEvent()),
        tester: tester,
        client: testClient,
      );
      expect(find.text('Redacted at'), findsNothing);
    });

    testWidgets('hidden when unsigned has no redacted_because', (tester) async {
      await prepareAppTestWithMatrixClient(
        child: dialogFor(makeEvent(unsigned: {'some_key': 'value'})),
        tester: tester,
        client: testClient,
      );
      expect(find.text('Redacted at'), findsNothing);
    });

    testWidgets('hidden when redacted_because has no origin_server_ts', (tester) async {
      await prepareAppTestWithMatrixClient(
        child: dialogFor(makeEvent(unsigned: {
          'redacted_because': {'event_id': '\$redact-event'},
        })),
        tester: tester,
        client: testClient,
      );
      expect(find.text('Redacted at'), findsNothing);
    });

    testWidgets('hidden when origin_server_ts is null', (tester) async {
      await prepareAppTestWithMatrixClient(
        child: dialogFor(makeEvent(unsigned: {
          'redacted_because': {'origin_server_ts': null},
        })),
        tester: tester,
        client: testClient,
      );
      expect(find.text('Redacted at'), findsNothing);
    });

    testWidgets('shown when origin_server_ts is a valid int', (tester) async {
      final ts = DateTime(2024, 6, 1, 12, 0, 0).millisecondsSinceEpoch;
      await prepareAppTestWithMatrixClient(
        child: dialogFor(makeEvent(unsigned: {
          'redacted_because': {'origin_server_ts': ts},
        })),
        tester: tester,
        client: testClient,
      );
      expect(find.text('Redacted at'), findsOneWidget);
    });

    testWidgets('hidden when origin_server_ts is zero', (tester) async {
      await prepareAppTestWithMatrixClient(
        child: dialogFor(makeEvent(unsigned: {
          'redacted_because': {'origin_server_ts': 0},
        })),
        tester: tester,
        client: testClient,
      );
      expect(find.text('Redacted at'), findsNothing);
    });
  });
}
