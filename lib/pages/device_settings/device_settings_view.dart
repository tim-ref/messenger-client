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

import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:fluffychat/pages/device_settings/device_settings.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'user_device_list_item.dart';

class DevicesSettingsView extends StatelessWidget {
  final DevicesSettingsController controller;

  const DevicesSettingsView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(L10n.of(context)!.devices),
      ),
      body: MaxWidthBody(
        child: FutureBuilder<bool>(
          future: controller.loadUserDevices(context),
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.error_outlined),
                    Text(snapshot.error.toString()),
                  ],
                ),
              );
            }
            if (!snapshot.hasData || controller.devices == null) {
              return const Center(
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              );
            }
            return ListView.builder(
              itemCount: controller.notThisDevice.length + 1,
              itemBuilder: (BuildContext context, int i) {
                if (i == 0) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (controller.thisDevice != null)
                        UserDeviceListItem(
                          controller.thisDevice!,
                          rename: controller.renameDeviceAction,
                          remove: (d) => controller.removeDevicesAction([d]),
                          verify: controller.verifyDeviceAction,
                          block: controller.blockDeviceAction,
                          unblock: controller.unblockDeviceAction,
                        ),
                      const Divider(height: 1),
                      if (controller.notThisDevice.isNotEmpty)
                        ListTile(
                          title: Text(
                            controller.errorDeletingDevices ??
                                L10n.of(context)!.removeAllOtherDevices,
                            style: const TextStyle(color: Colors.red),
                          ),
                          trailing: controller.loadingDeletingDevices
                              ? const CircularProgressIndicator.adaptive(
                                  strokeWidth: 2,
                                )
                              : const Icon(Icons.delete_outline),
                          onTap: controller.loadingDeletingDevices
                              ? null
                              : () => controller.removeDevicesAction(
                                    controller.notThisDevice,
                                  ),
                        )
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(L10n.of(context)!.noOtherDevicesFound),
                          ),
                        ),
                      const Divider(height: 1),
                    ],
                  );
                }
                i--;
                return UserDeviceListItem(
                  controller.notThisDevice[i],
                  rename: controller.renameDeviceAction,
                  remove: (d) => controller.removeDevicesAction([d]),
                  verify: controller.verifyDeviceAction,
                  block: controller.blockDeviceAction,
                  unblock: controller.unblockDeviceAction,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
