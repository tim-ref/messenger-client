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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:fluffychat/widgets/matrix.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:fluffychat/tim/feature/contact_approval/ui/new_contact_approval.dart';

class NewContactApprovalView extends StatelessWidget {
  final NewContactApprovalController controller;

  static const double _qrCodePadding = 8;

  const NewContactApprovalView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            _buildClientQrCode(context),
            _buildContactApprovalForm(context),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _buildScanButton(context),
      );

  AppBar _buildAppBar(BuildContext context) => AppBar(
        leading: const BackButton(),
        title: Text(L10n.of(context)!.timNewContactApproval),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      );

  Widget _buildClientQrCode(BuildContext context) => Expanded(
        child: MaxWidthBody(
          withScrolling: true,
          child: Container(
            margin: const EdgeInsets.all(_qrCodePadding),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(_qrCodePadding * 2),
            child: Material(
              borderRadius: BorderRadius.circular(12),
              elevation: 10,
              color: Colors.white,
              shadowColor: Theme.of(context).appBarTheme.shadowColor,
              clipBehavior: Clip.hardEdge,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QrImage(
                    data:
                        'https://matrix.to/#/${Matrix.of(context).client.userID}',
                    version: QrVersions.auto,
                    size: min(MediaQuery.of(context).size.width - 16, 200),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.adaptive.share_outlined),
                    label: Text(L10n.of(context)!.shareYourInviteLink),
                    onPressed: controller.inviteAction,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildContactApprovalForm(BuildContext context) => MaxWidthBody(
        withScrolling: false,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: controller.formKey,
            child: Semantics(
              label: "newContactApprovalInput",
              container: true,
              textField: true,
              child: TextFormField(
                controller: controller.controller,
                autocorrect: false,
                textInputAction: TextInputAction.go,
                focusNode: controller.textFieldFocus,
                onFieldSubmitted: controller.submitAction,
                validator: controller.validateForm,
                inputFormatters: controller.removeMatrixToFormatters,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  labelText: L10n.of(context)!.enterInviteLinkOrMatrixId,
                  hintText: '@username',
                  prefixText: NewContactApprovalController.prefixNoProtocol,
                  suffixIcon: Semantics(
                    label: "newContactApprovalButton",
                    container: true,
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: controller.submitAction,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget? _buildScanButton(BuildContext context) => PlatformInfos.isMobile
      ? Padding(
          padding: const EdgeInsets.only(bottom: 64.0),
          child: FloatingActionButton.extended(
            onPressed: controller.openScannerAction,
            label: Text(L10n.of(context)!.scanQrCode),
            icon: const Icon(Icons.camera_alt_outlined),
          ),
        )
      : null;
}
