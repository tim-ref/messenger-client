/*
 * Modified by akquinet GmbH on 16.10.2023
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'utils/test_client.dart';

void main() async {
  test('Check for missing /command hints', () async {
    final translated =
        jsonDecode(File('assets/l10n/intl_en.arb').readAsStringSync())
            .keys
            .where((String k) => k.startsWith('commandHint_'))
            .map((k) => k.replaceFirst('commandHint_', ''));
    final commands = (await prepareTestClient()).commands.keys;
    final missing = commands.where((c) => !translated.contains(c)).toList();

    expect(
      0,
      missing.length,
      reason:
          'missing hints for $missing\nAdding hints? See scripts/generate_command_hints_glue.sh',
    );
  });
}
