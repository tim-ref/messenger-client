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

import 'package:fluffychat/utils/matrix_sdk_extensions/room_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:badges/badges.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:keyboard_shortcuts/keyboard_shortcuts.dart';
import 'package:vrouter/vrouter.dart';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat_list/chat_list.dart';
import 'package:fluffychat/pages/chat_list/navi_rail_item.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/unread_rooms_badge.dart';
import '../../widgets/matrix.dart';
import 'chat_list_body.dart';
import 'start_chat_fab.dart';

class ChatListView extends StatelessWidget {
  final ChatListController controller;

  const ChatListView(this.controller, {Key? key}) : super(key: key);

  List<NavigationDestination> getNavigationDestinations(BuildContext context) {
    final badgePosition = BadgePosition.topEnd(top: -12, end: -8);
    return [
      if (AppConfig.separateChatTypes) ...[
        NavigationDestination(
          icon: UnreadRoomsBadge(
            badgePosition: badgePosition,
            filter: controller.getRoomFilterByActiveFilter(ActiveFilter.messages),
            child: const Icon(Icons.forum_outlined),
          ),
          selectedIcon: UnreadRoomsBadge(
            badgePosition: badgePosition,
            filter: controller.getRoomFilterByActiveFilter(ActiveFilter.messages),
            child: const Icon(Icons.forum),
          ),
          label: L10n.of(context)!.messages,
        ),
        NavigationDestination(
          icon: UnreadRoomsBadge(
            badgePosition: badgePosition,
            filter: controller.getRoomFilterByActiveFilter(ActiveFilter.groups),
            child: const Icon(Icons.group_outlined),
          ),
          selectedIcon: UnreadRoomsBadge(
            badgePosition: badgePosition,
            filter: controller.getRoomFilterByActiveFilter(ActiveFilter.groups),
            child: const Icon(Icons.group),
          ),
          label: L10n.of(context)!.groups,
        ),
      ] else
        NavigationDestination(
          icon: UnreadRoomsBadge(
            badgePosition: badgePosition,
            filter: controller.getRoomFilterByActiveFilter(ActiveFilter.allChats),
            child: const Icon(Icons.forum_outlined),
          ),
          selectedIcon: UnreadRoomsBadge(
            badgePosition: badgePosition,
            filter: controller.getRoomFilterByActiveFilter(ActiveFilter.allChats),
            child: const Icon(Icons.forum),
          ),
          label: L10n.of(context)!.chats,
        ),
      if (controller.spaces.isNotEmpty)
        const NavigationDestination(
          icon: Icon(Icons.workspaces_outlined),
          selectedIcon: Icon(Icons.workspaces),
          label: 'Spaces',
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final client = Matrix.of(context).client;
    return StreamBuilder<Object?>(
      stream: Matrix.of(context).onShareContentChanged.stream,
      builder: (_, __) {
        final selectMode = controller.selectMode;
        return VWidgetGuard(
          onSystemPop: (redirector) async {
            final selMode = controller.selectMode;
            if (selMode != SelectMode.normal) {
              controller.cancelAction();
              redirector.stopRedirection();
              return;
            }
            if (controller.activeFilter !=
                (AppConfig.separateChatTypes ? ActiveFilter.messages : ActiveFilter.allChats)) {
              controller.onDestinationSelected(AppConfig.separateChatTypes ? 1 : 0);
              redirector.stopRedirection();
              return;
            }
          },
          child: Row(
            children: [
              if (FluffyThemes.isColumnMode(context) &&
                  FluffyThemes.getDisplayNavigationRail(context)) ...[
                Builder(
                  builder: (context) {
                    final allSpaces = client.rooms.where((room) => room.isSpace);
                    final rootSpaces = allSpaces
                        .where(
                          (space) => !allSpaces.any(
                            (parentSpace) =>
                                parentSpace.spaceChildren.any((child) => child.roomId == space.id),
                          ),
                        )
                        .toList();
                    final destinations = getNavigationDestinations(context);

                    return SizedBox(
                      width: FluffyThemes.navRailWidth,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: rootSpaces.length + destinations.length,
                        itemBuilder: (context, i) {
                          if (i < destinations.length) {
                            return NaviRailItem(
                              isSelected: i == controller.selectedIndex,
                              onTap: () => controller.onDestinationSelected(i),
                              icon: destinations[i].icon,
                              selectedIcon: destinations[i].selectedIcon,
                              toolTip: destinations[i].label,
                            );
                          }
                          i -= destinations.length;
                          final isSelected = controller.activeFilter == ActiveFilter.spaces &&
                              rootSpaces[i].id == controller.activeSpaceId;
                          return NaviRailItem(
                            toolTip: rootSpaces[i].getLocalizedDisplaynameFromCustomNameEvent(
                              MatrixLocals(L10n.of(context)!),
                            ),
                            isSelected: isSelected,
                            onTap: () => controller.setActiveSpace(rootSpaces[i].id),
                            icon: Avatar(
                              mxContent: rootSpaces[i].avatar,
                              name: rootSpaces[i].getLocalizedDisplaynameFromCustomNameEvent(
                                MatrixLocals(L10n.of(context)!),
                              ),
                              size: 32,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                Container(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ],
              Expanded(
                child: GestureDetector(
                  onTap: FocusManager.instance.primaryFocus?.unfocus,
                  excludeFromSemantics: true,
                  behavior: HitTestBehavior.translucent,
                  child: Scaffold(
                    body: ChatListViewBody(controller),
                    bottomNavigationBar: controller.displayNavigationBar
                        ? NavigationBar(
                            height: 64,
                            selectedIndex: controller.selectedIndex,
                            onDestinationSelected: controller.onDestinationSelected,
                            destinations: getNavigationDestinations(context),
                          )
                        : null,
                    floatingActionButton: KeyBoardShortcuts(
                      keysToPress: {
                        LogicalKeyboardKey.controlLeft,
                        LogicalKeyboardKey.keyN,
                      },
                      onKeysPressed: () => VRouter.of(context).to('/newprivatechat'),
                      helpLabel: L10n.of(context)!.newChat,
                      child: selectMode == SelectMode.normal &&
                              controller.filteredRooms.isNotEmpty &&
                              !controller.isSearchMode
                          ? StartChatFloatingActionButton(
                              activeFilter: controller.activeFilter,
                              roomsIsEmpty: false,
                              scrolledToTop: controller.scrolledToTop,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
