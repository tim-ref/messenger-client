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

import 'package:fluffychat/utils/matrix_uri_validation.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  test('given valid matrix user uri, should return is valid', () {
    const uri = 'matrix:u/dr_bob_tiger_1:testserver.test?action=chat';

    expect(checkExpectedMatrixUriIsValid(uri), isTrue);
  });

  test('given not accepted uri, should return invalid', () {
    const uri = 'xmpp:alice@example.com';

    expect(checkExpectedMatrixUriIsValid(uri), isFalse);
  });

  test('given valid matrix room uri, should return is valid', () {
    const uri = 'matrix:r/somewhere:example.org';

    expect(checkExpectedMatrixUriIsValid(uri), isTrue);
  });

  test('given valid matrix roomid uri, should return is valid', () {
    const uri = 'matrix:roomid/somewhere:example.org?via=elsewhere.ca';

    expect(checkExpectedMatrixUriIsValid(uri), isTrue);
  });

  test('given valid matrix event uri, should return is valid', () {
    const uri = 'matrix:roomid/somewhere:example.org/e/event?via=elsewhere.ca';

    expect(checkExpectedMatrixUriIsValid(uri), isTrue);
  });

  test('given valid matrix.to user uri, should return is valid', () {
    const uri = 'https://matrix.to/#/@my_user_01:home.ser.ver00001';

    expect(checkExpectedMatrixUriIsValid(uri), isTrue);
  });
}
