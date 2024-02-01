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

import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';

import '../../config/themes.dart';
import 'chat.dart';
import 'events/reply_content.dart';

class ReplyDisplay extends StatelessWidget {
  final ChatController controller;
  const ReplyDisplay(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: FluffyThemes.animationDuration,
      curve: FluffyThemes.animationCurve,
      height: controller.replyEvent != null ? 56 : 0,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      child: Material(
        color: Theme.of(context).secondaryHeaderColor,
        child: Row(
          children: <Widget>[
            IconButton(
              tooltip: L10n.of(context)!.close,
              icon: const Icon(Icons.close),
              onPressed: controller.cancelReplyEventAction,
            ),
            if (controller.replyEvent != null)
              Expanded(
                child: ReplyContent(
                  controller.replyEvent!,
                  timeline: controller.timeline!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
