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

import 'package:fluffychat/tim/feature/automated_invite_rejection/ui/settings_invite_rejection_view_body.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:fluffychat/tim/shared/provider/tim_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'settings_invite_rejection_controller.dart';

class SettingsInviteRejectionView extends StatelessWidget {
  const SettingsInviteRejectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(L10n.of(context)!.inviteRejectionSettingsTitle),
        ),
        body: ChangeNotifierProvider<SettingsInviteRejectionController>(
          create: (context) {
            final repo = TimProvider.of(context).inviteRejectionPolicyRepository();
            return SettingsInviteRejectionController(inviteRejectionPolicyRepository: repo);
          },
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: SettingsInviteRejectionViewBody(),
          ),
        ),
      ),
    );
  }
}
