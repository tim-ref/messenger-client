/*
 * TIM-Referenzumgebung
 * Copyright (C) 2025 – akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

import '../../invite_rejection_policy.dart';
import '../../../../../utils/get_label_for_user_group.dart';

class AddGroupsDropdown extends StatelessWidget {
  const AddGroupsDropdown({
    Key? key,
    this.onGroupSelected,
  }) : super(key: key);

  /// Callback that notifies when a group is selected.
  final ValueChanged<String>? onGroupSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        onGroupSelected?.call(value);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(key: const Key("GroupItemInsuredPerson"),
          value: UserGroup.isInsuredPerson.name,
          child: Text(getLabelForUserGroup(L10n.of(context)!, UserGroup.isInsuredPerson.name)),
        ),
      ],
      // Wrap the OutlinedButton in IgnorePointer so the PopupMenuButton handles taps.
      child: IgnorePointer(
        child: OutlinedButton(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
            ),
          ),
          onPressed: () {},
          child:  Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(L10n.of(context)!.inviteRejectionSettingsAddGroupButton),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
