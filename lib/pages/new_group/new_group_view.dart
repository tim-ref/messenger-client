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

import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:fluffychat/pages/new_group/new_group.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';

class NewGroupView extends StatelessWidget {
  final NewGroupController controller;

  const NewGroupView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)!.createNewGroup),
      ),
      body: MaxWidthBody(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Semantics(
                label: "groupNameField",
                container: true,
                textField: true,
                child: TextField(
                  controller: controller.controller,
                  autofocus: true,
                  autocorrect: false,
                  textInputAction: TextInputAction.go,
                  onSubmitted: controller.submitAction,
                  decoration: InputDecoration(
                    labelText: L10n.of(context)!.optionalGroupName,
                    prefixIcon: const Icon(Icons.people_outlined),
                    hintText: L10n.of(context)!.enterAGroupName,
                  ),
                ),
              ),
            ),
            Semantics(
              label: "groupPrivateToggle",
              container: true,
              child: SwitchListTile.adaptive(
                secondary: const Icon(Icons.public_outlined),
                title: Text(L10n.of(context)!.groupIsPublic),
                value: controller.publicGroup,
                onChanged: controller.setPublicGroup,
              ),
            ),
            SwitchListTile.adaptive(
              secondary: const Icon(Icons.lock_outlined),
              title: Text(L10n.of(context)!.enableEncryption),
              value: !controller.publicGroup,
              onChanged: null,
            ),
            Semantics(
              label: "groupTimCaseReferenceRoomTypeToggle",
              container: true,
              child: SwitchListTile.adaptive(
                title: Text(L10n.of(context)!.createRoomWithCaseReference),
                value: controller.isCaseReference,
                onChanged: controller.setCaseReference,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.submitAction,
        child: Semantics(
          label: "createGroupButton",
          container: true,
          child: const Icon(Icons.arrow_forward_outlined),
        ),
      ),
    );
  }
}
