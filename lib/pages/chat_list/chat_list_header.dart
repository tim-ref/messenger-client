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

import 'package:fluffychat/tim/feature/fhir/search/ui/search_more_icon_button.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat_list/chat_list.dart';
import 'package:fluffychat/pages/chat_list/client_chooser_button.dart';

class ChatListHeader extends StatelessWidget implements PreferredSizeWidget {
  final ChatListController controller;

  const ChatListHeader({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectMode = controller.selectMode;

    return SliverAppBar(
      floating: true,
      pinned:
          FluffyThemes.isColumnMode(context) || selectMode != SelectMode.normal,
      scrolledUnderElevation: selectMode == SelectMode.normal ? 0 : null,
      backgroundColor:
          selectMode == SelectMode.normal ? Colors.transparent : null,
      automaticallyImplyLeading: false,
      leading: selectMode == SelectMode.normal
          ? null
          : IconButton(
              tooltip: L10n.of(context)!.cancel,
              icon: const Icon(Icons.close_outlined),
              onPressed: controller.cancelAction,
              color: Theme.of(context).colorScheme.primary,
            ),
      title: selectMode == SelectMode.share
          ? Text(
              L10n.of(context)!.share,
              key: const ValueKey(SelectMode.share),
            )
          : selectMode == SelectMode.select
              ? Text(
                  controller.selectedRoomIds.length.toString(),
                  key: const ValueKey(SelectMode.select),
                )
              : SizedBox(
                  height: 44,
                  child: Semantics(
                    label: "searchInputDebugLabel",
                    container: true,
                    textField: true,
                    child: TextField(
                      controller: controller.searchController,
                      textInputAction: TextInputAction.search,
                      onChanged: controller.onSearchEnter,
                      decoration: InputDecoration(

                        border: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius:
                              BorderRadius.circular(AppConfig.borderRadius),
                        ),
                        hintText: L10n.of(context)!.search,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        prefixIcon: controller.isSearchMode
                            ? IconButton(
                                tooltip: L10n.of(context)!.cancel,
                                icon: const Icon(Icons.close_outlined),
                                onPressed: controller.cancelSearch,
                                color: Theme.of(context).colorScheme.onBackground,
                              )
                            : const SearchMoreIconButton(path: '/fhir/search'),
                        suffixIcon: SizedBox(
                          width: 0,
                          child: ClientChooserButton(controller)
                        )
                      ),
                    )
                  ),
                ),
      actions: selectMode == SelectMode.share
          ? [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ClientChooserButton(controller),
              ),
            ]
          : selectMode == SelectMode.select
              ? [
                  if (controller.spaces.isNotEmpty)
                    IconButton(
                      tooltip: L10n.of(context)!.addToSpace,
                      icon: const Icon(Icons.workspaces_outlined),
                      onPressed: controller.addToSpace,
                    ),
                  IconButton(
                    tooltip: L10n.of(context)!.toggleUnread,
                    icon: Icon(
                      controller.anySelectedRoomNotMarkedUnread
                          ? Icons.mark_chat_read_outlined
                          : Icons.mark_chat_unread_outlined,
                    ),
                    onPressed: controller.toggleUnread,
                  ),
                  IconButton(
                    tooltip: L10n.of(context)!.toggleFavorite,
                    icon: Icon(
                      controller.anySelectedRoomNotFavorite
                          ? Icons.push_pin_outlined
                          : Icons.push_pin,
                    ),
                    onPressed: controller.toggleFavouriteRoom,
                  ),
                  IconButton(
                    icon: Icon(
                      controller.anySelectedRoomNotMuted
                          ? Icons.notifications_off_outlined
                          : Icons.notifications_outlined,
                    ),
                    tooltip: L10n.of(context)!.toggleMuted,
                    onPressed: controller.toggleMuted,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outlined),
                    tooltip: L10n.of(context)!.archive,
                    onPressed: controller.archiveAction,
                  ),
                ]
              : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
