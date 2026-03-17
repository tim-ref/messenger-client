/*
 * TIM-Referenzumgebung
 * Copyright (C) 2026 - akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/tim/shared/matrix/tim_matrix_crypto.dart';
import 'package:matrix/matrix.dart';

enum RelationshipType { reply, edit, reaction, thread }

extension RelationshipTypeX on RelationshipType {
  String get value => switch (this) {
        RelationshipType.reply => RelationshipTypes.reply,
        RelationshipType.edit => RelationshipTypes.edit,
        RelationshipType.reaction => RelationshipTypes.reaction,
        RelationshipType.thread => RelationshipTypes.thread,
      };
}

Future<List<Event>> fetchRelatedEvents(
  Client client,
  TimMatrixCrypto timCrypto,
  Room room,
  String eventId,
  RelationshipType relType, {
  bool includeParentEvent = false,
}) async {
  final relatingEvents =
      await client.getRelatingEventsWithRelType(room.id, eventId, relType.value);

  final List<Event> decryptedEvents = [];

  for (int i = 0; i < relatingEvents.chunk.length; i++) {
    final event = Event.fromMatrixEvent(relatingEvents.chunk[i], room);
    final decryptedEvent = await timCrypto.decryptRoomEvent(
          room.id,
          event,
        );
    decryptedEvents.add(decryptedEvent);
  }

  if (includeParentEvent) {
    final initialEventId =
        decryptedEvents.firstOrNull?.content.tryGetMap("m.relates_to")?["event_id"] as String?;
    if (initialEventId != null) {
      final initialEvent = await client.getOneRoomEvent(room.id, initialEventId);
      final initialDecryptedEvent =
          await timCrypto.decryptRoomEvent(
                room.id,
                Event.fromMatrixEvent(initialEvent, room),
              );

      decryptedEvents.add(initialDecryptedEvent);
    }
  }
  return decryptedEvents;
}
