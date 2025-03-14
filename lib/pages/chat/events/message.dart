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

import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/utils/date_time_extension.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/room_extension.dart';
import 'package:fluffychat/utils/string_color.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';
import 'package:swipe_to_action/swipe_to_action.dart';

import '../../../config/app_config.dart';
import '../../../widgets/user_avatar.dart';
import 'message_content.dart';
import 'message_reactions.dart';
import 'reply_content.dart';
import 'state_message.dart';
import 'verification_request_content.dart';

class Message extends StatelessWidget {
  final Event event;
  final Event? nextEvent;
  final bool displayReadMarker;
  final void Function(Event)? onSelect;
  final void Function(Event) onEditHistoryTap;
  final void Function(Event)? onAvatarTab;
  final void Function(Event)? onInfoTab;
  final void Function(String)? scrollToEventId;
  final void Function(SwipeDirection) onSwipe;
  final bool longPressSelect;
  final bool selected;
  final Timeline timeline;

  const Message(
    this.event, {
    this.nextEvent,
    this.displayReadMarker = false,
    this.longPressSelect = false,
    this.onSelect,
    this.onInfoTab,
    this.onAvatarTab,
    this.scrollToEventId,
    required this.onSwipe,
    this.selected = false,
    required this.timeline,
    required this.onEditHistoryTap,
    Key? key,
  }) : super(key: key);

  /// Indicates wheither the user may use a mouse instead
  /// of touchscreen.
  static bool useMouse = false;

  @override
  Widget build(BuildContext context) {
    if (!{
      EventTypes.Message,
      EventTypes.Sticker,
      EventTypes.Encrypted,
      EventTypes.CallInvite,
    }.contains(event.type)) {
      if (event.type.startsWith('m.call.')) {
        return const SizedBox.shrink();
      }
      return StateMessage(event);
    }

    if (event.type == EventTypes.Message &&
        event.messageType == EventTypes.KeyVerificationRequest) {
      return VerificationRequestContent(event: event, timeline: timeline);
    }

    final client = Matrix.of(context).client;
    final ownMessage = event.senderId == client.userID;
    final alignment = ownMessage ? Alignment.topRight : Alignment.topLeft;
    var color = Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Theme.of(context).colorScheme.surfaceVariant;
    final displayTime = event.type == EventTypes.RoomCreate ||
        nextEvent == null ||
        !event.originServerTs.sameEnvironment(nextEvent!.originServerTs);
    final sameSender = nextEvent != null &&
            [
              EventTypes.Message,
              EventTypes.Sticker,
              EventTypes.Encrypted,
            ].contains(nextEvent!.type)
        ? nextEvent!.senderId == event.senderId && !displayTime
        : false;
    final textColor = ownMessage
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onBackground;
    final rowMainAxisAlignment = ownMessage ? MainAxisAlignment.end : MainAxisAlignment.start;

    final displayEvent = event.getDisplayEvent(timeline);
    final borderRadius = BorderRadius.only(
      topLeft:
          !ownMessage ? const Radius.circular(4) : const Radius.circular(AppConfig.borderRadius),
      topRight: const Radius.circular(AppConfig.borderRadius),
      bottomLeft: const Radius.circular(AppConfig.borderRadius),
      bottomRight:
          ownMessage ? const Radius.circular(4) : const Radius.circular(AppConfig.borderRadius),
    );
    final noBubble = {
          MessageTypes.Video,
          MessageTypes.Image,
          MessageTypes.Sticker,
        }.contains(event.messageType) &&
        !event.redacted;
    final noPadding = {
      MessageTypes.File,
      MessageTypes.Audio,
    }.contains(event.messageType);

    if (ownMessage) {
      color =
          displayEvent.status.isError ? Colors.redAccent : Theme.of(context).colorScheme.primary;
    }

    final rowChildren = <Widget>[
      sameSender || ownMessage
          ? SizedBox(
              width: Avatar.defaultSize,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: SizedBox(
                    width: 16 * AppConfig.bubbleSizeFactor,
                    height: 16 * AppConfig.bubbleSizeFactor,
                    child: event.status == EventStatus.sending
                        ? const CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          )
                        : event.status == EventStatus.error
                            ? const Icon(Icons.error, color: Colors.red)
                            : null,
                  ),
                ),
              ),
            )
          : FutureBuilder<User?>(
              future: event.fetchSenderUser(),
              builder: (context, snapshot) {
                final user = snapshot.data ?? event.senderFromMemoryOrFallback;
                return UserAvatar(
                  user: user,
                  onTap: () => onAvatarTab!(event),
                );
              },
            ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!sameSender)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                child: ownMessage || event.room.isDirectChatWithTwoOrLessParticipants
                    ? const SizedBox(height: 12)
                    : FutureBuilder<User?>(
                        future: event.fetchSenderUser(),
                        builder: (context, snapshot) {
                          final displayname = snapshot.data?.calcDisplayname() ??
                              event.senderFromMemoryOrFallback.calcDisplayname();
                          return Text(
                            displayname,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: (Theme.of(context).brightness == Brightness.light
                                  ? displayname.color
                                  : displayname.lightColorText),
                            ),
                          );
                        },
                      ),
              ),
            Container(
              alignment: alignment,
              padding: const EdgeInsets.only(left: 8),
              child: Material(
                color: noBubble ? Colors.transparent : color,
                elevation: event.type == EventTypes.Sticker ? 0 : 4,
                shadowColor: Colors.black.withAlpha(64),
                borderRadius: borderRadius,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onHover: (b) => useMouse = true,
                  onTap: !useMouse && longPressSelect ? () {} : () => onSelect!(event),
                  onLongPress: !longPressSelect ? null : () => onSelect!(event),
                  borderRadius: borderRadius,
                  key: ValueKey("ChatMessage-${event.eventId}"),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                    ),
                    padding: noBubble || noPadding
                        ? EdgeInsets.zero
                        : EdgeInsets.all(16 * AppConfig.bubbleSizeFactor),
                    constraints: const BoxConstraints(
                      maxWidth: FluffyThemes.columnWidth * 1.5,
                    ),
                    child: Stack(
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (event.relationshipType == RelationshipTypes.reply)
                              FutureBuilder<Event?>(
                                future: event.getReplyEvent(timeline),
                                builder: (BuildContext context, snapshot) {
                                  final replyEvent = snapshot.hasData
                                      ? snapshot.data!
                                      : Event(
                                          eventId: event.relationshipEventId!,
                                          content: {
                                            'msgtype': 'm.text',
                                            'body': '...',
                                          },
                                          senderId: event.senderId,
                                          type: 'm.room.message',
                                          room: event.room,
                                          status: EventStatus.sent,
                                          originServerTs: DateTime.now(),
                                        );
                                  return InkWell(
                                    onTap: () {
                                      if (scrollToEventId != null) {
                                        scrollToEventId!(replyEvent.eventId);
                                      }
                                    },
                                    child: AbsorbPointer(
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                          vertical: 4.0 * AppConfig.bubbleSizeFactor,
                                        ),
                                        child: ReplyContent(
                                          replyEvent,
                                          ownMessage: ownMessage,
                                          timeline: timeline,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            MessageContent(
                              displayEvent,
                              textColor: textColor,
                              onInfoTab: onInfoTab,
                            ),
                            if (event.hasAggregatedEvents(
                              timeline,
                              RelationshipTypes.edit,
                            ))
                              InkWell(
                                onTap: () => onEditHistoryTap(event),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: 4.0 * AppConfig.bubbleSizeFactor,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        color: textColor.withAlpha(164),
                                        size: 14,
                                      ),
                                      Text(
                                        ' - ${displayEvent.originServerTs.localizedTimeShort(context)}',
                                        style: TextStyle(
                                          color: textColor.withAlpha(164),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: rowMainAxisAlignment,
      children: rowChildren,
    );
    Widget container;
    if (event.hasAggregatedEvents(timeline, RelationshipTypes.reaction) ||
        displayTime ||
        selected ||
        displayReadMarker) {
      container = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: ownMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          if (displayTime || selected)
            Padding(
              padding: displayTime
                  ? EdgeInsets.symmetric(
                      vertical: 8.0 * AppConfig.bubbleSizeFactor,
                    )
                  : EdgeInsets.zero,
              child: Center(
                child: Material(
                  color: displayTime
                      ? Theme.of(context).colorScheme.background
                      : Theme.of(context).colorScheme.background.withOpacity(0.33),
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      event.originServerTs.localizedTime(context),
                      style: TextStyle(fontSize: 14 * AppConfig.fontSizeFactor),
                    ),
                  ),
                ),
              ),
            ),
          row,
          if (event.hasAggregatedEvents(timeline, RelationshipTypes.reaction))
            Padding(
              padding: EdgeInsets.only(
                top: 4.0 * AppConfig.bubbleSizeFactor,
                left: (ownMessage ? 0 : Avatar.defaultSize) + 12.0,
                right: 12.0,
              ),
              child: MessageReactions(event, timeline),
            ),
          if (displayReadMarker)
            Row(
              children: [
                Expanded(
                  child: Divider(color: Theme.of(context).colorScheme.primary),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: Text(
                    L10n.of(context)!.readUpToHere,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                Expanded(
                  child: Divider(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
        ],
      );
    } else {
      container = row;
    }

    return Swipeable(
      key: ValueKey(event.eventId),
      background: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: Center(
          child: Icon(Icons.reply_outlined),
        ),
      ),
      direction: SwipeDirection.endToStart,
      onSwipe: onSwipe,
      child: Center(
        child: Container(
          color: selected
              ? Theme.of(context).primaryColor.withAlpha(100)
              : Theme.of(context).primaryColor.withAlpha(0),
          constraints: const BoxConstraints(maxWidth: FluffyThemes.columnWidth * 2.5),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 4.0 * AppConfig.bubbleSizeFactor,
            ),
            child: container,
          ),
        ),
      ),
    );
  }
}
