/*
 * Modified by akquinet GmbH on 13.11.2024
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/utils/fluffy_share.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vrouter/vrouter.dart';

import 'settings.dart';

class SettingsView extends StatelessWidget {
  final SettingsController controller;

  const SettingsView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showChatBackupBanner = controller.showChatBackupBanner;
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(
          key: const ValueKey('CloseSettingsButton'),
          onPressed: VRouter.of(context).pop,
        ),
        title: Text(L10n.of(context)!.settings),
        actions: [
          TextButton.icon(
            key: const ValueKey('logoutButton'),
            onPressed: controller.logoutAction,
            label: Text(L10n.of(context)!.logout),
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: ListTileTheme(
        iconColor: Theme.of(context).colorScheme.onBackground,
        child: ListView(
          key: const Key('SettingsListViewContent'),
          children: <Widget>[
            FutureBuilder<Profile>(
              future: controller.profileFuture,
              builder: (context, snapshot) {
                final profile = snapshot.data;
                final mxid =
                    Matrix.of(context).client.userID ?? L10n.of(context)!.user;
                final displayname =
                    profile?.displayName ?? mxid.localpart ?? mxid;
                return Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Stack(
                        children: [
                          Material(
                            elevation: Theme.of(context)
                                    .appBarTheme
                                    .scrolledUnderElevation ??
                                4,
                            shadowColor:
                                Theme.of(context).appBarTheme.shadowColor,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Theme.of(context).dividerColor,
                              ),
                              borderRadius: BorderRadius.circular(
                                Avatar.defaultSize * 2.5,
                              ),
                            ),
                            child: Avatar(
                              mxContent: profile?.avatarUrl,
                              name: displayname,
                              size: Avatar.defaultSize * 2.5,
                              fontSize: 18 * 2.5,
                            ),
                          ),
                          if (profile != null)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: FloatingActionButton.small(
                                onPressed: controller.setAvatarAction,
                                heroTag: null,
                                child: const Icon(Icons.camera_alt_outlined),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayname,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            //  style: const TextStyle(fontSize: 18),
                          ),
                          TextButton.icon(
                            onPressed: () => FluffyShare.share(mxid, context),
                            icon: const Icon(
                              Icons.copy_outlined,
                              size: 14,
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                            label: Text(
                              mxid,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              //    style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const Divider(thickness: 1),
            if (showChatBackupBanner == null)
              ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: Text(L10n.of(context)!.chatBackup),
                trailing: const CircularProgressIndicator.adaptive(),
              )
            else
              SwitchListTile.adaptive(
                key: const ValueKey("keyBackupSwitch"),
                controlAffinity: ListTileControlAffinity.trailing,
                value: controller.showChatBackupBanner == false,
                secondary: const Icon(Icons.backup_outlined),
                title: Text(L10n.of(context)!.chatBackup),
                onChanged: controller.firstRunBootstrapAction,
              ),
            const Divider(thickness: 1),
            ListTile(
              leading: const Icon(Icons.format_paint_outlined),
              title: Text(L10n.of(context)!.changeTheme),
              onTap: () => VRouter.of(context).to('/settings/style'),
              trailing: const Icon(Icons.chevron_right_outlined),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: Text(L10n.of(context)!.notifications),
              onTap: () => VRouter.of(context).to('/settings/notifications'),
              trailing: const Icon(Icons.chevron_right_outlined),
            ),
            ListTile(
              leading: const Icon(Icons.devices_outlined),
              title: Text(L10n.of(context)!.devices),
              onTap: () => VRouter.of(context).to('/settings/devices'),
              trailing: const Icon(Icons.chevron_right_outlined),
            ),
            ListTile(
              leading: const Icon(Icons.forum_outlined),
              title: Text(L10n.of(context)!.chat),
              onTap: () => VRouter.of(context).to('/settings/chat'),
              trailing: const Icon(Icons.chevron_right_outlined),
            ),
            ListTile(
              key: const ValueKey("fhirDirectory"),
              leading: const Icon(Icons.folder_copy_outlined),
              title: Text(L10n.of(context)!.timFhirAccount),
              onTap: () => VRouter.of(context).to('/settings/fhirAccount'),
              trailing: const Icon(Icons.chevron_right_outlined),
            ),
            ListTile(
              key: const ValueKey("securitySettings"),
              leading: const Icon(Icons.shield_outlined),
              title: Text(L10n.of(context)!.security),
              onTap: () => VRouter.of(context).to('/settings/security'),
              trailing: const Icon(Icons.chevron_right_outlined),
            ),
            const Divider(thickness: 1),
            ListTile(
              leading: const Icon(Icons.help_outline_outlined),
              title: Text(L10n.of(context)!.help),
              onTap: () => launchUrlString(AppConfig.supportUrl),
              trailing: const Icon(Icons.open_in_new_outlined),
            ),
            ListTile(
              leading: const Icon(Icons.shield_sharp),
              title: Text(L10n.of(context)!.privacy),
              onTap: () => launchUrlString(AppConfig.privacyUrl),
              trailing: const Icon(Icons.open_in_new_outlined),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(L10n.of(context)!.about),
              onTap: () => PlatformInfos.showLicenseDialog(context),
              trailing: const Icon(Icons.chevron_right_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
