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
import 'package:fluffychat/tim/shared/tim_auth_token_with_expiry_timestamp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('can tell if the token has expired', () {
    final token = TimAuthTokenWithExpiryTimestamp.from(
      TimAuthToken(
        accessToken: '',
        tokenType: '',
        matrixServerName: '',
        expiresIn: -1,
      ),
    );

    expect(token.isExpired(), isTrue);
  });

  test('can tell if the token has not expired yet', () {
    final token = TimAuthTokenWithExpiryTimestamp.from(
      TimAuthToken(
        accessToken: '',
        tokenType: '',
        matrixServerName: '',
        expiresIn: 1,
      ),
    );

    expect(token.isExpired(), isFalse);
  });
}
