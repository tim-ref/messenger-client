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

import 'package:fluffychat/tim/feature/tim_version/tim_version.dart';
import 'package:fluffychat/tim/feature/tim_version/tim_version_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

void main() {
  late TimVersionRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = TimVersionRepository();
  });

  test('can save and load TI-M classic version', () async {
    await repo.set(TimVersion.classic);
    final resultWithDefault = await repo.getOrDefault(TimVersion.ePA);
    final resultWithoutDefault = await repo.get();

    expect(resultWithDefault, equals(TimVersion.classic));
    expect(resultWithoutDefault, equals(TimVersion.classic));
  });

  test('can save and load TI-M ePA version', () async {
    await repo.set(TimVersion.ePA);
    final resultWithDefault = await repo.getOrDefault(TimVersion.classic);
    final resultWithoutDefault = await repo.get();

    expect(resultWithDefault, equals(TimVersion.ePA));
    expect(resultWithoutDefault, equals(TimVersion.ePA));
  });

  test('can default to TI-M classic version', () async {
    final result = await repo.getOrDefault(TimVersion.classic);

    expect(result, equals(TimVersion.classic));
  });

  test('can default to TI-M ePA version', () async {
    final result = await repo.getOrDefault(TimVersion.ePA);

    expect(result, equals(TimVersion.ePA));
  });
}
