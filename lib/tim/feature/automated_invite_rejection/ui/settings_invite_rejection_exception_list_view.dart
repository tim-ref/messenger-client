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

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:fluffychat/tim/feature/automated_invite_rejection/ui/settings_invite_rejection_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsInviteRejectionExceptionListView extends StatelessWidget {
  const SettingsInviteRejectionExceptionListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsInviteRejectionController>();
    final exceptions = controller.exceptionEntries;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              L10n.of(context)!.inviteRejectionSettingsExceptionsListHeader(
                controller.defaultSetting.toString(),
              ),
            ),
            trailing: IconButton(
              key: const ValueKey("inviteRejectionSettingsRemoveAllExceptionsButton"),
              icon: const Icon(Icons.delete_forever_outlined),
              onPressed: exceptions.isEmpty ? null : () => controller.removeAllExceptionEntries(),
              tooltip: L10n.of(context)!.inviteRejectionSettingsExceptionsListRemoveAllIconTooltip,
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              key: const ValueKey("inviteRejectionSettingsExceptionsList"),
              itemCount: exceptions.length,
              itemBuilder: (context, index) {
                final onTileColor =
                    index % 2 == 0 ? null : Theme.of(context).colorScheme.onSecondary;
                final tileColor = index % 2 == 0 ? null : Theme.of(context).colorScheme.secondary;

                // Need to wrap ListView elements with Material widget,
                // as workaround for issue [#86584](https://github.com/flutter/flutter/issues/86584)
                return Material(
                  child: ListTile(
                    textColor: onTileColor,
                    tileColor: tileColor,
                    title: Text(exceptions.elementAt(index)),
                    trailing: IconButton(
                      key: ValueKey("inviteRejectionSettingsRemoveExceptionButton${exceptions.elementAt(index)}"),
                      icon: Icon(
                        Icons.delete_forever_outlined,
                        color: onTileColor,
                      ),
                      onPressed: () => controller.removeExceptionEntry(exceptions.elementAt(index)),
                      tooltip: L10n.of(context)!
                          .inviteRejectionSettingsExceptionsListEntryRemoveIconTooltip,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8)
        ],
      ),
    );
  }
}
