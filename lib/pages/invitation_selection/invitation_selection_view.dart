/*
 * Modified by akquinet GmbH on 08.04.2024
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/pages/invitation_selection/invitation_selection.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/room_extension.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

import '../../widgets/user_avatar.dart';

class InvitationSelectionView extends StatelessWidget {
  final InvitationSelectionController controller;

  const InvitationSelectionView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final room = Matrix.of(context).client.getRoomById(controller.roomId!)!;
    final groupName =
        room.getLocalizedDisplaynameFromCustomNameEvent(MatrixLocals(L10n.of(context)!));
    return Scaffold(
      appBar: AppBar(
        leading: VRouter.of(context).path.startsWith('/spaces/')
            ? null
            : Semantics(
                label: "inviteCloseButton",
                container: true,
                child: IconButton(
                  icon: const Icon(Icons.close_outlined),
                  onPressed: () => VRouter.of(context).toSegments(['rooms', controller.roomId!]),
                ),
              ),
        titleSpacing: 0,
        title: SizedBox(
          height: 44,
          child: Semantics(
            label: "inviteSearchField",
            container: true,
            textField: true,
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: TextField(
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: L10n.of(context)!.inviteContactToGroup(groupName),
                  suffixIcon: controller.loading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 12,
                          ),
                          child: SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : const Icon(Icons.search_outlined),
                ),
                onChanged: controller.searchUserWithCoolDown,
              ),
            ),
          ),
        ),
      ),
      body: MaxWidthBody(
        withScrolling: true,
        child: Column(
          children: [
            TextButton(
              onPressed: () => VRouter.of(context).to('fhir/search'),
              child: Text(L10n.of(context)!.timFhirSearchContextLabel),
            ),
            controller.foundProfiles.isNotEmpty
                ? ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.foundProfiles.length,
                    itemBuilder: (BuildContext context, int i) => ListTile(
                      leading: Avatar(
                        mxContent: controller.foundProfiles[i].avatarUrl,
                        name: controller.foundProfiles[i].displayName ??
                            controller.foundProfiles[i].userId,
                      ),
                      title: Text(
                        controller.foundProfiles[i].displayName ??
                            controller.foundProfiles[i].userId.localpart!,
                      ),
                      subtitle: Text(controller.foundProfiles[i].userId),
                      onTap: () => controller.inviteAction(
                        context,
                        controller.foundProfiles[i].userId,
                      ),
                    ),
                  )
                : FutureBuilder<List<User>>(
                    future: controller.getContacts(context),
                    builder: (BuildContext context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        );
                      }
                      final contacts = snapshot.data!;
                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: contacts.length,
                        itemBuilder: (BuildContext context, int i) => ListTile(
                          leading: UserAvatar(user: contacts[i]),
                          title: Text(
                            contacts[i].calcDisplayname(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            contacts[i].id,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          onTap: () => controller.inviteAction(context, contacts[i].id),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
