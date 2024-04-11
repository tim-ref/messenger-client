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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:intl/intl.dart';
import 'package:vrouter/vrouter.dart';

import 'package:fluffychat/tim/feature/contact_approval/contact_approval_repository.dart';
import 'package:fluffychat/tim/feature/contact_approval/dto/contact.dart';
import 'package:fluffychat/tim/shared/provider/tim_provider.dart';

class ContactApprovalDetails extends StatefulWidget {
  const ContactApprovalDetails({Key? key}) : super(key: key);

  @override
  State<ContactApprovalDetails> createState() => _ContactApprovalDetailsState();
}

class _ContactApprovalDetailsState extends State<ContactApprovalDetails> {
  final TextEditingController _endDateController = TextEditingController();
  late final ContactApprovalRepository approvalRepository;

  Contact? _initialContact;
  Contact? _updatedContact;

  @override
  void initState() {
    approvalRepository = TimProvider.of(context).contactsApprovalRepository();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mxid = context.vRouter.pathParameters['contactId'];
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)!.timContactApprovals),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: FutureBuilder<Contact>(
        future: approvalRepository.getApproval(mxid!),
        builder: (context, contactSnapshot) {
          switch (contactSnapshot.connectionState) {
            case ConnectionState.waiting:
              return _buildContactLoading();
            default:
              if (contactSnapshot.hasError) {
                return _buildContactError(contactSnapshot);
              } else {
                _initialContact = contactSnapshot.data;
                return _buildContactDetails(contactSnapshot);
              }
          }
        },
      ),
      floatingActionButton: _buildAcceptButton(),
    );
  }

  Widget _buildContactLoading() => const Center(
        child: CircularProgressIndicator(),
      );

  Widget _buildContactError(contactSnapshot) => Center(
        child: Text(contactSnapshot.error.toString()),
      );

  Widget _buildContactDetails(contactSnapshot) => Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Text(
                contactSnapshot.data!.displayName,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            TextField(
              controller: _endDateController,
              decoration: InputDecoration(
                icon: const Icon(Icons.calendar_today),
                labelText: L10n.of(context)!.timApproveUntil,
              ),
              readOnly: true,
              onTap: () => _onEndDateTapped(context),
            ),
          ],
        ),
      );

  Widget _buildAcceptButton() => FloatingActionButton.extended(
        onPressed: () {
          approvalRepository.updateApproval(_updatedContact!);
          Navigator.of(context).pop();
        },
        label: Text(L10n.of(context)!.accept),
      );

  Future<void> _onEndDateTapped(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().toUtc(),
      firstDate: DateTime.now().toUtc(),
      lastDate: DateTime(DateTime.now().year + 100).toUtc(),
    );

    if (pickedDate != null) {
      final utcDate = DateTime.utc(pickedDate.year, pickedDate.month, pickedDate.day);
      final formattedDate = DateFormat('dd.MM.yyyy').format(utcDate);
      setState(() {
        _endDateController.text = formattedDate;
        _updatedContact = _initialContact!.copyWith(
          newInviteSettings: _initialContact!.inviteSettings.copyWith(
            newEnd: utcDate,
          ),
        );
      });
    }
  }
}
