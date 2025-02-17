/*
 * TIM-Referenzumgebung
 * Copyright (C) 2025 - akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/utils/matrix_sdk_extensions/room_extension.dart';
import 'package:matrix/matrix.dart';
import 'package:test/test.dart';

import '../../tim/shared/matrix/tim_matrix_client_test.mocks.dart';

void main() {
  group('extractRawMentionsFromEventBody', () {

    test('extracts multiple valid mentions', () {
      const text = "@user4 hello @user3 and @user1";
      final mentions = RoomExtension.extractRawMentionsFromEventBody(text);

      expect(mentions, unorderedEquals(['@user4', '@user3', '@user1']));
    });

    test('ignores mentions with a space after the @ symbol', () {
      const text = "@user4 hello @ user5 and @user3";
      final mentions = RoomExtension.extractRawMentionsFromEventBody(text);
      expect(mentions, equals(['@user4', '@user3']));
    });

    test('returns an empty list when there are no mentions', () {
      const text = "This string has no mentions";
      final mentions = RoomExtension.extractRawMentionsFromEventBody(text);
      expect(mentions, isEmpty);
    });

    test('extracts mention even when punctuation is attached', () {
      const text = "Hello, @user4!";
      final mentions = RoomExtension.extractRawMentionsFromEventBody(text);
      expect(mentions, equals(['@user4']));
    });

    test('extracts mentions at the beginning and end of the string', () {
      const text = "@start middle text @end";
      final mentions = RoomExtension.extractRawMentionsFromEventBody(text);
      expect(mentions, equals(['@start', '@end']));
    });
  });

  group('enrichEventWithMentions', () {
    late Room room;

    final Map<String, Map<String, StrippedStateEvent>> mockRoomStates = {
      EventTypes.RoomMember: {
        // Participant 1
        '@user1:79958930-655d-42be-8ab2-37ae737b249e.ru-dev.timref.akquinet.nx2.dev':
            StrippedStateEvent(
          type: 'm.room.member',
          content: {
            'membership': 'join',
            'displayname': 'user1',
          },
          senderId: '@user1:79958930-655d-42be-8ab2-37ae737b249e.ru-dev.timref.akquinet.nx2.dev',
          stateKey: '@user1:79958930-655d-42be-8ab2-37ae737b249e.ru-dev.timref.akquinet.nx2.dev',
        ),
        // Participant 2
        '@user4:822d07eb-dd53-4ec8-b68f-ef4fd2203cf1.ru-dev.timref.akquinet.nx2.dev':
            StrippedStateEvent(
          type: 'm.room.member',
          content: {
            'membership': 'join',
            'displayname': 'user4',
          },
          senderId: '@user4:822d07eb-dd53-4ec8-b68f-ef4fd2203cf1.ru-dev.timref.akquinet.nx2.dev',
          stateKey: '@user4:822d07eb-dd53-4ec8-b68f-ef4fd2203cf1.ru-dev.timref.akquinet.nx2.dev',
        ),
      },
    };

    setUp(() {
      room = Room(id: 'room123', client: MockClient());
    });
    test('extracts multiple valid mentions', () {
      final event = <String, dynamic>{
        'msgtype': MessageTypes.Text,
        'body': "@user4 hello @user3 and @user1",
        'm.mentions': {},
      };
      room.states = mockRoomStates;

      final enrichedEvent = room.enrichEventWithMentions(event);
      expect(
        enrichedEvent['m.mentions'],
        equals(
          {
            'user_ids': [
              // user3 is not in room, so should not appear in mentions
              '@user4:822d07eb-dd53-4ec8-b68f-ef4fd2203cf1.ru-dev.timref.akquinet.nx2.dev',
              '@user1:79958930-655d-42be-8ab2-37ae737b249e.ru-dev.timref.akquinet.nx2.dev',
            ],
          },
        ),
      );
    });
  });
}
