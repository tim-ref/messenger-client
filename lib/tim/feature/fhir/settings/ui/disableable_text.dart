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

/// Text that turns grey when not [enabled].
class DisableableText extends StatelessWidget {
  const DisableableText(
    this.data, {
    super.key,
    required this.enabled,
  });

  final String data;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: enabled
          ? Theme.of(context).textTheme.bodyLarge
          : Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).disabledColor,
              ),
    );
  }
}
