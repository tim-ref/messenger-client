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

/// these describes all the platform specific functions that we need to communicate with the autenticator app
/// we will only provide an implementation for web/windows
abstract class AuthenticatorApi {
  /// open the authenticator app
  void openAuthenticator(String challengePath);

  /// publish to authCode to the messenger-app after receiving it via callback. this will work across browser tabs
  void publishAuthCode(String authCode);

  /// await for publishing of the auth code in another browser tab
  Future<String> waitForAuthCode();
}
