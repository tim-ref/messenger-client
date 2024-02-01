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
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart' as matrix;
import 'package:path_provider/path_provider.dart';
import 'package:retry/retry.dart';
import 'package:share_plus/share_plus.dart';

import 'package:fluffychat/tim/feature/archive/model/plain_text_export.dart';
import 'package:fluffychat/tim/shared/matrix/tim_matrix_client.dart';
import 'package:fluffychat/tim/shared/matrix/tim_matrix_crypto.dart';

/// Maximum number of message events to fetch with one request.
/// This does not include binary data, which is fetched separately.
const _eventBatchSize = 1000;

/// Maximum number of parallel binary data requests for attachments.
const _attachmentDownloadBatchSize = 1;

/// Maximum attempts to perform an HTTP request.
const _httpMaxAttempts = 5;

/// Create a ZIP archive from the given room, then share the archive using the platform's share method.
/// This will usually open a dialog for the user to choose an app to handle the archive file, e.g. an email app to send
/// the file as an attachment.
///
/// The ZIP file has the following contents:
/// - A JSON file "messages.json" with the structure of [RoomPlainTextExport].
/// - All attachments as binary files.
///
/// The returned Future resolves once all downloads are complete and the ZIP file was created successfully.
/// It does **not** wait for the result of the dialog where the user chooses an app.
///
/// On network error, the operation is retried a number of times. On recurring problems, the returned Future fails with
/// [http.ClientException].
///
/// This operation is currently not parallelizable: It shows a user dialog, and it uses the same directory to accumulate
/// files to avoid filling up space.
///
/// A RenderBox is required to be passed on iPads, see
/// [https://github.com/fluttercommunity/plus_plugins/tree/main/packages/share_plus/share_plus#ipad]
Future<void> shareRoomArchive({
  required TimMatrixClient client,
  required TimMatrixCrypto crypto,
  required matrix.Room room,
  required RenderBox? renderBox,
}) async {
  final zipFile = await _exportRoomToZipFile(client, crypto, room);
  await _shareFile(room.name, zipFile, renderBox);
}

Future<File> _exportRoomToZipFile(
  TimMatrixClient client,
  TimMatrixCrypto crypto,
  matrix.Room room,
) async {
  final tempDir = await recreateTempDir();

  final messages = await _fetchRoomMessages(client, crypto, room);
  final messagesJsonFile = File("${tempDir.path}/messages.json");
  await messagesJsonFile.writeAsString(
      jsonEncode(_roomMessagesToExport(room, messages).toJson()));

  final zipFile = File("${tempDir.path}/tim-archive_${room.name}.zip");
  final zip = ZipFileEncoder();
  try {
    zip.create(zipFile.path);
    await zip.addFile(messagesJsonFile);
    for (final attachmentFile in await fetchAttachments(tempDir, messages)) {
      await zip.addFile(attachmentFile);
    }
  } finally {
    zip.close();
  }

  return zipFile;
}

Future<Directory> recreateTempDir() async {
  final tempDir = Directory("${(await getTemporaryDirectory()).path}/export");
  if (await tempDir.exists()) await tempDir.delete(recursive: true);

  await tempDir.create(recursive: true);
  return tempDir;
}

Future<Iterable<matrix.Event>> _fetchRoomMessages(
    TimMatrixClient client, TimMatrixCrypto crypto, matrix.Room room) async {
  final List<matrix.Event> result = [];
  matrix.GetRoomEventsResponse page;
  String? pageToken;

  // room.getTimeline() would be easier, but it cannot fetch *all* content because it requires a limit parameter.
  // We therefore use Matrix Client to fetch the messages, which does not automatically decrypt messages. We have to do
  // that using the Client crypto API.
  Future<matrix.GetRoomEventsResponse> fetchRoomEvents() => _withRetry(
        () => client.getRoomEvents(
          room.id, matrix.Direction.f, from: pageToken,
          limit: _eventBatchSize,
          // we are only interested in messages and encrypted messages, not status events like room join or similar
          filter:
              """{ "types": ["${matrix.EventTypes.Message}","${matrix.EventTypes.Encrypted}"] }""",
        ),
      );

  while ((page = await fetchRoomEvents()).end != null) {
    result.addAll(
      await Future.wait(
        // A decryption attempt returns the original event on any failure, which we'd then filter at the end.
        page.chunk.map((e) => crypto.decryptRoomEvent(
            room.id, matrix.Event.fromMatrixEvent(e, room))),
      ),
    );
    pageToken = page.end;
  }

  // Successful decryption changes the type to 'EventTypes.Message', we remove anything else.
  return result.where((e) => e.type == matrix.EventTypes.Message);
}

RoomPlainTextExport _roomMessagesToExport(
        matrix.Room room, Iterable<matrix.Event> messages) =>
    RoomPlainTextExport(
        roomId: room.id,
        roomName: room.name,
        messages: messages
            .map((m) => PlainTextMessage(
                  eventId: m.eventId,
                  senderId: m.senderId,
                  originServerTs: m.originServerTs.toIso8601String(),
                  text: m.text,
                ))
            .toList());

Future<Iterable<File>> fetchAttachments(
    Directory tempDir, Iterable<matrix.Event> messages) async {
  final List<File> results = [];

  final attachmentBatch = messages
      .where((e) => e.hasAttachment)
      .slices(_attachmentDownloadBatchSize);
  for (final attachments in attachmentBatch) {
    final matrixFiles = await Future.wait(attachments
        .map((e) => _withRetry(() => e.downloadAndDecryptAttachment())));
    for (final matrixFile in matrixFiles) {
      final file = await _uniqueNewFile("${tempDir.path}/${matrixFile.name}");
      await file.writeAsBytes(matrixFile.bytes);
      results.add(file);
    }
  }

  return results;
}

Future<T> _withRetry<T>(FutureOr<T> Function() fn) => retry(
      fn,
      retryIf: (e) =>
          e is http.ClientException, // all HTTP requests should fail with this
      maxAttempts: _httpMaxAttempts,
    );

/// Given a path to a file, return a new [File] that is guaranteed to not exist, by adding a number suffix before the
/// file extension (or, if no extension, at the end of the file name). This is useful to avoid name collison.
///
/// Examples:
/// - non-existing "path/to/image.jpg"  =>  File "path/to/image.jpg"
/// - existing "path/to/image.jpg"      =>  File "path/to/image (2).jpg"
/// - existing "path/to/image.jpg"
///        and "path/to/image (2).jpg"  =>  File "path/to/image (3).jpg"
Future<File> _uniqueNewFile(String filePath) async {
  File file;
  final extMatch = _fileExtensionRegex.firstMatch(filePath);
  var nextPath = filePath;
  var nextNumber = 2;
  while (await (file = File(nextPath)).exists()) {
    nextPath = extMatch != null
        ? filePath.replaceRange(extMatch.start, extMatch.end,
            " (${nextNumber++})${extMatch.group(0)}")
        : "$filePath (${nextNumber++})";
  }
  return file;
}

/// matches e.g. ".jpg" in "/path/to/image.jpg"
final _fileExtensionRegex = RegExp(r"\.[^/.]+$");

Future<void> _shareFile(String subject, File file, RenderBox? renderBox) =>
// using "*/*" will open a very generic share dialog where, in theory,
// any app that can receive a file is applicable
    Share.shareXFiles([XFile(file.path, mimeType: "*/*")],
        subject: subject,
        // compare: https://github.com/fluttercommunity/plus_plugins/tree/main/packages/share_plus/share_plus#ipad
        sharePositionOrigin:
            renderBox == null ? null : renderBox.localToGlobal(Offset.zero) & renderBox.size);
