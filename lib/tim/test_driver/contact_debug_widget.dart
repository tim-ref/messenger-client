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

import 'dart:convert';

import 'package:fluffychat/tim/shared/provider/tim_provider.dart';
import 'package:flutter/material.dart';
import 'package:tim_contact_management_api/api.dart';

class ContactDebugWidget extends StatelessWidget {
  const ContactDebugWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Contact>?>(
      stream: TimProvider.of(context).testDriverStateHelper()!.contactApprovalListViewData.stream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? Text(
                jsonEncode(snapshot.requireData),
                key: const ValueKey("contactList"),
              )
            : const Text("no contact data yet");
      },
    );
  }
}
