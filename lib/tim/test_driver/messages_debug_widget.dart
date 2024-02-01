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

import 'package:fluffychat/tim/shared/provider/tim_provider.dart';
import 'package:fluffychat/tim/test_driver/debug_dtos.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

class MessagesDebugWidget extends StatelessWidget {
  const MessagesDebugWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Timeline?>(
      stream: TimProvider.of(context).testDriverStateHelper()?.roomTimeline,
      builder: (roomStateContext, timelineSnapshot) {
        final roomId = roomStateContext.vRouter.pathParameters['roomid'];
        Room? room;
        if (roomId != null) {
          room = Matrix.of(roomStateContext).client.getRoomById(roomId);
        }
        if (timelineSnapshot.hasData && room != null) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Messages Count: ${keepMessageEvents(timelineSnapshot.data!).length}',
              ),
              Text(
                timelineToMessageJsonString(timelineSnapshot.data!),
                key: const ValueKey("messagesDebug"),
              ),
            ],
          );
        } else {
          return const Text(
            'No Messages.',
            key: ValueKey("noMessagesDebug"),
          );
        }
      },
    );
  }
}
