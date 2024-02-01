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

import 'package:fluffychat/tim/shared/tim_auth_token.dart';
import 'package:flutter/foundation.dart';

/// A [TimAuthToken] with an expiry timestamp
@immutable
class TimAuthTokenWithExpiryTimestamp {
  /// The TimAuthToken
  final TimAuthToken token;

  /// The token's expiry timestamp
  final DateTime expiresAt;

  /// Primary constructor
  const TimAuthTokenWithExpiryTimestamp(this.token, this.expiresAt);

  /// Constructor that turns a token's expiry duration into an expiry timestamp
  TimAuthTokenWithExpiryTimestamp.from(this.token)
      : expiresAt = DateTime.now().add(Duration(seconds: token.expiresIn));

  /// Has the token's expiration date/time passed?
  bool isExpired() => expiresAt.isBefore(DateTime.now());
}
