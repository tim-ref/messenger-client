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

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:fluffychat/tim/shared/tim_auth_token.dart';

class TimAuthState {
  TimAuthToken? hbaToken;

  bool hbaTokenValid() {
    if (hbaToken == null) {
      return false;
    }
    final jwt = JWT.decode(hbaToken!.accessToken);
    final tokenExpiry = DateTime.fromMillisecondsSinceEpoch(
      _convertTimestampToMilliseconds(jwt),
    ).toUtc();
    return tokenExpiry.isAfter(DateTime.now());
  }

  void disposeHbaToken() {
    hbaToken = null;
  }

  _convertTimestampToMilliseconds(JWT jwt) => jwt.payload['exp'] * 1000 as int;
}
