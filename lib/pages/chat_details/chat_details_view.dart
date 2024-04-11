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

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pages/chat_details/chat_details.dart';
import 'package:fluffychat/pages/chat_details/participant_list_item.dart';
import 'package:fluffychat/utils/fluffy_share.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/chat_settings_popup_menu.dart';
import 'package:fluffychat/widgets/content_banner.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:fluffychat/widgets/matrix.dart';
import '../../utils/url_launcher.dart';

class ChatDetailsView extends StatelessWidget {
  final ChatDetailsController controller;

  const ChatDetailsView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final room = Matrix.of(context).client.getRoomById(controller.roomId!);
    if (room == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(L10n.of(context)!.oopsSomethingWentWrong),
        ),
        body: Center(
          child: Text(L10n.of(context)!.youAreNoLongerParticipatingInThisChat),
        ),
      );
    }

    controller.members!.removeWhere((u) => u.membership == Membership.leave);
    final actualMembersCount =
        (room.summary.mInvitedMemberCount ?? 0) + (room.summary.mJoinedMemberCount ?? 0);
    final canRequestMoreMembers = controller.members!.length < actualMembersCount;
    final iconColor = Theme.of(context).textTheme.bodyLarge!.color;
    return StreamBuilder(
      stream: room.onUpdate.stream,
      builder: (context, snapshot) {
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => <Widget>[
              SliverAppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close_outlined),
                  onPressed: () => VRouter.of(context).path.startsWith('/spaces/')
                      ? VRouter.of(context).pop()
                      : VRouter.of(context).toSegments(['rooms', controller.roomId!]),
                ),
                elevation: Theme.of(context).appBarTheme.elevation,
                expandedHeight: 300.0,
                floating: true,
                pinned: true,
                actions: <Widget>[
                  if (room.canonicalAlias.isNotEmpty)
                    IconButton(
                      tooltip: L10n.of(context)!.share,
                      icon: Icon(Icons.adaptive.share_outlined),
                      onPressed: () => FluffyShare.share(
                        AppConfig.inviteLinkPrefix + room.canonicalAlias,
                        context,
                      ),
                    ),
                  ChatSettingsPopupMenu(room, false),
                ],
                title: Text(
                  room.getLocalizedDisplaynameFromCustomNameEvent(MatrixLocals(L10n.of(context)!)),
                ),
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: ContentBanner(
                    mxContent: room.avatar,
                    onEdit: room.canSendEvent('m.room.avatar') ? controller.setAvatarAction : null,
                    defaultIcon: Icons.group_outlined,
                  ),
                ),
              ),
            ],
            body: MaxWidthBody(
              child: ListView.builder(
                itemCount: controller.members!.length + 1 + (canRequestMoreMembers ? 1 : 0),
                itemBuilder: (BuildContext context, int i) => i == 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          ListTile(
                            onTap: room.canSendEvent(EventTypes.RoomTopic)
                                ? controller.setTopicAction
                                : null,
                            trailing: room.canSendEvent(EventTypes.RoomTopic)
                                ? Icon(
                                    Icons.edit_outlined,
                                    color: Theme.of(context).colorScheme.onBackground,
                                  )
                                : null,
                            title: Text(
                              L10n.of(context)!.groupDescription,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (room.displayTopic.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Linkify(
                                text: room.displayTopic,
                                options: const LinkifyOptions(humanize: false),
                                linkStyle: const TextStyle(color: Colors.blueAccent),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).textTheme.bodyMedium!.color,
                                  decorationColor: Theme.of(context).textTheme.bodyMedium!.color,
                                ),
                                onOpen: (url) => UrlLauncher(context, url.url).launchUrl(),
                              ),
                            ),
                          const SizedBox(height: 8),
                          const Divider(height: 1),
                          ListTile(
                            title: Text(
                              L10n.of(context)!.settings,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Icon(
                              controller.displaySettings
                                  ? Icons.keyboard_arrow_down_outlined
                                  : Icons.keyboard_arrow_right_outlined,
                            ),
                            onTap: controller.toggleDisplaySettings,
                          ),
                          if (controller.displaySettings) ...[
                            if (room.canSendEvent('m.room.name'))
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                  foregroundColor: iconColor,
                                  child: const Icon(
                                    Icons.people_outline_outlined,
                                  ),
                                ),
                                title: Text(
                                  L10n.of(context)!.changeTheNameOfTheGroup,
                                ),
                                subtitle: Text(
                                  room.getLocalizedDisplaynameFromCustomNameEvent(
                                    MatrixLocals(L10n.of(context)!),
                                  ),
                                ),
                                onTap: controller.setDisplaynameAction,
                              ),
                            if (room.joinRules == JoinRules.public)
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                  foregroundColor: iconColor,
                                  child: const Icon(Icons.link_outlined),
                                ),
                                onTap: controller.editAliases,
                                title: Text(L10n.of(context)!.editRoomAliases),
                                subtitle: Text(
                                  (room.canonicalAlias.isNotEmpty)
                                      ? room.canonicalAlias
                                      : L10n.of(context)!.none,
                                ),
                              ),
                            PopupMenuButton(
                              onSelected: controller.setJoinRulesAction,
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<JoinRules>>[
                                if (room.canChangeJoinRules)
                                  PopupMenuItem<JoinRules>(
                                    value: JoinRules.public,
                                    child: Text(
                                      JoinRules.public.getLocalizedString(
                                        MatrixLocals(L10n.of(context)!),
                                      ),
                                    ),
                                  ),
                                if (room.canChangeJoinRules)
                                  PopupMenuItem<JoinRules>(
                                    value: JoinRules.invite,
                                    child: Text(
                                      JoinRules.invite.getLocalizedString(
                                        MatrixLocals(L10n.of(context)!),
                                      ),
                                    ),
                                  ),
                              ],
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                  foregroundColor: iconColor,
                                  child: const Icon(Icons.shield_outlined),
                                ),
                                title: Text(
                                  L10n.of(context)!.whoIsAllowedToJoinThisGroup,
                                ),
                                subtitle: Text(
                                  room.joinRules?.getLocalizedString(
                                        MatrixLocals(L10n.of(context)!),
                                      ) ??
                                      L10n.of(context)!.none,
                                ),
                              ),
                            ),
                            PopupMenuButton(
                              onSelected: controller.setHistoryVisibilityAction,
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<HistoryVisibility>>[
                                if (room.canChangeHistoryVisibility)
                                  PopupMenuItem<HistoryVisibility>(
                                    value: HistoryVisibility.invited,
                                    child: Text(
                                      HistoryVisibility.invited.getLocalizedString(
                                        MatrixLocals(L10n.of(context)!),
                                      ),
                                    ),
                                  ),
                                if (room.canChangeHistoryVisibility)
                                  PopupMenuItem<HistoryVisibility>(
                                    value: HistoryVisibility.joined,
                                    child: Text(
                                      HistoryVisibility.joined.getLocalizedString(
                                        MatrixLocals(L10n.of(context)!),
                                      ),
                                    ),
                                  ),
                                if (room.canChangeHistoryVisibility)
                                  PopupMenuItem<HistoryVisibility>(
                                    value: HistoryVisibility.shared,
                                    child: Text(
                                      HistoryVisibility.shared.getLocalizedString(
                                        MatrixLocals(L10n.of(context)!),
                                      ),
                                    ),
                                  ),
                                if (room.canChangeHistoryVisibility)
                                  PopupMenuItem<HistoryVisibility>(
                                    value: HistoryVisibility.worldReadable,
                                    child: Text(
                                      HistoryVisibility.worldReadable.getLocalizedString(
                                        MatrixLocals(L10n.of(context)!),
                                      ),
                                    ),
                                  ),
                              ],
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                  foregroundColor: iconColor,
                                  child: const Icon(Icons.visibility_outlined),
                                ),
                                title: Text(
                                  L10n.of(context)!.visibilityOfTheChatHistory,
                                ),
                                subtitle: Text(
                                  room.historyVisibility?.getLocalizedString(
                                        MatrixLocals(L10n.of(context)!),
                                      ) ??
                                      L10n.of(context)!.none,
                                ),
                              ),
                            ),
                            if (room.joinRules == JoinRules.public)
                              PopupMenuButton(
                                onSelected: controller.setGuestAccessAction,
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<GuestAccess>>[
                                  if (room.canChangeGuestAccess)
                                    PopupMenuItem<GuestAccess>(
                                      value: GuestAccess.canJoin,
                                      child: Text(
                                        GuestAccess.canJoin.getLocalizedString(
                                          MatrixLocals(
                                            L10n.of(context)!,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (room.canChangeGuestAccess)
                                    PopupMenuItem<GuestAccess>(
                                      value: GuestAccess.forbidden,
                                      child: Text(
                                        GuestAccess.forbidden.getLocalizedString(
                                          MatrixLocals(
                                            L10n.of(context)!,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                    foregroundColor: iconColor,
                                    child: const Icon(
                                      Icons.person_add_alt_1_outlined,
                                    ),
                                  ),
                                  title: Text(
                                    L10n.of(context)!.areGuestsAllowedToJoin,
                                  ),
                                  subtitle: Text(
                                    room.guestAccess.getLocalizedString(
                                      MatrixLocals(L10n.of(context)!),
                                    ),
                                  ),
                                ),
                              ),
                            ListTile(
                              title: Text(L10n.of(context)!.editChatPermissions),
                              subtitle: Text(
                                L10n.of(context)!.whoCanPerformWhichAction,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                foregroundColor: iconColor,
                                child: const Icon(
                                  Icons.edit_attributes_outlined,
                                ),
                              ),
                              onTap: () => VRouter.of(context).to('permissions'),
                            ),
                          ],
                          const Divider(height: 1),
                          ListTile(
                            title: Text(
                              actualMembersCount > 1
                                  ? L10n.of(context)!.countParticipants(
                                      actualMembersCount.toString(),
                                    )
                                  : L10n.of(context)!.emptyChat,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          room.canInvite
                              ? ListTile(
                                  title: Text(L10n.of(context)!.inviteContact),
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    radius: Avatar.defaultSize / 2,
                                    child: const Icon(Icons.add_outlined),
                                  ),
                                  onTap: () => VRouter.of(context).to('invite'),
                                )
                              : const SizedBox.shrink(),
                        ],
                      )
                    : i < controller.members!.length + 1
                        ? ParticipantListItem(controller.members![i - 1])
                        : ListTile(
                            title: Text(
                              L10n.of(context)!.loadCountMoreParticipants(
                                (actualMembersCount - controller.members!.length).toString(),
                              ),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.grey,
                              ),
                            ),
                            onTap: controller.requestMoreMembersAction,
                          ),
              ),
            ),
          ),
        );
      },
    );
  }
}
