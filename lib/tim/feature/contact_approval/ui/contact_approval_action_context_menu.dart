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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:tim_contact_management_api/api.dart';

import 'package:vrouter/vrouter.dart';

import 'package:fluffychat/tim/shared/provider/tim_provider.dart';

class ContactApprovalActionContextMenu extends StatelessWidget {
  final Contact contact;

  const ContactApprovalActionContextMenu({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PopupMenuItem<Object> itemContactName(BuildContext context) => PopupMenuItem(
          textStyle: Theme.of(context).textTheme.titleLarge,
          child: Text(contact.displayName),
        );

    PopupMenuItem<Object> itemContactApprove(BuildContext context) => PopupMenuItem(
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.edit_outlined,
                ),
              ),
              Text(L10n.of(context)!.timEditContactApproval),
            ],
          ),
          onTap: () => VRouter.of(context).to('/contacts/edit/${contact.mxid}'),
        );

    PopupMenuItem<Object> itemContactReject(BuildContext context) => PopupMenuItem(
          key: const ValueKey("deleteContactIcon"),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.remove_circle_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              Text(L10n.of(context)!.timDeleteContactApproval),
            ],
          ),
          onTap: () =>
              TimProvider.of(context).contactsApprovalRepository().deleteApproval(contact.mxid),
        );

    return PopupMenuButton<Object>(
      itemBuilder: (context) => <PopupMenuEntry<Object>>[
        itemContactName(context),
        itemContactApprove(context),
        itemContactReject(context),
      ],
      child: const Icon(Icons.more_horiz),
    );
  }
}
