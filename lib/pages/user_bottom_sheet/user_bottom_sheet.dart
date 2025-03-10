/*
 * Modified by akquinet GmbH on 27.02.2025
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:fluffychat/widgets/permission_slider_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

import '../../tim/shared/provider/tim_provider.dart';
import '../../widgets/matrix.dart';
import 'user_bottom_sheet_view.dart';

enum UserBottomSheetAction {
  report,
  mention,
  ban,
  kick,
  unban,
  permission,
  message,
  ignore,
}

class UserBottomSheet extends StatefulWidget {
  final User user;
  final Function? onMention;
  final BuildContext outerContext;

  const UserBottomSheet({
    Key? key,
    required this.user,
    required this.outerContext,
    this.onMention,
  }) : super(key: key);

  @override
  UserBottomSheetController createState() => UserBottomSheetController();
}

class UserBottomSheetController extends State<UserBottomSheet> {
  void participantAction(UserBottomSheetAction action, [Function? onFinish]) async {
    // ignore: prefer_function_declarations_over_variables
    final Function askConfirmation = () async => (await showOkCancelAlertDialog(
          useRootNavigator: false,
          context: context,
          title: L10n.of(context)!.areYouSure,
          okLabel: L10n.of(context)!.yes,
          cancelLabel: L10n.of(context)!.no,
        ) ==
        OkCancelResult.ok);
    switch (action) {
      case UserBottomSheetAction.report:
        final event = widget.user;
        final score = await showConfirmationDialog<int>(
          context: context,
          title: L10n.of(context)!.reportUser,
          message: L10n.of(context)!.howOffensiveIsThisContent,
          cancelLabel: L10n.of(context)!.cancel,
          okLabel: L10n.of(context)!.ok,
          actions: [
            AlertDialogAction(
              key: -100,
              label: L10n.of(context)!.extremeOffensive,
            ),
            AlertDialogAction(
              key: -50,
              label: L10n.of(context)!.offensive,
            ),
            AlertDialogAction(
              key: 0,
              label: L10n.of(context)!.inoffensive,
            ),
          ],
        );
        if (score == null) return;
        final reason = await showTextInputDialog(
          useRootNavigator: false,
          context: context,
          title: L10n.of(context)!.whyDoYouWantToReportThis,
          okLabel: L10n.of(context)!.ok,
          cancelLabel: L10n.of(context)!.cancel,
          textFields: [DialogTextField(hintText: L10n.of(context)!.reason)],
        );
        if (reason == null || reason.single.isEmpty) return;
        final result = await showFutureLoadingDialog(
          context: context,
          future: () => Matrix.of(context).client.reportContent(
                event.room.id,
                event.id,
                reason: reason.single,
                score: score,
              ),
        );
        if (result.error != null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10n.of(context)!.contentHasBeenReported)),
        );
        break;
      case UserBottomSheetAction.mention:
        Navigator.of(context, rootNavigator: false).pop();
        widget.onMention!();
        break;
      case UserBottomSheetAction.ban:
        if (await askConfirmation()) {
          await showFutureLoadingDialog(
            context: context,
            future: () => widget.user.ban(),
          );
          Navigator.of(context, rootNavigator: false).pop();
        }
        break;
      case UserBottomSheetAction.unban:
        if (await askConfirmation()) {
          await showFutureLoadingDialog(
            context: context,
            future: () => widget.user.unban(),
          );
          Navigator.of(context, rootNavigator: false).pop();
        }
        break;
      case UserBottomSheetAction.kick:
        if (await askConfirmation()) {
          await showFutureLoadingDialog(
            context: context,
            future: () => widget.user.kick(),
          );
          Navigator.of(context, rootNavigator: false).pop();
        }
        break;
      case UserBottomSheetAction.permission:
        final newPermission = await showPermissionChooser(
          context,
          currentLevel: widget.user.powerLevel,
        );
        if (newPermission != null) {
          if (newPermission == 100 && await askConfirmation() == false) break;
          await showFutureLoadingDialog(
            context: context,
            future: () => widget.user.setPower(newPermission),
          );
          Navigator.of(context, rootNavigator: false).pop();
        }
        break;
      case UserBottomSheetAction.message:
        final roomIdResult = await showFutureLoadingDialog(
          context: context,
          future: () => TimProvider.of(context).matrix().client().startDirectChatWithCustomRoomType(widget.user.id),
        );
        if (roomIdResult.error != null) return;
        VRouter.of(widget.outerContext).toSegments(['rooms', roomIdResult.result!]);
        Navigator.of(context, rootNavigator: false).pop();
        break;
      case UserBottomSheetAction.ignore:
        if (await askConfirmation()) {
          await showFutureLoadingDialog(
            context: context,
            future: () => Matrix.of(context)
                .client
                .ignoreUser(widget.user.id)
                .then((value) => onFinish?.call()),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) => UserBottomSheetView(this);
}
