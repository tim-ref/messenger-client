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

import 'package:fluffychat/tim/feature/fhir/fhir_endpoint_address_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:vrouter/vrouter.dart';

import 'package:fluffychat/tim/feature/contact_approval/ui/contacts_profile_bottom_sheet.dart';
import 'package:fluffychat/tim/feature/fhir/search/practitioner_search_result.dart';
import 'package:fluffychat/tim/shared/provider/tim_provider.dart';
import 'package:fluffychat/utils/adaptive_bottom_sheet.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_locals.dart';

class PractitionerSearchResultListTile extends StatelessWidget {
  final PractitionerSearchResult _searchResult;

  const PractitionerSearchResultListTile(this._searchResult, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(Icons.person_outline),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _searchResult.practitionerName ?? '-',
                        style: Theme.of(context).textTheme.headlineSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      _buildSearchResultList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildSearchResultList() {
    if (_searchResult.endpointAdresses == null) {
      return const SizedBox.shrink();
    }
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 16),
      itemCount: _searchResult.endpointAdresses!.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            final roomId = context.vRouter.pathParameters['roomid'];
            final mxIdUri = _searchResult.endpointAdresses![index];
            final mxId = convertUriToSigil(mxIdUri);
            if (roomId != null) {
              _inviteToGroup(
                  context, roomId, mxId);
            } else {
              _showUserProfile(context, mxId);
            }
          },
          child: Text(
            _searchResult.endpointAdresses![index],
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
      separatorBuilder: (context, index) {
        return const Divider();
      },
    );
  }

  void _inviteToGroup(BuildContext context, String roomId, String mxid) async {
    final room = TimProvider.of(context).matrix().client().getRoomById(roomId)!;
    if (OkCancelResult.ok !=
        await showOkCancelAlertDialog(
          context: context,
          title: L10n.of(context)!.inviteContactToGroup(
            room.getLocalizedDisplayname(
              MatrixLocals(L10n.of(context)!),
            ),
          ),
          okLabel: L10n.of(context)!.yes,
          cancelLabel: L10n.of(context)!.cancel,
        )) {
      return;
    }
    final success = await showFutureLoadingDialog(
      context: context,
      future: () => room.invite(mxid),
    );
    if (success.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.contactHasBeenInvitedToTheGroup),
        ),
      );
    }
  }

  void _showUserProfile(BuildContext context, String mxid) {
    showAdaptiveBottomSheet(
      context: context,
      builder: (c) => ContactsProfileBottomSheet(
        userId: mxid,
        outerContext: c,
      ),
    );
  }
}
