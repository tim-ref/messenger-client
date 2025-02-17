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

import 'package:fluffychat/widgets/matrix.dart';
import 'package:fluffychat/tim/shared/provider/tim_provider.dart';
import 'package:fluffychat/tim/tim_constants.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pages/chat/events/message.dart';
import 'package:fluffychat/pages/chat/seen_by_row.dart';
import 'package:fluffychat/pages/chat/typing_indicators.dart';
import 'package:fluffychat/pages/user_bottom_sheet/user_bottom_sheet.dart';
import 'package:fluffychat/utils/adaptive_bottom_sheet.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/filtered_timeline_extension.dart';
import 'package:fluffychat/utils/platform_infos.dart';

class ChatEventList extends StatelessWidget {
  final ChatController controller;

  const ChatEventList({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = FluffyThemes.isColumnMode(context) ? 8.0 : 0.0;

    // create a map of eventId --> index to greatly improve performance of
    // ListView's findChildIndexCallback
    final thisEventsKeyMap = <String, int>{};
    for (var i = 0; i < controller.timeline!.events.length; i++) {
      thisEventsKeyMap[controller.timeline!.events[i].eventId] = i;
      Logs().d("my event id is ${controller.timeline!.events[i].eventId}");
    }
    if (const bool.fromEnvironment(enableDebugWidget)) {
      TimProvider.of(context).testDriverStateHelper()!.roomTimeline.add(controller.timeline);
    }

    final ignoredUsers = Matrix.of(context).client.ignoredUsers;

    return ListView.custom(
      padding: EdgeInsets.only(
        top: 16,
        bottom: 4,
        left: horizontalPadding,
        right: horizontalPadding,
      ),
      reverse: true,
      controller: controller.scrollController,
      keyboardDismissBehavior: PlatformInfos.isIOS
          ? ScrollViewKeyboardDismissBehavior.onDrag
          : ScrollViewKeyboardDismissBehavior.manual,
      childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int i) {
          // Footer to display typing indicator and read receipts:
          if (i == 0) {
            if (controller.timeline!.isRequestingFuture) {
              return const Center(
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              );
            }
            if (controller.timeline!.canRequestFuture) {
              Center(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  onPressed: controller.requestFuture,
                  child: Text(L10n.of(context)!.loadMore),
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SeenByRow(controller),
                TypingIndicators(controller),
              ],
            );
          }

          // Request history button or progress indicator:
          if (i == controller.timeline!.events.length + 1) {
            if (controller.timeline!.isRequestingHistory) {
              return const Center(
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              );
            }
            if (controller.timeline!.canRequestHistory) {
              Center(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  onPressed: controller.requestHistory,
                  child: Text(L10n.of(context)!.loadMore),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          final eventList = controller.timeline!.events;
          if (eventList.length <= i - 1) {
            return const SizedBox.shrink();
          }
          // The message at this index:
          final event = eventList[i - 1];

          return AutoScrollTag(
            key: ValueKey(event.eventId),
            index: i - 1,
            controller: controller.scrollController,
            child: event.isVisibleInGui && !event.isMessageIgnored(ignoredUsers)
                ? Message(
                    event,
                    onSwipe: (direction) => controller.replyAction(replyTo: event),
                    onEditHistoryTap:(event)=> controller.showEditHistory(event),
                    onInfoTab: controller.showEventInfo,
                    onAvatarTab: (Event event) => showAdaptiveBottomSheet(
                      context: context,
                      builder: (c) => UserBottomSheet(
                        user: event.senderFromMemoryOrFallback,
                        outerContext: context,
                        onMention: () => controller.sendController.text +=
                            '${event.senderFromMemoryOrFallback.mention} ',
                      ),
                    ),
                    onSelect: controller.onSelectMessage,
                    scrollToEventId: (String eventId) => controller.scrollToEventId(eventId),
                    longPressSelect: controller.selectedEvents.isEmpty,
                    selected: controller.selectedEvents.any((e) => e.eventId == event.eventId),
                    timeline: controller.timeline!,
                    displayReadMarker: controller.readMarkerEventId == event.eventId &&
                        controller.timeline?.allowNewEvent == false,
                    nextEvent: i < controller.timeline!.events.length
                        ? controller.timeline!.events[i]
                        : null,
                  )
                : const SizedBox.shrink(),
          );
        },
        childCount: controller.timeline!.events.length + 2,
        findChildIndexCallback: (key) => controller.findChildIndexCallback(key, thisEventsKeyMap),
      ),
    );
  }
}
