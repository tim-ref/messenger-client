/*
 * Modified by akquinet GmbH on 16.10.2023
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';

import '../../widgets/user_avatar.dart';

class TypingIndicators extends StatelessWidget {
  final ChatController controller;
  const TypingIndicators(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final typingUsers = controller.room.typingUsers
      ..removeWhere((u) => u.stateKey == Matrix.of(context).client.userID);
    const topPadding = 20.0;
    const bottomPadding = 4.0;

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: AnimatedContainer(
        constraints:
            const BoxConstraints(maxWidth: FluffyThemes.columnWidth * 2.5),
        height: typingUsers.isEmpty ? 0 : Avatar.defaultSize + bottomPadding,
        duration: FluffyThemes.animationDuration,
        curve: FluffyThemes.animationCurve,
        alignment: controller.timeline!.events.isNotEmpty &&
                controller.timeline!.events.first.senderId ==
                    Matrix.of(context).client.userID
            ? Alignment.topRight
            : Alignment.topLeft,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(),
        padding: const EdgeInsets.only(
          left: 8.0,
          bottom: bottomPadding,
        ),
        child: Row(
          children: [
            SizedBox(
              height: Avatar.defaultSize,
              width: typingUsers.length < 2
                  ? Avatar.defaultSize
                  : Avatar.defaultSize + 16,
              child: Stack(
                children: [
                  if (typingUsers.isNotEmpty) UserAvatar(user: typingUsers.first),
                  if (typingUsers.length == 2)
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: UserAvatar(user: typingUsers.last),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: topPadding),
              child: Material(
                color: Theme.of(context).appBarTheme.backgroundColor,
                elevation: 6,
                shadowColor:
                    Theme.of(context).secondaryHeaderColor.withAlpha(100),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(AppConfig.borderRadius),
                  bottomLeft: Radius.circular(AppConfig.borderRadius),
                  bottomRight: Radius.circular(AppConfig.borderRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: typingUsers.isEmpty
                      ? null
                      : Image.asset(
                          'assets/typing.gif',
                          height: 30,
                          filterQuality: FilterQuality.medium,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
