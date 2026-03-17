/*
 * TIM-Referenzumgebung
 * Copyright (C) 2026 – akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/pages/chat/chat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'chat_controller_test.mocks.dart';

@GenerateMocks([
  Room,
  Client,
  Event,
])
void main() {
  group('ChatController.canRedactEvents', () {
    const testUser = '@testuser:example.com';

    late MockClient mockClient;
    late MockEvent mockEvent;

    setUp(() {
      mockClient = MockClient();
      mockEvent = MockEvent();
      when(mockClient.userID).thenReturn(testUser);
    });

    test('returns true when event is within 24h', () {
      // given
      final timestamp = DateTime.now().subtract(const Duration(hours: 23));
      when(mockEvent.originServerTs).thenReturn(timestamp);
      when(mockEvent.canRedact).thenReturn(true);
      when(mockEvent.senderId).thenReturn(testUser);

      // when
      final result = ChatController.canRedactEvents(
        selectedEvents: [mockEvent],
        isArchived: false,
        currentBundle: [mockClient],
      );

      // then
      expect(result, true);
    });

    test('returns false when event is exactly 24h old', () {
      // given
      final timestamp = DateTime.now().subtract(const Duration(hours: 24));
      when(mockEvent.originServerTs).thenReturn(timestamp);
      when(mockEvent.canRedact).thenReturn(true);
      when(mockEvent.senderId).thenReturn(testUser);

      // when
      final result = ChatController.canRedactEvents(
        selectedEvents: [mockEvent],
        isArchived: false,
        currentBundle: [mockClient],
      );

      // then
      expect(result, false);
    });

    test('returns false when event is over 24h old', () {
      // given
      final timestamp = DateTime.now().subtract(const Duration(hours: 25));
      when(mockEvent.originServerTs).thenReturn(timestamp);
      when(mockEvent.canRedact).thenReturn(true);
      when(mockEvent.senderId).thenReturn(testUser);

      // when
      final result = ChatController.canRedactEvents(
        selectedEvents: [mockEvent],
        isArchived: false,
        currentBundle: [mockClient],
      );

      // then
      expect(result, false);
    });

    test('returns false for future event', () {
      // given
      final timestamp = DateTime.now().add(const Duration(seconds: 1));
      when(mockEvent.originServerTs).thenReturn(timestamp);
      when(mockEvent.canRedact).thenReturn(true);
      when(mockEvent.senderId).thenReturn(testUser);

      // when
      final result = ChatController.canRedactEvents(
        selectedEvents: [mockEvent],
        isArchived: false,
        currentBundle: [mockClient],
      );

      // then
      expect(result, false);
    });

    test('returns false when room is archived', () {
      // given
      final timestamp = DateTime.now().subtract(const Duration(hours: 23));
      when(mockEvent.originServerTs).thenReturn(timestamp);
      when(mockEvent.canRedact).thenReturn(true);
      when(mockEvent.senderId).thenReturn(testUser);

      // when
      final result = ChatController.canRedactEvents(
        selectedEvents: [mockEvent],
        isArchived: true,
        currentBundle: [mockClient],
      );

      // then
      expect(result, false);
    });

    test('returns true when user cannot redact but is sender', () {
      // given
      final timestamp = DateTime.now().subtract(const Duration(hours: 23));
      when(mockEvent.originServerTs).thenReturn(timestamp);
      when(mockEvent.canRedact).thenReturn(false);
      when(mockEvent.senderId).thenReturn(testUser);

      // when
      final result = ChatController.canRedactEvents(
        selectedEvents: [mockEvent],
        isArchived: false,
        currentBundle: [mockClient],
      );

      // then
      expect(result, true);
    });

    test('returns false when user cannot redact and is not sender', () {
      // given
      final timestamp = DateTime.now().subtract(const Duration(hours: 23));
      when(mockEvent.originServerTs).thenReturn(timestamp);
      when(mockEvent.canRedact).thenReturn(false);
      when(mockEvent.senderId).thenReturn('@otheruser:example.com');

      // when
      final result = ChatController.canRedactEvents(
        selectedEvents: [mockEvent],
        isArchived: false,
        currentBundle: [mockClient],
      );

      // then
      expect(result, false);
    });

    test('returns true when multiple events all within 24h', () {
      // given
      final timestamp1 = DateTime.now().subtract(const Duration(hours: 23));
      final timestamp2 = DateTime.now().subtract(const Duration(hours: 10));
      final mockEvent1 = MockEvent();
      final mockEvent2 = MockEvent();

      when(mockEvent1.originServerTs).thenReturn(timestamp1);
      when(mockEvent1.canRedact).thenReturn(true);
      when(mockEvent1.senderId).thenReturn(testUser);

      when(mockEvent2.originServerTs).thenReturn(timestamp2);
      when(mockEvent2.canRedact).thenReturn(true);
      when(mockEvent2.senderId).thenReturn(testUser);

      // when
      final result = ChatController.canRedactEvents(
        selectedEvents: [mockEvent1, mockEvent2],
        isArchived: false,
        currentBundle: [mockClient],
      );

      // then
      expect(result, true);
    });

    test('returns false when multiple events with one over 24h old', () {
      // given
      final timestamp1 = DateTime.now().subtract(const Duration(hours: 23));
      final timestamp2 = DateTime.now().subtract(const Duration(hours: 25));
      final mockEvent1 = MockEvent();
      final mockEvent2 = MockEvent();

      when(mockEvent1.originServerTs).thenReturn(timestamp1);
      when(mockEvent1.canRedact).thenReturn(true);
      when(mockEvent1.senderId).thenReturn(testUser);

      when(mockEvent2.originServerTs).thenReturn(timestamp2);
      when(mockEvent2.canRedact).thenReturn(true);
      when(mockEvent2.senderId).thenReturn(testUser);

      // when
      final result = ChatController.canRedactEvents(
        selectedEvents: [mockEvent1, mockEvent2],
        isArchived: false,
        currentBundle: [mockClient],
      );

      // then
      expect(result, false);
    });

    test('returns true when empty selected events', () {
      // given
      // (no events)

      // when
      final result = ChatController.canRedactEvents(
        selectedEvents: [],
        isArchived: false,
        currentBundle: [mockClient],
      );

      // then
      expect(result, true);
    });
  });
}
