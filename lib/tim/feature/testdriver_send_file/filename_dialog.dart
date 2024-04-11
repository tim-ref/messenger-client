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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:matrix/matrix.dart';

import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_file_extension.dart';

class FilenameDialog extends StatefulWidget {
  final Room room;

  const FilenameDialog({
    required this.room,
    Key? key,
  }) : super(key: key);

  @override
  FilenameDialogState createState() => FilenameDialogState();
}

class FilenameDialogState extends State<FilenameDialog> {
  TextEditingController? _matrixFilenameTextEditingController;
  TextEditingController? _absolutePathTextEditingController;

  @override
  void initState() {
    _matrixFilenameTextEditingController = TextEditingController();
    _absolutePathTextEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _matrixFilenameTextEditingController?.dispose();
    _absolutePathTextEditingController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget contentWidget() => Column(
          children: [
            TextField(
              controller: _matrixFilenameTextEditingController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'matrix filename',
              ),
              key: const ValueKey("matrixFilenameTextfield"),
            ),
            TextField(
              controller: _absolutePathTextEditingController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'absolute path',
              ),
              key: const ValueKey("absolutePathTextfield"),
            ),
          ],
        );

    return AlertDialog(
      title: Text(L10n.of(context)!.sendFileTest),
      content: contentWidget(),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: false).pop();
          },
          child: Text(L10n.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () => _send(),
          key: const ValueKey("filenameDialogOKButton"),
          child: Text(L10n.of(context)!.send),
        ),
      ],
    );
  }

  Future<void> _send() async {
    final String filepath = _absolutePathTextEditingController!.text;
    final String matrixFilename = _matrixFilenameTextEditingController!.text;
    final File file = File(filepath);
    try {
      if (await _requestFilePermission()) {
        final fileName = filepath.substring(filepath.lastIndexOf("/") + 1);
        final fileId = fileName.substring(0, fileName.indexOf("."));
        final fileExtension = matrixFilename.substring(matrixFilename.indexOf(".") + 1);
        final matrixFile = MatrixFile(
          bytes: file.readAsBytesSync(),
          name: "$fileId.$fileExtension",
        ).detectFileType;
        widget.room.sendFileEvent(matrixFile, extraContent: {
          "fileId": fileId,
          "fileName": matrixFilename,
        },);
      } else {
        throw Exception("No permission to send matrix file $matrixFilename");
      }
      Navigator.of(context, rootNavigator: false).pop();
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.of(context)!.filenameDialogSendFileError)),
      );
      Logs().e("Unable to send matrix file!", e);
    }
  }

  /// Request the files permission and updates the UI accordingly.
  Future<bool> _requestFilePermission() async {
    PermissionStatus result;
    // In Android we need to request the storage permission,
    // while in iOS it is the photos permission.
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt > 29) {
        result = await Permission.manageExternalStorage.request();
      } else {
        result = await Permission.storage.request();
      }
    } else {
      result = await Permission.photos.request();
    }
    return result.isGranted;
  }
}
