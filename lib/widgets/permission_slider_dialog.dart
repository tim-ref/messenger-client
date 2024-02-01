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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

enum PermissionLevel {
  user,
  moderator,
  admin,
  custom,
}

extension on PermissionLevel {
  String toLocalizedString(BuildContext context) {
    switch (this) {
      case PermissionLevel.user:
        return L10n.of(context)!.user;
      case PermissionLevel.moderator:
        return L10n.of(context)!.moderator;
      case PermissionLevel.admin:
        return L10n.of(context)!.admin;
      case PermissionLevel.custom:
      default:
        return L10n.of(context)!.custom;
    }
  }
}

Future<int?> showPermissionChooser(
  BuildContext context, {
  int currentLevel = 0,
}) async {
  final permissionLevel = await showConfirmationDialog(
    context: context,
    title: L10n.of(context)!.setPermissionsLevel,
    actions: PermissionLevel.values
        .map(
          (level) => AlertDialogAction(
            key: level,
            label: level.toLocalizedString(context),
          ),
        )
        .toList(),
  );
  if (permissionLevel == null) return null;

  switch (permissionLevel) {
    case PermissionLevel.user:
      return 0;
    case PermissionLevel.moderator:
      return 50;
    case PermissionLevel.admin:
      return 100;
    case PermissionLevel.custom:
      final customLevel = await showTextInputDialog(
        context: context,
        title: L10n.of(context)!.setPermissionsLevel,
        textFields: [
          DialogTextField(
            initialText: currentLevel.toString(),
            keyboardType: TextInputType.number,
            autocorrect: false,
          )
        ],
      );
      if (customLevel == null) return null;
      return int.tryParse(customLevel.first);
  }
}
