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

import 'package:fluffychat/utils/fluffy_share.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

import '../../utils/matrix_sdk_extensions/presence_extension.dart';
import '../../widgets/matrix.dart';
import '../../widgets/user_avatar.dart';
import 'user_bottom_sheet.dart';

class UserBottomSheetView extends StatelessWidget {
  final UserBottomSheetController controller;

  const UserBottomSheetView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = controller.widget.user;
    final client = Matrix.of(context).client;
    final presence = client.presences[user.id];
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: CloseButton(
            onPressed: Navigator.of(context, rootNavigator: false).pop,
          ),
          title: Text(user.calcDisplayname()),
          actions: [
            if (user.id != client.userID)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton.icon(
                  onPressed: () => controller.participantAction(UserBottomSheetAction.message),
                  icon: const Icon(Icons.forum_outlined),
                  label: Text(L10n.of(context)!.sendAMessage),
                ),
              ),
          ],
        ),
        body: ListView(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: UserAvatar(
                    user: user,
                    size: Avatar.defaultSize * 2,
                    fontSize: 24,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(right: 16.0),
                    title: Text(user.id),
                    subtitle:
                        presence == null ? null : Text(presence.getLocalizedLastActiveAgo(context)),
                    trailing: IconButton(
                      icon: Icon(Icons.adaptive.share),
                      onPressed: () => FluffyShare.share(
                        user.id,
                        context,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (controller.widget.onMention != null)
              ListTile(
                leading: const Icon(Icons.alternate_email_outlined),
                title: Text(L10n.of(context)!.mention),
                onTap: () => controller.participantAction(UserBottomSheetAction.mention),
              ),
            if (user.canChangePowerLevel)
              ListTile(
                title: Text(L10n.of(context)!.setPermissionsLevel),
                leading: const Icon(Icons.edit_attributes_outlined),
                onTap: () => controller.participantAction(UserBottomSheetAction.permission),
              ),
            if (user.canKick)
              ListTile(
                title: Text(L10n.of(context)!.kickFromChat),
                leading: const Icon(Icons.exit_to_app_outlined),
                onTap: () => controller.participantAction(UserBottomSheetAction.kick),
              ),
            if (user.canBan && user.membership != Membership.ban)
              ListTile(
                title: Text(L10n.of(context)!.banFromChat),
                leading: const Icon(Icons.warning_sharp),
                onTap: () => controller.participantAction(UserBottomSheetAction.ban),
              )
            else if (user.canBan && user.membership == Membership.ban)
              ListTile(
                title: Text(L10n.of(context)!.unbanFromChat),
                leading: const Icon(Icons.warning_outlined),
                onTap: () => controller.participantAction(UserBottomSheetAction.unban),
              ),
            if (user.id != client.userID && !client.ignoredUsers.contains(user.id))
              ListTile(
                textColor: Theme.of(context).colorScheme.onErrorContainer,
                iconColor: Theme.of(context).colorScheme.onErrorContainer,
                title: Text(L10n.of(context)!.ignore),
                leading: const Icon(Icons.block),
                onTap: () => _ignoreUser(context),
              ),
            if (user.id != client.userID)
              ListTile(
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                title: Text(L10n.of(context)!.reportUser),
                leading: const Icon(Icons.shield_outlined),
                onTap: () => controller.participantAction(UserBottomSheetAction.report),
              ),
          ],
        ),
      ),
    );
  }

  void _ignoreUser(BuildContext context) {
    controller.participantAction(UserBottomSheetAction.ignore, () {
      Navigator.of(context, rootNavigator: false).pop();
    });
  }
}
