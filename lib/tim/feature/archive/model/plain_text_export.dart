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

class RoomPlainTextExport {
  /// Matrix 'roomId'
  final String roomId;

  /// room name as set by a participant
  final String roomName;

  final List<PlainTextMessage> messages;

  RoomPlainTextExport(
      {required this.roomId, required this.roomName, required this.messages,});

  Map<String, dynamic> toJson() =>
      {'roomId': roomId, 'roomName': roomName, 'messages': messages};
}

class PlainTextMessage {
  /// Matrix 'eventId'
  final String eventId;

  /// Matrix 'senderId'
  final String senderId;

  /// Matrix 'originServerTs', which is the send timestamp, formatted using ISO-8601
  final String originServerTs;

  /// plain-text content of the message without formatting
  final String text;

  PlainTextMessage({
    required this.eventId,
    required this.senderId,
    required this.originServerTs,
    required this.text,
  });

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'senderId': senderId,
        'originServerTs': originServerTs,
        'text': text,
      };
}
