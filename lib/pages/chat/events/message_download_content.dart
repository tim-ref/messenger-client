/*
 * Modified by akquinet GmbH on 08.07.2024
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:fluffychat/utils/matrix_sdk_extensions/event_extension.dart';

class MessageDownloadContent extends StatelessWidget {
  final Event event;
  final Color textColor;

  const MessageDownloadContent(this.event, this.textColor, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    final filename = event.content.tryGet<String>('filename') ?? event.body;
    final mimetype = event.content
        .tryGetMap<String, dynamic>('info')
        ?.tryGet<String>('mimetype')
        ?.toUpperCase();
    final fileExtension = filename.contains('.') ? filename.split('.').last.toUpperCase() : 'UNKNOWN';
    final filetype =  mimetype ?? fileExtension;
    final sizeString = event.sizeString;
    return InkWell(
      onTap: () => event.saveFile(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.file_download_outlined,
                  color: textColor,
                ),
                const SizedBox(width: 16),
                Text(
                  filename,
                  maxLines: 1,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Text(
                  filetype,
                  style: TextStyle(
                    color: textColor.withAlpha(150),
                  ),
                ),
                const Spacer(),
                if (sizeString != null)
                  Text(
                    sizeString,
                    style: TextStyle(
                      color: textColor.withAlpha(150),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
