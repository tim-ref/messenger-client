/*
 * Modified by akquinet GmbH on 16.10.2023
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:keyboard_shortcuts/keyboard_shortcuts.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

import 'package:fluffychat/tim/shared/provider/tim_provider.dart';
import 'package:fluffychat/tim/feature/archive/share_room_archive.dart';
import 'matrix.dart';

class ChatSettingsPopupMenu extends StatefulWidget {
  final Room room;
  final bool displayChatDetails;

  const ChatSettingsPopupMenu(this.room, this.displayChatDetails, {Key? key})
      : super(key: key);

  @override
  ChatSettingsPopupMenuState createState() => ChatSettingsPopupMenuState();
}

class ChatSettingsPopupMenuState extends State<ChatSettingsPopupMenu> {
  StreamSubscription? notificationChangeSub;

  @override
  void dispose() {
    notificationChangeSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    notificationChangeSub ??= Matrix.of(context)
        .client
        .onAccountData
        .stream
        .where((u) => u.type == 'm.push_rules')
        .listen(
          (u) => setState(() {}),
        );
    final items = <PopupMenuEntry<String>>[
      widget.room.pushRuleState == PushRuleState.notify
          ? PopupMenuItem<String>(
              value: 'mute',
              child: Row(
                children: [
                  const Icon(Icons.notifications_off_outlined),
                  const SizedBox(width: 12),
                  Text(L10n.of(context)!.muteChat),
                ],
              ),
            )
          : PopupMenuItem<String>(
              value: 'unmute',
              child: Row(
                children: [
                  const Icon(Icons.notifications_on_outlined),
                  const SizedBox(width: 12),
                  Text(L10n.of(context)!.unmuteChat),
                ],
              ),
            ),
      PopupMenuItem<String>(
        value: 'archive',
        child: Row(
          children: [
            const Icon(Icons.archive),
            const SizedBox(width: 12),
            Text(L10n.of(context)!.archive),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'leave',
        key: const ValueKey("leaveChatButton"),
        child: Row(
          children: [
            const Icon(Icons.delete_outlined),
            const SizedBox(width: 12),
            Text(L10n.of(context)!.leave),
          ],
        ),
      ),
    ];
    if (widget.displayChatDetails) {
      items.insert(
        0,
        PopupMenuItem<String>(
          value: 'details',
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded),
              const SizedBox(width: 12),
              Text(L10n.of(context)!.chatDetails),
            ],
          ),
        ),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        KeyBoardShortcuts(
          keysToPress: {
            LogicalKeyboardKey.controlLeft,
            LogicalKeyboardKey.keyI
          },
          helpLabel: L10n.of(context)!.chatDetails,
          onKeysPressed: _showChatDetails,
          child: const SizedBox.shrink(),
        ),
        PopupMenuButton(
          key: const ValueKey("roomActionPopupMenu"),
          onSelected: (String choice) async {
            switch (choice) {
              case 'leave':
                final confirmed = await showOkCancelAlertDialog(
                  useRootNavigator: false,
                  context: context,
                  title: L10n.of(context)!.areYouSure,
                  okLabel: L10n.of(context)!.ok,
                  cancelLabel: L10n.of(context)!.cancel,
                );
                if (confirmed == OkCancelResult.ok) {
                  final success = await showFutureLoadingDialog(
                    context: context,
                    future: () => widget.room.leave(),
                  );
                  if (success.error == null) {
                    VRouter.of(context).to('/rooms');
                  }
                }
                break;
              case 'mute':
                await showFutureLoadingDialog(
                  context: context,
                  future: () =>
                      widget.room.setPushRuleState(PushRuleState.mentionsOnly),
                );
                break;
              case 'unmute':
                await showFutureLoadingDialog(
                  context: context,
                  future: () =>
                      widget.room.setPushRuleState(PushRuleState.notify),
                );
                break;
              case 'details':
                _showChatDetails();
                break;
              case 'archive':
                final tim = TimProvider.of(context);
                final result = await showFutureLoadingDialog(
                  context: context,
                  future: () => shareRoomArchive(
                    client: tim.matrix().client(),
                    crypto: tim.matrix().crypto(),
                    room: widget.room,
                    renderBox: context.findRenderObject() as RenderBox?,
                  ),
                );
                if (result.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(L10n.of(context)!.chatSettingsArchiveDownloadError)));
                }
                break;
            }
          },
          itemBuilder: (BuildContext context) => items,
        ),
      ],
    );
  }

  void _showChatDetails() {
    if (VRouter.of(context).path.endsWith('/details')) {
      VRouter.of(context).toSegments(['rooms', widget.room.id]);
    } else {
      VRouter.of(context).toSegments(['rooms', widget.room.id, 'details']);
    }
  }
}
