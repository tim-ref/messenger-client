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

import 'package:fluffychat/tim/feature/contact_approval/contact_approval_repository.dart';

import 'package:fluffychat/tim/feature/contact_approval/ui/contact_approvals.dart';
import 'package:fluffychat/tim/shared/provider/tim_provider.dart';
import 'package:fluffychat/tim/test_driver/test_driver_state_helper.dart';

class ContactApprovalView extends StatefulWidget {
  const ContactApprovalView({Key? key}) : super(key: key);

  @override
  State<ContactApprovalView> createState() => _ContactApprovalViewState();
}

class _ContactApprovalViewState extends State<ContactApprovalView> {
  late final ContactApprovalRepository approvalRepository;
  late final TestDriverStateHelper? testDriverStateHelper;

  late Future<List<Contact>> _approvals;

  @override
  void initState() {
    approvalRepository = TimProvider.of(context).contactsApprovalRepository();
    testDriverStateHelper = TimProvider.of(context).testDriverStateHelper();
    _approvals = approvalRepository.listApprovals();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: _buildApprovalsList(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() => AppBar(
        title: Text(L10n.of(context)!.timContactApprovals),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            key: const ValueKey("reloadContactApprovalsButton"),
            onPressed: () => _reload(),
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      );

  Widget _buildApprovalsList() => ListTileTheme(
        iconColor: Theme.of(context).colorScheme.onBackground,
        child: FutureBuilder<List<Contact>>(
          future: _approvals,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(snapshot.error.toString()),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final data = snapshot.data ?? List.empty();
            testDriverStateHelper?.contactApprovalListViewData.add(data);
            return ContactApprovals(contacts: data);
          },
        ),
      );

  Widget _buildFloatingActionButton() => FloatingActionButton.extended(
        key: const ValueKey("newContactApprovalActionButton"),
        onPressed: () => _onApproveContact(context),
        label: Text(L10n.of(context)!.timNewContactApproval),
        icon: const Icon(Icons.add),
      );

  void _reload() {
    testDriverStateHelper?.contactApprovalListViewData.add(null);
    setState(() {
      _approvals = approvalRepository.listApprovals();
    });
  }

  void _onApproveContact(BuildContext context) {
    VRouter.of(context).to('/newcontact');
  }
}
