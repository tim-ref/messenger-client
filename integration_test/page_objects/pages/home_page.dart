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

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_test/src/finders.dart';
import 'package:flutter_test/src/widget_tester.dart';

import '../page_identifiable.dart';
import '../page_object.dart';

class HomePage extends PageObject implements PageIdentifiable {
  HomePage(L10n localizations, WidgetTester tester)
      : super(localizations, tester);

  @override
  Finder get identifier => newChatButton();

  Finder newChatButton() {
    return find.text(localizations.newChat);
  }
}
