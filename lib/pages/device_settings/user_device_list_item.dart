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

import 'package:flutter/material.dart';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

import '../../utils/date_time_extension.dart';
import '../../utils/matrix_sdk_extensions/device_extension.dart';
import '../../widgets/matrix.dart';

enum UserDeviceListItemAction {
  rename,
  remove,
  verify,
  block,
  unblock,
}

class UserDeviceListItem extends StatelessWidget {
  final Device userDevice;
  final void Function(Device) remove;
  final void Function(Device) rename;
  final void Function(Device) verify;
  final void Function(Device) block;
  final void Function(Device) unblock;

  const UserDeviceListItem(
    this.userDevice, {
    required this.remove,
    required this.rename,
    required this.verify,
    required this.block,
    required this.unblock,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final client = Matrix.of(context).client;
    final keys = client.userDeviceKeys[Matrix.of(context).client.userID]
        ?.deviceKeys[userDevice.deviceId];
    final isOwnDevice = userDevice.deviceId == client.deviceID;

    return ListTile(
      onTap: () async {
        final action = await showModalActionSheet<UserDeviceListItemAction>(
          context: context,
          title: '${userDevice.displayName} (${userDevice.deviceId})',
          actions: [
            SheetAction(
              key: UserDeviceListItemAction.rename,
              label: L10n.of(context)!.changeDeviceName,
            ),
            if (!isOwnDevice && keys != null) ...{
              SheetAction(
                key: UserDeviceListItemAction.verify,
                label: L10n.of(context)!.verifyStart,
              ),
              if (!keys.blocked)
                SheetAction(
                  key: UserDeviceListItemAction.block,
                  label: L10n.of(context)!.blockDevice,
                  isDestructiveAction: true,
                ),
              if (keys.blocked)
                SheetAction(
                  key: UserDeviceListItemAction.unblock,
                  label: L10n.of(context)!.unblockDevice,
                  isDestructiveAction: true,
                ),
            },
            if (!isOwnDevice)
              SheetAction(
                key: UserDeviceListItemAction.remove,
                label: L10n.of(context)!.delete,
                isDestructiveAction: true,
              ),
          ],
        );
        if (action == null) return;
        switch (action) {
          case UserDeviceListItemAction.rename:
            rename(userDevice);
            break;
          case UserDeviceListItemAction.remove:
            remove(userDevice);
            break;
          case UserDeviceListItemAction.verify:
            verify(userDevice);
            break;
          case UserDeviceListItemAction.block:
            block(userDevice);
            break;
          case UserDeviceListItemAction.unblock:
            unblock(userDevice);
            break;
        }
      },
      leading: CircleAvatar(
        foregroundColor: Colors.white,
        backgroundColor: keys == null
            ? Colors.grey[700]
            : keys.blocked
                ? Colors.red
                : keys.verified
                    ? Colors.green
                    : Colors.orange,
        child: Icon(userDevice.icon),
      ),
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              userDevice.displayname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (keys != null)
            Text(
              keys.blocked
                  ? L10n.of(context)!.blocked
                  : keys.verified
                      ? L10n.of(context)!.verified
                      : L10n.of(context)!.unverified,
              style: TextStyle(
                color: keys.blocked
                    ? Colors.red
                    : keys.verified
                        ? Colors.green
                        : Colors.orange,
              ),
            ),
        ],
      ),
      subtitle: Text(
        L10n.of(context)!.lastActiveAgo(
          DateTime.fromMillisecondsSinceEpoch(userDevice.lastSeenTs ?? 0)
              .localizedTimeShort(context),
        ),
        style: const TextStyle(fontWeight: FontWeight.w300),
      ),
    );
  }
}
