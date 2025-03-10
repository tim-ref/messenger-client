/*
 * TIM-Referenzumgebung
 * Copyright (C) 2025 - akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';

/// Icon showing an open eye when [visibilityOn] is true, and a closed one otherwise.
/// The icon turns grey when not [enabled].
class VisibilityIcon extends StatelessWidget {
  const VisibilityIcon({
    super.key,
    required this.visibilityOn,
    required this.enabled,
  });

  final bool visibilityOn;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Icon(
      visibilityOn ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      size: 34,
      color: enabled ? null : Theme.of(context).disabledColor,
    );
  }
}
