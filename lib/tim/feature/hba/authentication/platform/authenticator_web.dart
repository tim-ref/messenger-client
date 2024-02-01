/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:matrix/matrix.dart';

import 'package:fluffychat/tim/feature/hba/authentication/platform/authenticator_api.dart';

class AuthenticatorImpl extends AuthenticatorApi {
  final broadcastChannel = html.BroadcastChannel("vzd-auth-code");

  @override
  void openAuthenticator(String challengePath) {
    Logs().i('Open authenticator app');

    html.window.open(
        'authenticator://?challenge_path=$challengePath&callback=tim', 'todo');

    Logs().i('Opened authenticator app');
  }

  @override
  void publishAuthCode(String authCode) {
    Logs().i('Publishing authCode $authCode');

    broadcastChannel.postMessage(authCode);
    broadcastChannel.close();
  }

  @override
  Future<String> waitForAuthCode() {
    Logs().i("Waiting for auth code on broadcast channel");
    return broadcastChannel.onMessage.first.then((value) {
      Logs().i("Got auth code via broadbast channel: ${value.data}");
      return value.data;
    });
  }
}
