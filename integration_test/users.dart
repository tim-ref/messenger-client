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

abstract class Users {
  const Users._();

  static const user1 = User(
    String.fromEnvironment(
      'USER1_NAME',
      defaultValue: 'alice',
    ),
    String.fromEnvironment(
      'USER1_PW',
      defaultValue: 'AliceInWonderland',
    ),
  );
  static const user2 = User(
    String.fromEnvironment(
      'USER2_NAME',
      defaultValue: 'bob',
    ),
    String.fromEnvironment(
      'USER2_PW',
      defaultValue: 'JoWirSchaffenDas',
    ),
  );
}

class User {
  final String name;
  final String password;

  const User(this.name, this.password);
}

const homeserver = 'http://${const String.fromEnvironment(
  'HOMESERVER',
  defaultValue: 'localhost',
)}';

