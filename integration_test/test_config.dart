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

import 'package:flutter_test/flutter_test.dart';

import 'page_objects/page_identifiable.dart';

abstract class Users {
  const Users._();
  static const integrationTest = User('integrationtest', 'supersafepassword');
}

class User {
  final String name;
  final String password;

  const User(this.name, this.password);
}

// https://stackoverflow.com/a/33088657
const homeserver = 'https://test1.eu.timref.akquinet.nx2.dev';

extension PageIdentification on WidgetTester {
  void expectToBeAt(PageIdentifiable page) {
    expect(page.identifier, findsOneWidget);
  }
}
