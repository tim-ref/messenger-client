/*
 * Modified by akquinet GmbH on 2025-04-03
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

  String? get sizeString =>
      content.tryGetMap<String, dynamic>('info')?.tryGet<int>('size')?.sizeString;

  /// Downloads (and decrypts if necessary) the attachment of this
  /// event and returns it as a [MatrixFile]. If this event doesn't
  /// contain an attachment, this throws an error. Set [getThumbnail] to
  /// true to download the thumbnail instead. Set [fromLocalStoreOnly] to true
  /// if you want to retrieve the attachment from the local store only without
  /// making http request.
  Future<MatrixFile> downloadAndDecryptAttachmentWithCorrectName({
    bool getThumbnail = false,
    Future<Uint8List> Function(Uri)? downloadCallback,
    bool fromLocalStoreOnly = false,
  }) async {
    final file = await downloadAndDecryptAttachment(
      getThumbnail: getThumbnail,
      downloadCallback: downloadCallback,
      fromLocalStoreOnly: fromLocalStoreOnly,
    );
    final fileId = content.tryGet<String>("fileId");
    return MatrixFile(bytes: file.bytes, name: fileId ?? file.name);
  }
}
