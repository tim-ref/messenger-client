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

import 'package:fluffychat/utils/data_preperation_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../tim/share_room_archive_test.mocks.dart';
import '../tim/shared/matrix/tim_matrix_client_test.mocks.dart';
import '../tim/utils/test_factory.dart';

@GenerateNiceMocks([MockSpec<GetRelatingEventsResponse>()])
void main() {
  late MockClient clientMock;
  late MockTimMatrixCrypto cryptoMock;

  setUp(() {
    clientMock = MockClient();
    cryptoMock = MockTimMatrixCrypto();
  });

  test('fetchRelatedEvents returns decoded events', () async {
    const eventId = '1234';
    final matrixEvent = TestFactory.matrixEventTextMessage(eventId: eventId);
    final relEvents = TestFactory.relatedEvents(chunk: [matrixEvent]);
    final room = TestFactory.room();
    final event = Event.fromMatrixEvent(matrixEvent, room);

    when(clientMock.getRelatingEventsWithRelType(any, any, any)).thenAnswer((_) async => relEvents);
    when(cryptoMock.decryptRoomEvent(any, any)).thenAnswer((_) async => event);

    final result = await fetchRelatedEvents(
      clientMock,
      cryptoMock,
      room,
      eventId,
      RelationshipType.edit,
    );

    expect(
        verify(clientMock.getRelatingEventsWithRelType(captureAny, captureAny, captureAny))
            .captured,
        [room.id, eventId, RelationshipTypes.edit]);
    verify(cryptoMock.decryptRoomEvent(any, any)).called(1);
    expect(result, equals([event]));
  });
}
