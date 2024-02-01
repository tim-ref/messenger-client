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

import 'package:flutter/material.dart';

extension StringColor on String {
  static final _colorCache = <String, Map<double, Color>>{};

  Color _getColorLight(double light) {
    var number = 0.0;
    for (var i = 0; i < length; i++) {
      number += codeUnitAt(i);
    }
    number = (number % 12) * 25.5;
    return HSLColor.fromAHSL(1, number, 1, light).toColor();
  }

  Color get color {
    _colorCache[this] ??= {};
    return _colorCache[this]![0.35] ??= _getColorLight(0.35);
  }

  Color get darkColor {
    _colorCache[this] ??= {};
    return _colorCache[this]![0.2] ??= _getColorLight(0.2);
  }

  Color get lightColorText {
    _colorCache[this] ??= {};
    return _colorCache[this]![0.7] ??= _getColorLight(0.7);
  }

  Color get lightColorAvatar {
    _colorCache[this] ??= {};
    return _colorCache[this]![0.4] ??= _getColorLight(0.4);
  }
}
