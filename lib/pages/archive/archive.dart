/*
 * Modified by akquinet GmbH on 08.04.2024
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/room_extension.dart';
import 'package:flutter/material.dart';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';

import 'package:fluffychat/pages/archive/archive_view.dart';
import 'package:fluffychat/widgets/matrix.dart';

class Archive extends StatefulWidget {
  const Archive({Key? key}) : super(key: key);

  @override
  ArchiveController createState() => ArchiveController();
}

class ArchiveController extends State<Archive> {
  List<Room>? archive;

  Future<List<Room>> getArchive(BuildContext context) async {
    final archive = this.archive;
    if (archive != null) return archive;
    return this.archive = await Matrix.of(context).client.loadArchive();
  }

  void forgetAllAction() async {
    final archive = this.archive;
    if (archive == null) return;
    if (await showOkCancelAlertDialog(
          useRootNavigator: false,
          context: context,
          title: L10n.of(context)!.areYouSure,
          okLabel: L10n.of(context)!.yes,
          cancelLabel: L10n.of(context)!.cancel,
          message: L10n.of(context)!.clearArchive,
        ) !=
        OkCancelResult.ok) {
      return;
    }
    await showFutureLoadingDialog(
      context: context,
      future: () async {
        while (archive.isNotEmpty) {
          Logs().v(
            'Forget room ${archive.last.getLocalizedDisplaynameFromCustomNameEvent(MatrixLocals(L10n.of(context)!))}',
          );
          await archive.last.forget();
          archive.removeLast();
        }
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => ArchiveView(this);
}
