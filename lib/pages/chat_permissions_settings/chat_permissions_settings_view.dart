/*
 * Modified by akquinet GmbH on 21.11.2024
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/pages/chat_permissions_settings/chat_permissions_settings.dart';
import 'package:fluffychat/pages/chat_permissions_settings/permission_list_tile.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

class ChatPermissionsSettingsView extends StatelessWidget {
  final ChatPermissionsSettingsController controller;

  const ChatPermissionsSettingsView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: VRouter.of(context).path.startsWith('/spaces/')
            ? null
            : IconButton(
                icon: const Icon(Icons.close_outlined),
                onPressed: () => VRouter.of(context).toSegments(['rooms', controller.roomId!]),
              ),
        title: Text(L10n.of(context)!.editChatPermissions),
      ),
      body: MaxWidthBody(
        withScrolling: true,
        child: StreamBuilder(
          stream: controller.onChanged,
          builder: (context, _) {
            final roomId = controller.roomId;
            final room = roomId == null ? null : Matrix.of(context).client.getRoomById(roomId);
            if (room == null) {
              return Center(child: Text(L10n.of(context)!.noRoomsFound));
            }
            final powerLevelsContent = Map<String, dynamic>.from(
              room.getState(EventTypes.RoomPowerLevels)!.content,
            );
            final powerLevels = Map<String, dynamic>.from(powerLevelsContent)
              ..removeWhere((k, v) => v is! int);
            final eventsPowerLevels = Map<String, dynamic>.from(powerLevelsContent['events'] ?? {})
              ..removeWhere((k, v) => v is! int);
            return Column(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final entry in powerLevels.entries)
                      PermissionsListTile(
                        permissionKey: entry.key,
                        permission: entry.value,
                        onTap: () => controller.editPowerLevel(
                          context,
                          entry.key,
                          entry.value,
                        ),
                      ),
                    const Divider(thickness: 1),
                    ListTile(
                      title: Text(
                        L10n.of(context)!.notifications,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        const key = 'rooms';
                        final int value = powerLevelsContent.containsKey('notifications')
                            ? powerLevelsContent['notifications']['rooms'] ?? 0
                            : 0;
                        return PermissionsListTile(
                          permissionKey: key,
                          permission: value,
                          category: 'notifications',
                          onTap: () => controller.editPowerLevel(
                            context,
                            key,
                            value,
                            category: 'notifications',
                          ),
                        );
                      },
                    ),
                    const Divider(thickness: 1),
                    ListTile(
                      title: Text(
                        L10n.of(context)!.configureChat,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    for (final entry in eventsPowerLevels.entries)
                      PermissionsListTile(
                        permissionKey: entry.key,
                        category: 'events',
                        permission: entry.value,
                        onTap: () => controller.editPowerLevel(
                          context,
                          entry.key,
                          entry.value,
                          category: 'events',
                        ),
                      ),
                    if (room.canSendEvent(EventTypes.RoomTombstone)) ...{
                      const Divider(thickness: 1),
                      FutureBuilder<Capabilities>(
                        future: room.client.getCapabilities(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            );
                          }
                          final String roomVersion = room
                                  .getState(EventTypes.RoomCreate)!
                                  .content
                                  .tryGet('room_version') ??
                              '1';

                          return ListTile(
                            title: Text(
                              '${L10n.of(context)!.roomVersion}: $roomVersion',
                            ),
                            onTap: () => controller.updateRoomAction(snapshot.data!),
                          );
                        },
                      ),
                    },
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
