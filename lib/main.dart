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

import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluffychat/utils/client_manager.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:matrix/matrix.dart';
import 'package:universal_html/html.dart' as html;

import 'tim/tim_constants.dart';
import 'utils/background_push.dart';
import 'widgets/fluffy_chat_app.dart';
import 'widgets/lock_screen.dart';

void main() async {
  if (const bool.fromEnvironment(enableTestDriver)) {
    enableFlutterDriverExtension();
  }

  // Our background push shared isolate accesses flutter-internal things very early in the startup proccess
  // To make sure that the parts of flutter needed are started up already, we need to ensure that the
  // widget bindings are initialized already.
  WidgetsFlutterBinding.ensureInitialized();

  Logs().nativeColors = !PlatformInfos.isIOS;
  final clients = await ClientManager.getClients();

  // Preload first client
  final firstClient = clients.firstOrNull;
  await firstClient?.roomsLoading;
  await firstClient?.accountDataLoading;

  if (PlatformInfos.isMobile) {
    try {
      await Firebase.initializeApp();
      BackgroundPush.clientOnly(clients.first);
    } catch (exception, stacktrace) {
      Logs().e('Error Setting up Firebase', exception, stacktrace);
    }
  }

  final queryParameters = <String, String>{};
  if (kIsWeb) {
    queryParameters
        .addAll(Uri.parse(html.window.location.href).queryParameters);
  }

  runApp(
    PlatformInfos.isMobile
        ? AppLock(
            builder: (args) => FluffyChatApp(
              clients: clients,
              queryParameters: queryParameters,
            ),
            lockScreen: const LockScreen(),
            enabled: false,
          )
        : FluffyChatApp(
            clients: clients,
            queryParameters: queryParameters,
          ),
  );
}
