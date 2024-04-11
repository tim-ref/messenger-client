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

import 'package:flutter/foundation.dart';

import 'package:http/http.dart';

import 'package:fluffychat/tim/feature/hba/authentication/hba_authentication_dispenser.dart';
import 'package:fluffychat/tim/feature/hba/authentication/hba_authentication_authenticator.dart';
import 'package:fluffychat/tim/feature/hba/authentication/authenticator.dart';
import 'package:fluffychat/tim/feature/hba/authentication/hba_authentication.dart';
import 'package:fluffychat/tim/feature/hba/authentication/vzd_client.dart';

class HbaAuthenticationFactory {
  HbaAuthentication getHbaAuthentication() {
    if (kIsWeb) {
      return HbaAuthenticationAuthenticator(
          Authenticator(), VzdClient(Client()),);
    } else {
      return HbaTokenDispenserAuthentication(Client());
    }
  }
}
