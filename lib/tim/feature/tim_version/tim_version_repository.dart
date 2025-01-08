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
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the active TI-M version setting.
///
/// Use [TimVersionService] instead.
class TimVersionRepository {
  static const _key = "active TI-M version";

  Future<void> set(TimVersion version) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_key, version.index);
  }

  Future<TimVersion?> get() async {
    final prefs = await SharedPreferences.getInstance();
    final versionIndex = prefs.getInt(_key);
    if (versionIndex != null) {
      return TimVersion.values[versionIndex];
    } else {
      return null;
    }
  }

  Future<TimVersion> getOrDefault(TimVersion defaultVersion) async {
    final prefs = await SharedPreferences.getInstance();
    final versionIndex = prefs.getInt(_key);
    if (versionIndex != null) {
      return TimVersion.values[versionIndex];
    } else {
      return defaultVersion;
    }
  }
}
