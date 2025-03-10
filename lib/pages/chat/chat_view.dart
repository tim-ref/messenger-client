/*
 * Modified by akquinet GmbH on 26.02.2025
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';

import 'package:badges/badges.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pages/chat/chat_app_bar_title.dart';
import 'package:fluffychat/pages/chat/chat_event_list.dart';
import 'package:fluffychat/pages/chat/encryption_button.dart';
import 'package:fluffychat/pages/chat/pinned_events.dart';
import 'package:fluffychat/pages/chat/reactions_picker.dart';
import 'package:fluffychat/pages/chat/reply_display.dart';
import 'package:fluffychat/pages/chat/tombstone_display.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/room_extension.dart';
import 'package:fluffychat/widgets/chat_settings_popup_menu.dart';
import 'package:fluffychat/widgets/connection_status_header.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:fluffychat/widgets/unread_rooms_badge.dart';
import '../../utils/stream_extension.dart';
import '../../tim/feature/chat/case_reference_popup_widget.dart';
import 'chat_emoji_picker.dart';
import 'chat_input_row.dart';
import 'revision_history_display.dart';

enum _EventContextAction { info, report }

class ChatView extends StatelessWidget {
  final ChatController controller;

  const ChatView(this.controller, {Key? key}) : super(key: key);

  List<Widget> _appBarActions(BuildContext context) {
    if (controller.selectMode) {
      return [
        IconButton(
          icon: const Icon(Icons.copy_outlined),
          tooltip: L10n.of(context)!.copy,
          onPressed: controller.copyEventsAction,
        ),
        if (controller.canSaveSelectedEvent)
          // Use builder context to correctly position the share dialog on iPad
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.adaptive.share),
              tooltip: L10n.of(context)!.share,
              onPressed: () => controller.saveSelectedEvent(context),
            ),
          ),
        if (controller.canRedactSelectedEvents)
          IconButton(
            icon: const Icon(Icons.delete_outlined),
            tooltip: L10n.of(context)!.redactMessage,
            onPressed: controller.redactEventsAction,
            key: const ValueKey("redactEventButton"),
          ),
        IconButton(
          icon: const Icon(Icons.push_pin_outlined),
          onPressed: controller.pinEvent,
          tooltip: L10n.of(context)!.pinMessage,
        ),
        // can only edit own messages and 1 at a time
        if (controller.selectedEvents.length == 1 &&
            controller.selectedEvents.first.senderId == controller.matrixClient.userID)
          IconButton(onPressed: controller.editAction, icon: const Icon(Icons.edit)),
        if (controller.selectedEvents.length == 1)
          PopupMenuButton<_EventContextAction>(
            onSelected: (action) {
              switch (action) {
                case _EventContextAction.info:
                  controller.showEventInfo();
                  controller.clearSelectedEvents();
                  break;
                case _EventContextAction.report:
                  controller.reportEventAction();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _EventContextAction.info,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outlined),
                    const SizedBox(width: 12),
                    Text(L10n.of(context)!.messageInfo),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _EventContextAction.report,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Text(L10n.of(context)!.reportMessage),
                  ],
                ),
              ),
            ],
          ),
      ];
    } else if (controller.isArchived) {
      return [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton.icon(
            onPressed: controller.forgetRoom,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            icon: const Icon(Icons.delete_forever_outlined),
            label: Text(L10n.of(context)!.delete),
          ),
        ),
      ];
    } else {
      return [
        if (Matrix.of(context).voipPlugin != null &&
            controller.room.isDirectChatWithTwoOrLessParticipants)
          IconButton(
            onPressed: controller.onPhoneButtonTap,
            icon: const Icon(Icons.call_outlined),
            tooltip: L10n.of(context)!.placeCall,
          ),
        EncryptionButton(controller.room),
        if (controller.timCaseReferenceContent.isNotEmpty)
          CaseReferencePopupWidget(caseReference: controller.timCaseReferenceContent),
        Semantics(
          label: "roomPopupMenu",
          container: true,
          child: ChatSettingsPopupMenu(
            controller.room,
            true,
          ),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller.room.membership == Membership.invite) {
      showFutureLoadingDialog(
        context: context,
        future: () => controller.room.join(),
      );
    }
    final bottomSheetPadding = FluffyThemes.isColumnMode(context) ? 16.0 : 8.0;
    final colorScheme = Theme.of(context).colorScheme;

    return VWidgetGuard(
      onSystemPop: (redirector) async {
        if (controller.selectedEvents.isNotEmpty) {
          controller.clearSelectedEvents();
          redirector.stopRedirection();
        } else if (controller.showEmojiPicker) {
          controller.emojiPickerAction();
          redirector.stopRedirection();
        }
      },
      child: GestureDetector(
        onTapDown: (_) => controller.setReadMarker(),
        behavior: HitTestBehavior.opaque,
        child: StreamBuilder(
          stream: controller.room.onUpdate.stream.rateLimit(const Duration(seconds: 1)),
          builder: (context, snapshot) => FutureBuilder(
            future: controller.loadTimelineFuture,
            builder: (BuildContext context, snapshot) {
              return Scaffold(
                appBar: AppBar(
                  elevation: 3,
                  actionsIconTheme: IconThemeData(
                    color: controller.selectedEvents.isEmpty
                        ? null
                        : Theme.of(context).colorScheme.primary,
                  ),
                  leading: controller.selectMode
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: controller.clearSelectedEvents,
                          tooltip: L10n.of(context)!.close,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : UnreadRoomsBadge(
                          filter: (r) => r.id != controller.roomId,
                          badgePosition: BadgePosition.topEnd(end: 8, top: 4),
                          child: Semantics(
                            label: "backButton",
                            container: true,
                            child: const Center(child: BackButton()),
                          ),
                        ),
                  titleSpacing: 0,
                  title: ChatAppBarTitle(controller),
                  actions: _appBarActions(context),
                ),
                floatingActionButton:
                    controller.showScrollDownButton && controller.selectedEvents.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 56.0),
                            child: FloatingActionButton(
                              onPressed: controller.scrollDown,
                              mini: true,
                              child: const Icon(Icons.arrow_downward_outlined),
                            ),
                          )
                        : null,
                body: DropTarget(
                  onDragDone: controller.onDragDone,
                  onDragEntered: controller.onDragEntered,
                  onDragExited: controller.onDragExited,
                  child: Stack(
                    children: <Widget>[
                      if (Matrix.of(context).wallpaper != null)
                        Image.file(
                          Matrix.of(context).wallpaper!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.medium,
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              colors: [
                                colorScheme.primaryContainer.withAlpha(64),
                                colorScheme.secondaryContainer.withAlpha(64),
                                colorScheme.tertiaryContainer.withAlpha(64),
                                colorScheme.primaryContainer.withAlpha(64),
                              ],
                            ),
                          ),
                        ),
                      SafeArea(
                        child: Column(
                          children: <Widget>[
                            TombstoneDisplay(controller),
                            PinnedEvents(controller),
                            Expanded(
                              child: GestureDetector(
                                onTap: controller.clearSingleSelectedEvent,
                                child: Builder(
                                  builder: (context) {
                                    if (controller.timeline == null) {
                                      return const Center(
                                        child: CircularProgressIndicator.adaptive(
                                          strokeWidth: 2,
                                        ),
                                      );
                                    }

                                    return ChatEventList(
                                      key: UniqueKey(),
                                      controller: controller,
                                    );
                                  },
                                ),
                              ),
                            ),
                            if (controller.room.canSendDefaultMessages &&
                                controller.room.membership == Membership.join)
                              Container(
                                margin: EdgeInsets.only(
                                  bottom: bottomSheetPadding,
                                  left: bottomSheetPadding,
                                  right: bottomSheetPadding,
                                ),
                                constraints: const BoxConstraints(
                                  maxWidth: FluffyThemes.columnWidth * 2.5,
                                ),
                                alignment: Alignment.center,
                                child: Material(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(AppConfig.borderRadius),
                                    bottomRight: Radius.circular(AppConfig.borderRadius),
                                  ),
                                  elevation: 4,
                                  shadowColor: Colors.black.withAlpha(64),
                                  clipBehavior: Clip.hardEdge,
                                  color: Theme.of(context).brightness == Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  child: controller.room.isAbandonedDMRoom == true
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            TextButton.icon(
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.all(16),
                                                foregroundColor:
                                                    Theme.of(context).colorScheme.error,
                                              ),
                                              icon: const Icon(
                                                Icons.archive_outlined,
                                              ),
                                              onPressed: controller.leaveChat,
                                              label: Text(
                                                L10n.of(context)!.leave,
                                              ),
                                            ),
                                            TextButton.icon(
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.all(16),
                                              ),
                                              icon: const Icon(
                                                Icons.forum_outlined,
                                              ),
                                              onPressed: controller.recreateChat,
                                              label: Text(
                                                L10n.of(context)!.reopenChat,
                                              ),
                                            ),
                                          ],
                                        )
                                      : controller.currentMembership == 'leave'
                                          ? null
                                          : Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const ConnectionStatusHeader(),
                                                ReactionsPicker(controller),
                                                RevisionHistoryDisplay(controller),
                                                ReplyDisplay(controller),
                                                ChatInputRow(controller),
                                                ChatEmojiPicker(controller),
                                              ],
                                            ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (controller.dragging)
                        Container(
                          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.upload_outlined,
                            size: 100,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
