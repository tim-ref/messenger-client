/*
 * Modified by akquinet GmbH on 14.03.2025
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/config/setting_keys.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/utils/voip/callkeep_manager.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:fluffychat/widgets/settings_switch_list_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

import 'settings_chat.dart';

class SettingsChatView extends StatelessWidget {
  final SettingsChatController controller;

  const SettingsChatView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final matrixState = Matrix.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(L10n.of(context)!.chat)),
      body: ListTileTheme(
        iconColor: Theme.of(context).textTheme.bodyLarge!.color,
        child: MaxWidthBody(
          withScrolling: true,
          child: Column(
            children: [
              SettingsSwitchListTile.adaptive(
                title: L10n.of(context)!.renderRichContent,
                onChanged: (b) => AppConfig.renderHtml = b,
                storeKey: SettingKeys.renderHtml,
                defaultValue: AppConfig.renderHtml,
              ),
              SettingsSwitchListTile.adaptive(
                title: L10n.of(context)!.hideRedactedEvents,
                onChanged: (b) => AppConfig.hideRedactedEvents = b,
                storeKey: SettingKeys.hideRedactedEvents,
                defaultValue: AppConfig.hideRedactedEvents,
              ),
              SettingsSwitchListTile.adaptive(
                title: L10n.of(context)!.hideUnknownEvents,
                onChanged: (b) => AppConfig.hideUnknownEvents = b,
                storeKey: SettingKeys.hideUnknownEvents,
                defaultValue: AppConfig.hideUnknownEvents,
              ),
              SettingsSwitchListTile.adaptive(
                title: L10n.of(context)!.hideUnimportantStateEvents,
                onChanged: (b) => AppConfig.hideUnimportantStateEvents = b,
                storeKey: SettingKeys.hideUnimportantStateEvents,
                defaultValue: AppConfig.hideUnimportantStateEvents,
              ),
              if (PlatformInfos.isMobile)
                SettingsSwitchListTile.adaptive(
                  title: L10n.of(context)!.autoplayImages,
                  onChanged: (b) => AppConfig.autoplayImages = b,
                  storeKey: SettingKeys.autoplayImages,
                  defaultValue: AppConfig.autoplayImages,
                ),
              const Divider(),
              SettingsSwitchListTile.adaptive(
                title: L10n.of(context)!.sendOnEnter,
                onChanged: (b) => AppConfig.sendOnEnter = b,
                storeKey: SettingKeys.sendOnEnter,
                defaultValue: AppConfig.sendOnEnter,
              ),
              SettingsSwitchListTile.adaptive(
                title: L10n.of(context)!.sendTypingNotifications,
                onChanged: (b) => AppConfig.sendTypingNotifications = b,
                storeKey: SettingKeys.sendTypingNotifications,
                defaultValue: AppConfig.sendTypingNotifications,
              ),
              SettingsSwitchListTile.adaptive(
                key: const Key("public_read_receipts_setting"),
                title: L10n.of(context)!.sendReadReceipts,
                onChanged: (b) => AppConfig.sendPublicReadReceipts = b,
                storeKey: SettingKeys.sendPublicReadReceipts,
                defaultValue: AppConfig.sendPublicReadReceipts,
              ),
              if (matrixState.webrtcIsSupported)
                SettingsSwitchListTile.adaptive(
                  title: L10n.of(context)!.sendPresenceUpdates,
                  onChanged: (newValue) {
                    AppConfig.sendPresenceUpdates = newValue;
                    if (matrixState.client.userID != null) {
                      matrixState.client.syncPresence = newValue ? null : PresenceType.offline;
                      matrixState.client.setPresence(
                        matrixState.client.userID!,
                        AppConfig.sendPresenceUpdates ? PresenceType.online : PresenceType.offline,
                      );
                    }
                  },
                  storeKey: SettingKeys.sendPresenceUpdates,
                  defaultValue: AppConfig.sendPresenceUpdates,
                ),
              if (matrixState.webrtcIsSupported)
                SettingsSwitchListTile.adaptive(
                  title: L10n.of(context)!.experimentalVideoCalls,
                  onChanged: (b) {
                    AppConfig.experimentalVoip = b;
                    matrixState.createVoipPlugin();
                    return;
                  },
                  storeKey: SettingKeys.experimentalVoip,
                  defaultValue: AppConfig.experimentalVoip,
                ),
              if (matrixState.webrtcIsSupported && !kIsWeb)
                ListTile(
                  title: Text(L10n.of(context)!.callingPermissions),
                  onTap: () => CallKeepManager().checkoutPhoneAccountSetting(context),
                  trailing: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(Icons.call),
                  ),
                ),
              SettingsSwitchListTile.adaptive(
                title: L10n.of(context)!.separateChatTypes,
                onChanged: (b) => AppConfig.separateChatTypes = b,
                storeKey: SettingKeys.separateChatTypes,
                defaultValue: AppConfig.separateChatTypes,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
