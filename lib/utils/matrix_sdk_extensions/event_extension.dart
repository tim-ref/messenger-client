/*
 * Modified by akquinet GmbH on 21.11.2024
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:developer';

import 'package:fluffychat/utils/size_string.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';

import 'matrix_file_extension.dart';

extension LocalizedBody on Event {
  Future<LoadingDialogResult<MatrixFile?>> _getFile(BuildContext context) =>
      showFutureLoadingDialog(
        context: context,
        future: downloadAndDecryptAttachmentWithCorrectName,
      );

  void saveFile(BuildContext context) async {
    final matrixFile = await _getFile(context);

    matrixFile.result?.save(context);
  }

  void shareFile(BuildContext context) async {
    final matrixFile = await _getFile(context);
    inspect(matrixFile);

    matrixFile.result?.share(context);
  }

  bool get isAttachmentSmallEnough =>
      infoMap['size'] is int && infoMap['size'] < room.client.database!.maxFileSize;

  bool get isThumbnailSmallEnough =>
      thumbnailInfoMap['size'] is int &&
      thumbnailInfoMap['size'] < room.client.database!.maxFileSize;

  bool get showThumbnail =>
      [MessageTypes.Image, MessageTypes.Sticker, MessageTypes.Video].contains(messageType) &&
      (kIsWeb || isAttachmentSmallEnough || isThumbnailSmallEnough || (content['url'] is String));

  String? get sizeString =>
      content.tryGetMap<String, dynamic>('info')?.tryGet<int>('size')?.sizeString;

  /// Downloads (and decrypts if necessary) the attachment of this
  /// event and returns it as a [MatrixFile]. If this event doesn't
  /// contain an attachment, this throws an error. Set [getThumbnail] to
  /// true to download the thumbnail instead.
  Future<MatrixFile> downloadAndDecryptAttachmentWithCorrectName(
      {bool getThumbnail = false, Future<Uint8List> Function(Uri)? downloadCallback}) async {
    if (![EventTypes.Message, EventTypes.Sticker].contains(type)) {
      throw ("This event has the type '$type' and so it can't contain an attachment.");
    }
    if (status.isSending) {
      final localFile = room.sendingFilePlaceholders[eventId];
      if (localFile != null) return localFile;
    }
    final database = room.client.database;
    final mxcUrl = attachmentOrThumbnailMxcUrl(getThumbnail: getThumbnail);
    if (mxcUrl == null) {
      throw "This event hasn't any attachment or thumbnail.";
    }
    getThumbnail = mxcUrl != attachmentMxcUrl;
    final isEncrypted = getThumbnail ? isThumbnailEncrypted : isAttachmentEncrypted;
    if (isEncrypted && !room.client.encryptionEnabled) {
      throw ('Encryption is not enabled in your Client.');
    }

    // Is this file storeable?
    final thisInfoMap = getThumbnail ? thumbnailInfoMap : infoMap;
    var storeable = database != null &&
        thisInfoMap['size'] is int &&
        thisInfoMap['size'] <= database.maxFileSize;

    Uint8List? uint8list;
    if (storeable) {
      uint8list = await room.client.database?.getFile(mxcUrl);
    }

    // Download the file
    if (uint8list == null) {
      final httpClient = room.client.httpClient;
      downloadCallback ??= (Uri url) async => (await httpClient.get(url)).bodyBytes;
      uint8list = await downloadCallback(mxcUrl.getDownloadLink(room.client));
      storeable = database != null && storeable && uint8list.lengthInBytes < database.maxFileSize;
      if (storeable) {
        await database.storeFile(mxcUrl, uint8list, DateTime.now().millisecondsSinceEpoch);
      }
    }

    // Decrypt the file
    if (isEncrypted) {
      final fileMap = getThumbnail ? infoMap['thumbnail_file'] : content['file'];
      if (!fileMap['key']['key_ops'].contains('decrypt')) {
        throw ("Missing 'decrypt' in 'key_ops'.");
      }
      final encryptedFile = EncryptedFile(
        data: uint8list,
        iv: fileMap['iv'],
        k: fileMap['key']['k'],
        sha256: fileMap['hashes']['sha256'],
      );
      uint8list = await room.client.nativeImplementations.decryptFile(encryptedFile);
      if (uint8list == null) {
        throw ('Unable to decrypt file');
      }
    }
    return MatrixFile(bytes: uint8list, name: content.tryGet("fileId") ?? body);
  }
}
