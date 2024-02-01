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

import 'dart:typed_data';

import 'package:matrix/matrix.dart';

/// Factory to create working test objects.
/// This is a best effort:
/// - Some involved types are difficult to create test objects for, e.g. Room with 130+ members.
/// - These implementations may be brittle regarding changes to involved types.
abstract class TestFactory {
  static var _num = 1;

  static Client client({String? name}) => Client(name ?? "client${_num++}");

  static Room room({String? id, String? name, Client? client}) {
    final result = Room(
        id: id ?? "roomId${_num++}", client: client ?? TestFactory.client());
    // A room name is derived from a room name event, which we add here.
    result.states[EventTypes.RoomName] = {
      "": Event.fromMatrixEvent(matrixEventRoomName(name: name), result)
    };
    return result;
  }

  static MatrixEvent matrixEventTextMessage(
          {String? body,
          String? senderId,
          String? eventId,
          DateTime? originServerTs}) =>
      matrixEvent(
        type: EventTypes.Message,
        content: {
          "body": body ?? "test message ${_num++}",
          "msgtype": "m.text"
        },
        senderId: senderId,
        eventId: eventId,
        originServerTs: originServerTs,
      );

  static MatrixEvent matrixEventMessageWithAttachment(
          {required String url,
          String? body,
          String? senderId,
          String? eventId,
          DateTime? originServerTs}) =>
      matrixEvent(
        type: EventTypes.Message,
        content: {
          "body": body ?? "test message ${_num++}",
          "msgtype": "m.text",
          "url": url
        },
        senderId: senderId,
        eventId: eventId,
        originServerTs: originServerTs,
      );

  static MatrixEvent matrixEventRoomName(
          {String? name,
          String? senderId,
          String? eventId,
          DateTime? originServerTs}) =>
      matrixEvent(
        type: EventTypes.RoomName,
        content: {"name": name ?? "roomName${_num++}"},
        senderId: senderId,
        eventId: eventId,
        originServerTs: originServerTs,
      );

  static MatrixEvent matrixEvent({
    required String type,
    required Map<String, dynamic> content,
    String? senderId,
    String? eventId,
    DateTime? originServerTs,
  }) =>
      MatrixEvent(
        type: type,
        content: content,
        senderId: senderId ?? "senderId${_num++}",
        eventId: eventId ?? "eventId${_num++}",
        originServerTs: originServerTs ?? DateTime.now(),
      );

  static Event event({
    required String type,
    required Map<String, dynamic> content,
    String? senderId,
    String? eventId,
    DateTime? originServerTs,
    Room? room,
  }) =>
      Event.fromMatrixEvent(
        matrixEvent(
            type: type,
            content: content,
            senderId: senderId,
            eventId: eventId,
            originServerTs: originServerTs),
        room ?? TestFactory.room(),
      );

  static MatrixFile matrixFile({Uint8List? bytes, String? name}) =>
      MatrixFile(bytes: bytes ?? Uint8List(0), name: "matrixFileName${_num++}");
}
