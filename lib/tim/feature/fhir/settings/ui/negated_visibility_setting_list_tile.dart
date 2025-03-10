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

import 'package:fluffychat/tim/feature/fhir/settings/ui/disableable_text.dart';
import 'package:fluffychat/tim/feature/fhir/settings/ui/visibility_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

/// ListTile with a [Switch], [DisableableText], and a [VisibilityIcon].
/// When [visibilityOff] is true, the Switch is on, and a 'not visible' icon is shown.
class NegatedVisibilitySettingListTile extends StatelessWidget {
  const NegatedVisibilitySettingListTile({
    super.key,
    required this.visibilityOff,
    required this.onChanged,
  });

  final bool visibilityOff;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: visibilityOff,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      secondary: VisibilityIcon(
        visibilityOn: !visibilityOff,
        enabled: onChanged != null,
      ),
      title: DisableableText(
        L10n.of(context)!.timFhirInsureeVisibilityLabel,
        enabled: onChanged != null,
      ),
    );
  }
}
