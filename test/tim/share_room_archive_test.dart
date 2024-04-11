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

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:fluffychat/tim/feature/archive/model/plain_text_export.dart';
import 'package:fluffychat/tim/feature/archive/share_room_archive.dart';
import 'package:fluffychat/tim/shared/matrix/tim_matrix_client.dart';
import 'package:fluffychat/tim/shared/matrix/tim_matrix_crypto.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/room_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

import 'share_room_archive_test.mocks.dart';
import 'utils/fake_path_provider_platform.dart';
import 'utils/mock_share_platform.dart';
import 'utils/test_factory.dart';

@GenerateMocks([TimMatrixClient, TimMatrixCrypto])
void main() {
  late MockTimMatrixClient clientMock;
  late MockTimMatrixCrypto cryptoMock;

  late MockSharePlatform sharePlatformMock;

  Future<void> subject(matrix.Room room) =>
      shareRoomArchive(client: clientMock, crypto: cryptoMock, room: room, renderBox: null);

  setUp(() {
    // This fakes path provider, e.g. getTempDirectory(), to return real directories under system temp.
    PathProviderPlatform.instance = FakePathProviderPlatform();

    // This mocks Share, e.g. Share.shareFiles(...)
    sharePlatformMock = SharePlatform.instance = MockSharePlatform();
    clientMock = MockTimMatrixClient();
    cryptoMock = MockTimMatrixCrypto();
  });

  void mockRoomEvents(matrix.Room room, List<matrix.MatrixEvent> events) {
    // Let the first call to client.getRoomEvents return the one event and also provide an "end" token to start the next
    // request with.
    when(
      clientMock.getRoomEvents(
        room.id,
        matrix.Direction.f,
        from: null,
        to: null,
        limit: anyNamed("limit"),
        filter: anyNamed("filter"),
      ),
    ).thenAnswer((_) async => matrix.GetRoomEventsResponse(chunk: events, start: "", end: "end"));
    // Let the second call indicates that there is no more data by setting "end" to null.
    when(
      clientMock.getRoomEvents(
        room.id,
        matrix.Direction.f,
        from: "end",
        to: null,
        limit: anyNamed("limit"),
        filter: anyNamed("filter"),
      ),
    ).thenAnswer((_) async => matrix.GetRoomEventsResponse(chunk: [], start: ""));
  }

  void performNoOpOnDecrypt(matrix.Room room) {
    // Return the input event on decrypt call.
    when(cryptoMock.decryptRoomEvent(room.id, any))
        .thenAnswer((invocation) async => invocation.positionalArguments[1]);
  }

  test('a single message event', () async {
    final event = TestFactory.matrixEventTextMessage();
    final room = TestFactory.room();

    mockRoomEvents(room, [event]);
    performNoOpOnDecrypt(room);

    await subject(room);

    // Check the shareFiles(...) call, it should have received the ZIP file with the export.
    final zipFilePath = (verify(
      sharePlatformMock.shareXFiles(
        captureAny,
        subject: anyNamed("subject"),
        text: anyNamed("text"),
        sharePositionOrigin: anyNamed("sharePositionOrigin"),
      ),
    ).captured.single as List<XFile>)
        .first
        .path;

    _expectZipFileToContain(room, zipFilePath, [event]);
  });

  test('multiple message events', () async {
    final events = List.generate(25, (_) => TestFactory.matrixEventTextMessage());
    final room = TestFactory.room();

    mockRoomEvents(room, events);
    performNoOpOnDecrypt(room);

    await subject(room);

    // Check the shareFiles(...) call, it should have received the ZIP file with the export.
    final zipFilePath = (verify(
      sharePlatformMock.shareXFiles(
        captureAny,
        subject: anyNamed("subject"),
        text: anyNamed("text"),
        sharePositionOrigin: anyNamed("sharePositionOrigin"),
      ),
    ).captured.single as List<XFile>)
        .first
        .path;

    _expectZipFileToContain(room, zipFilePath, events);
  });
}

void _expectZipFileToContain(
  matrix.Room room,
  String zipFilePath,
  Iterable<matrix.MatrixEvent> events,
) {
  final plainTextExport = RoomPlainTextExport(
    roomId: room.id,
    roomName: room.displayName,
    messages: events
        .map((e) => matrix.Event.fromMatrixEvent(e, room))
        .map(
          (e) => PlainTextMessage(
            eventId: e.eventId,
            senderId: e.senderId,
            originServerTs: e.originServerTs.toIso8601String(),
            text: e.text,
          ),
        )
        .toList(),
  );

  expect(File(zipFilePath).existsSync(), true);
  final inputStream = InputFileStream(zipFilePath);
  try {
    final zipArchive = ZipDecoder().decodeBuffer(inputStream);
    final messagesJsonFile = zipArchive.files.firstWhere((f) => f.name == "messages.json");
    final String messagesJsonString = utf8.decode(messagesJsonFile.content);
    expect(messagesJsonString, jsonEncode(plainTextExport.toJson()));
  } finally {
    inputStream.close();
  }
}
