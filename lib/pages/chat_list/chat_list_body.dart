/*
 * Modified by akquinet GmbH on 30.10.2024
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/utils/matrix_sdk_extensions/room_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:matrix/matrix.dart';
import 'package:animations/animations.dart';

import 'package:fluffychat/pages/chat_list/chat_list.dart';
import 'package:fluffychat/pages/chat_list/chat_list_item.dart';
import 'package:fluffychat/pages/chat_list/search_title.dart';
import 'package:fluffychat/pages/chat_list/space_view.dart';
import 'package:fluffychat/pages/chat_list/start_chat_fab.dart';
import 'package:fluffychat/utils/adaptive_bottom_sheet.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:fluffychat/utils/stream_extension.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/profile_bottom_sheet.dart';
import 'package:fluffychat/widgets/public_room_bottom_sheet.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/tim/test_driver/search_result_debug_widget.dart';
import 'package:fluffychat/widgets/connection_status_header.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:vrouter/vrouter.dart';
import 'chat_list_header.dart';

class ChatListViewBody extends StatelessWidget {
  final ChatListController controller;

  const ChatListViewBody(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roomSearchResult = controller.roomSearchResult;
    final userSearchResult = controller.userSearchResult;
    final client = Matrix.of(context).client;
    final showBlockAllBanner = controller.shouldShowBlockAllInvitesWithoutExceptionsWarning;

    final switcher = PageTransitionSwitcher(
      transitionBuilder: (
        Widget child,
        Animation<double> primaryAnimation,
        Animation<double> secondaryAnimation,
      ) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        );
      },
      child: StreamBuilder(
        key: ValueKey(
          client.userID.toString() +
              controller.activeFilter.toString() +
              controller.activeSpaceId.toString(),
        ),
        stream: client.onSync.stream
            .where((s) => s.hasRoomUpdate)
            .rateLimit(const Duration(seconds: 1)),
        builder: (context, _) {
          if (controller.activeFilter == ActiveFilter.spaces && !controller.isSearchMode) {
            return SpaceView(
              controller,
              scrollController: controller.scrollController,
              key: Key(controller.activeSpaceId ?? 'Spaces'),
            );
          }
          if (controller.waitForFirstSync && client.prevBatch != null) {
            final rooms = controller.filteredRooms;
            return SafeArea(
              child: CustomScrollView(
                controller: controller.scrollController,
                slivers: [
                  ChatListHeader(controller: controller),
                  if (showBlockAllBanner) ...[
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          MaterialBanner(
                            key: const ValueKey("blockAllWithoutExceptionsBanner"),
                            leading: const Icon(Icons.admin_panel_settings_outlined),
                            content:
                                Text(L10n.of(context)!.blockAllInvitesWithoutExceptionsWarning),
                            actions: [
                              TextButton(
                                key: const ValueKey(
                                  "blockAllWithoutExceptionsWarningAddExceptionsButton",
                                ),
                                child: Text(L10n.of(context)!
                                    .blockAllInvitesWithoutExceptionsAddExceptionsButtonLabel),
                                onPressed: () {
                                  VRouter.of(context).to('/settings/security/inviteRejection');
                                },
                              ),
                              TextButton(
                                key:
                                    const ValueKey("blockAllWithoutExceptionsWarningDismissButton"),
                                child: Text(L10n.of(context)!
                                    .blockAllInvitesWithoutExceptionsDismissButtonLabel),
                                onPressed: () {
                                  controller.dismissBlockAllInvitesWithoutExceptionsWarning();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        if (controller.isSearchMode) ...[
                          SearchTitle(
                            title: L10n.of(context)!.publicRooms,
                            icon: const Icon(Icons.explore_outlined),
                          ),
                          AnimatedContainer(
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(),
                            height: roomSearchResult == null || roomSearchResult.chunk.isEmpty
                                ? 0
                                : 106,
                            duration: FluffyThemes.animationDuration,
                            curve: FluffyThemes.animationCurve,
                            child: roomSearchResult == null
                                ? null
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: roomSearchResult.chunk.length,
                                    itemBuilder: (context, i) => _SearchItem(
                                      title: roomSearchResult.chunk[i].name ??
                                          roomSearchResult.chunk[i].canonicalAlias?.localpart ??
                                          L10n.of(context)!.group,
                                      avatar: roomSearchResult.chunk[i].avatarUrl,
                                      onPressed: () => showAdaptiveBottomSheet(
                                        context: context,
                                        builder: (c) => PublicRoomBottomSheet(
                                          roomAlias: roomSearchResult.chunk[i].canonicalAlias ??
                                              roomSearchResult.chunk[i].roomId,
                                          outerContext: context,
                                          chunk: roomSearchResult.chunk[i],
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          SearchTitle(
                            title: L10n.of(context)!.users,
                            icon: const Icon(Icons.group_outlined),
                          ),
                          AnimatedContainer(
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(),
                            height: userSearchResult == null || userSearchResult.results.isEmpty
                                ? 0
                                : 106,
                            duration: FluffyThemes.animationDuration,
                            curve: FluffyThemes.animationCurve,
                            child: userSearchResult == null
                                ? null
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: userSearchResult.results.length,
                                    itemBuilder: (context, i) => _SearchItem(
                                      title: userSearchResult.results[i].displayName ??
                                          userSearchResult.results[i].userId.localpart ??
                                          L10n.of(context)!.unknownDevice,
                                      avatar: userSearchResult.results[i].avatarUrl,
                                      onPressed: () => showAdaptiveBottomSheet(
                                        context: context,
                                        builder: (c) => ProfileBottomSheet(
                                          userId: userSearchResult.results[i].userId,
                                          outerContext: context,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                        const ConnectionStatusHeader(),
                        if (controller.isSearchMode)
                          SearchTitle(
                            title: L10n.of(context)!.chats,
                            icon: const Icon(Icons.forum_outlined),
                          ),
                        if (rooms.isEmpty && !controller.isSearchMode) ...[
                          Center(
                            child: StartChatFloatingActionButton(
                              activeFilter: controller.activeFilter,
                              roomsIsEmpty: true,
                              scrolledToTop: controller.scrolledToTop,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int i) {
                        if (!rooms[i]
                            .getLocalizedDisplaynameFromCustomNameEvent(
                              MatrixLocals(L10n.of(context)!),
                            )
                            .toLowerCase()
                            .contains(
                              controller.searchController.text.toLowerCase(),
                            )) {
                          return const SizedBox.shrink();
                        }
                        return ChatListItem(
                          rooms[i],
                          key: Key('chat_list_item_${rooms[i].id}'),
                          selected: controller.selectedRoomIds.contains(rooms[i].id),
                          onTap: controller.selectMode == SelectMode.select
                              ? () => controller.toggleSelection(rooms[i].id)
                              : null,
                          onLongPress: () => controller.toggleSelection(rooms[i].id),
                          activeChat: controller.activeChat == rooms[i].id,
                        );
                      },
                      childCount: rooms.length,
                    ),
                  ),
                ],
              ),
            );
          }
          return _buildDummyList(context);
        },
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [SearchResultDebugWidget(userSearchResult), switcher],
    );
  }

  Widget _buildDummyList(BuildContext context) {
    // Workaround to force the list to reload from a potentially broken state.
    Future.delayed(const Duration(milliseconds: 1000), () {
      try {
        (context as Element).reassemble();
      } finally {}
    });

    const dummyChatCount = 5;
    final titleColor = Theme.of(context).textTheme.bodyLarge!.color!.withAlpha(100);
    final subtitleColor = Theme.of(context).textTheme.bodyLarge!.color!.withAlpha(50);
    return ListView.builder(
      key: const Key('dummychats'),
      itemCount: dummyChatCount,
      itemBuilder: (context, i) => Opacity(
        opacity: (dummyChatCount - i) / dummyChatCount,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: titleColor,
            child: CircularProgressIndicator(
              strokeWidth: 1,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: titleColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 36),
              Container(
                height: 14,
                width: 14,
                decoration: BoxDecoration(
                  color: subtitleColor,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 14,
                width: 14,
                decoration: BoxDecoration(
                  color: subtitleColor,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ],
          ),
          subtitle: Container(
            decoration: BoxDecoration(
              color: subtitleColor,
              borderRadius: BorderRadius.circular(3),
            ),
            height: 12,
            margin: const EdgeInsets.only(right: 22),
          ),
        ),
      ),
    );
  }
}

class _SearchItem extends StatelessWidget {
  final String title;
  final Uri? avatar;
  final void Function() onPressed;

  const _SearchItem({
    required this.title,
    this.avatar,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 84,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Avatar(
                mxContent: avatar,
                name: title,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
