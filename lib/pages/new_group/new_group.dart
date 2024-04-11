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

import 'package:fluffychat/tim/shared/provider/tim_provider.dart';
import 'package:flutter/material.dart';

import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart' as sdk;
import 'package:vrouter/vrouter.dart';

import 'package:fluffychat/pages/new_group/new_group_view.dart';

class NewGroup extends StatefulWidget {
  const NewGroup({Key? key}) : super(key: key);

  @override
  NewGroupController createState() => NewGroupController();
}

class NewGroupController extends State<NewGroup> {
  TextEditingController controller = TextEditingController();
  bool publicGroup = false;
  bool isCaseReference = false;

  void setCaseReference(bool value) => setState(() => isCaseReference = value);
  void setPublicGroup(bool b) => setState(() => publicGroup = b);

  void submitAction([_]) async {
    final client = TimProvider.of(context).matrix().client();
    final roomID = await showFutureLoadingDialog(
      context: context,
      future: () async {
        final roomId = await client.createGroupChatWithCustomRoomType(
          visibility: publicGroup ? sdk.Visibility.public : sdk.Visibility.private,
          preset: publicGroup ? sdk.CreateRoomPreset.publicChat : sdk.CreateRoomPreset.privateChat,
          name: controller.text.isNotEmpty ? controller.text : null,
          isCaseReference: isCaseReference,
        );
        return roomId;
      },
    );
    if (roomID.error == null) {
      VRouter.of(context).toSegments(['rooms', roomID.result!, 'invite']);
    }
  }

  @override
  Widget build(BuildContext context) => NewGroupView(this);
}
