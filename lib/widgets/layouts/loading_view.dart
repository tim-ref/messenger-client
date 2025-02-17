/*
 * Modified by akquinet GmbH on 05.02.2025
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/utils/update_checker_no_store.dart';
import 'package:fluffychat/widgets/layouts/empty_page.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

import '../../config/app_config.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await UpdateCheckerNoStore(context).checkUpdate();

        final client = Matrix.of(context).client;
        // don't send presence through sync
        client.syncPresence = PresenceType.offline;

        final isLoggedIn = Matrix.of(context).widget.clients.any(
              (client) => client.onLoginStateChanged.value == LoginState.loggedIn,
            );

        if (isLoggedIn) {
          if (client.userID != null) {
            client.setPresence(
              client.userID!,
              AppConfig.sendPresenceUpdates ? PresenceType.online : PresenceType.offline,
            );
          }
        }
        VRouter.of(context).to(
          isLoggedIn ? '/rooms' : '/home',
          queryParameters: VRouter.of(context).queryParameters,
        );
      },
    );
    return const EmptyPage(loading: true);
  }
}
