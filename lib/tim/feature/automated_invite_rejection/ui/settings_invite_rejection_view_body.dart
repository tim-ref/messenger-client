/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - 2025 - akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/tim/feature/automated_invite_rejection/ui/settings_invite_rejection_controller.dart';
import 'package:fluffychat/tim/feature/automated_invite_rejection/ui/settings_invite_rejection_exception_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:provider/provider.dart';

import 'elements/add_group_widget.dart';

class SettingsInviteRejectionViewBody extends StatefulWidget {
  const SettingsInviteRejectionViewBody({super.key});

  @override
  State<SettingsInviteRejectionViewBody> createState() => _SettingsInviteRejectionViewBodyState();
}

class _SettingsInviteRejectionViewBodyState extends State<SettingsInviteRejectionViewBody> {
  final TextEditingController _exceptionFieldController = TextEditingController();
  late SettingsInviteRejectionController _controller;

  @override
  Widget build(BuildContext context) {
    _controller = context.watch<SettingsInviteRejectionController>();
    if (_controller.inviteRejectionPolicy == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          L10n.of(context)!.inviteRejectionSettingsDefaultSettingHeader,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        RadioListTile(
          key: const ValueKey("inviteRejectionSettingsAllowAllOption"),
          value: InviteRejectionPolicyType.allowAll,
          groupValue: _controller.defaultSetting,
          onChanged: (value) => _controller.setDefaultSetting(value!),
          title: Text(L10n.of(context)!.inviteRejectionSettingsDefaultSettingAllowAllOption),
        ),
        RadioListTile(
          key: const ValueKey("inviteRejectionSettingsBlockAllOption"),
          value: InviteRejectionPolicyType.blockAll,
          groupValue: _controller.defaultSetting,
          onChanged: (value) => _controller.setDefaultSetting(value!),
          title: Text(L10n.of(context)!.inviteRejectionSettingsDefaultSettingBlockAllOption),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          L10n.of(context)!.inviteRejectionSettingsExceptionsHeader,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 8,
        ),
        Semantics(
          label: "inviteRejectionSettingsAddExceptionField",
          container: true,
          textField: true,
          child: TextField(
            decoration: InputDecoration(
              filled: false,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              label: Text(L10n.of(context)!.inviteRejectionSettingsExceptionsAddExceptionFieldHint),
            ),
            controller: _exceptionFieldController,
            onSubmitted: (_) => _addException(),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AddGroupsDropdown(
              onGroupSelected: _controller.handleGroupSelect,
            ),
            FilledButton(
              key: const ValueKey("inviteRejectionSettingsAddExceptionButton"),
              onPressed: _addException,
              child:
                  Text(L10n.of(context)!.inviteRejectionSettingsExceptionsAddExceptionButtonLabel),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        const Expanded(
          child: SettingsInviteRejectionExceptionListView(),
        ),
      ],
    );
  }

  Future<void> _addException() async {
    await _controller.addExceptionEntry(_exceptionFieldController.text);
    _exceptionFieldController.clear();
  }
}
