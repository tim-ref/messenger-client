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

import 'package:fluffychat/tim/shared/tim_services.dart';
import 'package:fluffychat/utils/beautify_string_extension.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:vrouter/vrouter.dart';

import 'settings_security.dart';

class SettingsSecurityView extends StatefulWidget {
  final SettingsSecurityController controller;

  const SettingsSecurityView(this.controller, {Key? key}) : super(key: key);

  @override
  State<SettingsSecurityView> createState() => _SettingsSecurityViewState();
}

class _SettingsSecurityViewState extends State<SettingsSecurityView> {
  late final Future<bool> _showAutomaticInviteRejectionSettings;

  @override
  void initState() {
    super.initState();

    final versionService = context.read<TimServices>().timVersionService;
    _showAutomaticInviteRejectionSettings = versionService.versionFeaturesClientSideInviteRejection();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final matrixClient = Matrix.of(context).client;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n!.security),
        leading: const BackButton(),
      ),
      body: ListTileTheme(
        iconColor: Theme.of(context).colorScheme.onBackground,
        child: MaxWidthBody(
          withScrolling: true,
          child: Column(
            children: [
              FutureBuilder<bool>(
                future: _showAutomaticInviteRejectionSettings,
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return ListTile(
                      key: const ValueKey("inviteRejectionSettingsNavigateButton"),
                      leading: const Icon(Icons.admin_panel_settings_outlined),
                      trailing: const Icon(Icons.chevron_right_outlined),
                      title: Text(l10n.inviteRejectionSettingsNavigationButtonLabel),
                      onTap: () => VRouter.of(context).to('inviteRejection'),
                    );
                  } else {
                    return const SizedBox(height: 0);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.block_outlined),
                trailing: const Icon(Icons.chevron_right_outlined),
                title: Text(l10n.ignoredUsers),
                onTap: () => VRouter.of(context).to('ignorelist'),
              ),
              ListTile(
                leading: const Icon(Icons.password_outlined),
                trailing: const Icon(Icons.chevron_right_outlined),
                title: Text(l10n.changePassword),
                onTap: widget.controller.changePasswordAccountAction,
              ),
              ListTile(
                leading: const Icon(Icons.mail_outlined),
                trailing: const Icon(Icons.chevron_right_outlined),
                title: Text(l10n.passwordRecovery),
                onTap: () => VRouter.of(context).to('3pid'),
              ),
              if (matrixClient.encryption != null) ...{
                const Divider(thickness: 1),
                if (PlatformInfos.isMobile)
                  ListTile(
                    leading: const Icon(Icons.lock_outlined),
                    trailing: const Icon(Icons.chevron_right_outlined),
                    title: Text(l10n.appLock),
                    onTap: widget.controller.setAppLockAction,
                  ),
                ListTile(
                  title: Text(l10n.yourPublicKey),
                  subtitle: Text(
                    matrixClient.fingerprintKey.beautified,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  leading: const Icon(Icons.vpn_key_outlined),
                ),
              },
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.tap_and_play),
                trailing: const Icon(Icons.chevron_right_outlined),
                title: Text(
                  l10n.dehydrate,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: widget.controller.dehydrateAction,
              ),
              ListTile(
                leading: const Icon(Icons.delete_outlined),
                trailing: const Icon(Icons.chevron_right_outlined),
                title: Text(
                  l10n.deleteAccount,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: widget.controller.deleteAccountAction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
