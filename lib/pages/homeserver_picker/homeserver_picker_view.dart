/*
 * Modified by akquinet GmbH on 01.11.2024
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pages/homeserver_picker/homeserver_picker.dart';
import 'package:fluffychat/tim/feature/tim_version/tim_version_switcher.dart';
import 'package:fluffychat/widgets/layouts/login_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../utils/platform_infos.dart';

class HomeserverPickerView extends StatelessWidget {
  final HomeserverPickerController controller;

  const HomeserverPickerView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoginScaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  height: 190,
                  child: Image.asset('assets/akquinet-logo.png'),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Semantics(
                    label: "homeserver",
                    container: true,
                    textField: true,
                    child: TextField(
                      focusNode: controller.homeserverFocusNode,
                      controller: controller.homeserverController,
                      decoration: InputDecoration(
                        prefixText: '${L10n.of(context)!.homeserver}: ',
                        hintText: L10n.of(context)!.enterYourHomeserver,
                        suffixIcon: const Icon(Icons.search),
                        errorText: controller.error,
                        fillColor: Theme.of(context).colorScheme.background,
                      ),
                      readOnly: !AppConfig.allowOtherHomeservers,
                      onSubmitted: (_) => controller.checkHomeserverAction(),
                      autocorrect: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextButton(
                    onPressed: () => PlatformInfos.showLicenseDialog(context),
                    child: Text(L10n.of(context)!.about),
                  ),
                  TextButton(
                    onPressed: () => launchUrlString(AppConfig.privacyUrl),
                    child: Text(L10n.of(context)!.privacy),
                  ),
                  TextButton(
                    onPressed: controller.restoreBackup,
                    child: Text(L10n.of(context)!.hydrate),
                  ),
                  Semantics(
                    label: "loginButton",
                    container: true,
                    button: true,
                    child: Hero(
                      tag: 'loginButton',
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: controller.isLoading ? null : controller.checkHomeserverAction,
                        icon: const Icon(Icons.start_outlined),
                        label:
                            controller.isLoading ? const LinearProgressIndicator() : Text(L10n.of(context)!.letsStart),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const TimVersionSwitcher(),
        ],
      ),
    );
  }

  AppBar? _buildAppBar() {
    return controller.widget.enableBackButton
        ? AppBar(
            leading: const BackButton(),
            automaticallyImplyLeading: true,
          )
        : null;
  }
}
