/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - 2025 akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/utils/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:intl/intl.dart';

import 'package:fluffychat/tim/feature/contact_approval/contact_approval_constants.dart';
import 'package:fluffychat/tim/feature/contact_approval/ui/contact_approval_action_context_menu.dart';
import 'package:tim_contact_management_api/api.dart';

class ContactApprovals extends StatelessWidget {
  final List<Contact> contacts;

  const ContactApprovals({Key? key, required this.contacts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return contacts.isEmpty ? _buildEmptyList(context) : _buildContactList();
  }

  Widget _buildEmptyList(BuildContext context) => Center(
        child: Text(L10n.of(context)!.timNoContactApprovals),
      );

  Widget _buildContactList() => ListView.separated(
        key: const Key('ContactsSettingsListViewContent'),
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: contacts.length,
        itemBuilder: (BuildContext context, int index) {
          final contact = contacts[index];
          final inviteStartDate = _formatDateFrom(contact.inviteSettings.start);
          final inviteEndDate = contact.inviteSettings.end != null
              ? _formatDateFrom(contact.inviteSettings.end!)
              : '';
          return ListTile(
            leading: const Icon(Icons.contact_page_outlined),
            title: Text(contact.displayName),
            subtitle: Text('$inviteStartDate - $inviteEndDate'),
            trailing: ContactApprovalActionContextMenu(
              key: ValueKey(contact.mxid),
              contact: contact,
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
      );

  String _formatDateFrom(int secondsSinceEpochUtc) {
    final dateFormat = DateFormat(contactInviteSettingsDateFormatPattern);
    return dateFormat.format(
      DateTimeExtension.fromSecondsSinceEpoch(
        secondsSinceEpochUtc,
        isUtc: true,
      ),
    );
  }
}
