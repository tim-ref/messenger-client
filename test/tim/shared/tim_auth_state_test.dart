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
import 'package:fluffychat/tim/shared/tim_auth_state.dart';
import 'package:fluffychat/tim/shared/tim_auth_token.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'Should correctly determine validity for hbaToken with expiryDate in the future',
      () {
    // given
    final TimAuthToken hbaToken = setupToken(
      DateTime.now().add(const Duration(hours: 2)),
    );
    final authState = TimAuthState();
    authState.hbaToken = hbaToken;

    // expect
    expect(authState.hbaTokenValid(), equals(true));
  });

  test(
      'Should correctly determine validity for hbaToken with expiryDate in the past',
      () {
    // given
    final TimAuthToken hbaToken = setupToken(
      DateTime(2023, 6, 26, 0, 0, 0, 0),
    );
    final authState = TimAuthState();
    authState.hbaToken = hbaToken;

    // expect
    expect(authState.hbaTokenValid(), equals(false));
  });
  test('Should correctly dispose hbaToken', () {
    // given
    final TimAuthToken hbaToken = setupToken(
      DateTime(2023, 6, 26, 0, 0, 0, 0),
    );
    final authState = TimAuthState();
    authState.hbaToken = hbaToken;

    // when
    authState.disposeHbaToken();

    // then
    expect(authState.hbaToken, equals(null));
  });
}

TimAuthToken setupToken(DateTime expiryDate) {
  final expiryTimeStamp = expiryDate.millisecondsSinceEpoch ~/ 1000;
  final jwt = JWT(
    {
      'id': 123,
      'exp': expiryTimeStamp,
      'server': {
        'id': '3e4fc296',
        'loc': 'euw-2',
      }
    },
    issuer: 'unittest',
  );
  final token = jwt.sign(SecretKey('unittest'));
  return TimAuthToken(accessToken: token, tokenType: 'bearer', expiresIn: 3600);
}
