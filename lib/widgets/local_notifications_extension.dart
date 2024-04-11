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

import 'dart:io';

import 'package:fluffychat/utils/matrix_sdk_extensions/room_extension.dart';
import 'package:flutter/foundation.dart';

import 'package:desktop_lifecycle/desktop_lifecycle.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:vrouter/vrouter.dart';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/widgets/matrix.dart';

extension LocalNotificationsExtension on MatrixState {
  void showLocalNotification(EventUpdate eventUpdate) async {
    final roomId = eventUpdate.roomID;
    if (activeRoomId == roomId) {
      if (kIsWeb && webHasFocus) return;
      if (PlatformInfos.isLinux && DesktopLifecycle.instance.isActive.value) {
        return;
      }
    }
    final room = client.getRoomById(roomId);
    if (room == null) {
      Logs().w('Can not display notification for unknown room $roomId');
      return;
    }
    if (room.notificationCount == 0) return;
    final event = Event.fromJson(eventUpdate.content, room);
    final title =
        room.getLocalizedDisplaynameFromCustomNameEvent(MatrixLocals(L10n.of(widget.context)!));
    final body = await event.calcLocalizedBody(
      MatrixLocals(L10n.of(widget.context)!),
      withSenderNamePrefix: !room.isDirectChat || room.lastEvent?.senderId == client.userID,
      plaintextBody: true,
      hideReply: true,
      hideEdit: true,
      removeMarkdown: true,
    );
    final icon = event.senderFromMemoryOrFallback.avatarUrl?.getThumbnail(
          client,
          width: 64,
          height: 64,
          method: ThumbnailMethod.crop,
        ) ??
        room.avatar?.getThumbnail(
          client,
          width: 64,
          height: 64,
          method: ThumbnailMethod.crop,
        );
    if (kIsWeb) {
      html.AudioElement()
        ..src = 'assets/assets/sounds/WoodenBeaver_stereo_message-new-instant.ogg'
        ..autoplay = true
        ..load();
      html.Notification(
        title,
        body: body,
        icon: icon.toString(),
      );
    } else if (Platform.isLinux) {
      final appIconUrl = room.avatar?.getThumbnail(
        room.client,
        width: 56,
        height: 56,
      );
      File? appIconFile;
      if (appIconUrl != null) {
        final tempDirectory = await getApplicationSupportDirectory();
        final avatarDirectory = await Directory('${tempDirectory.path}/notiavatars/').create();
        appIconFile = File(
          '${avatarDirectory.path}/${Uri.encodeComponent(appIconUrl.toString())}',
        );
        if (await appIconFile.exists() == false) {
          final response = await http.get(appIconUrl);
          await appIconFile.writeAsBytes(response.bodyBytes);
        }
      }
      final notification = await linuxNotifications!.notify(
        title,
        body: body,
        replacesId: linuxNotificationIds[roomId] ?? 0,
        appName: AppConfig.applicationName,
        appIcon: appIconFile?.path ?? '',
        actions: [
          NotificationAction(
            DesktopNotificationActions.openChat.name,
            L10n.of(widget.context)!.openChat,
          ),
          NotificationAction(
            DesktopNotificationActions.seen.name,
            L10n.of(widget.context)!.markAsRead,
          ),
        ],
        hints: [
          NotificationHint.soundName('message-new-instant'),
        ],
      );
      notification.action.then((actionStr) {
        final action = DesktopNotificationActions.values.singleWhere((a) => a.name == actionStr);
        switch (action) {
          case DesktopNotificationActions.seen:
            if (AppConfig.sendReadReceipts) room.setReadMarker(event.eventId, mRead: event.eventId);
            break;
          case DesktopNotificationActions.openChat:
            VRouter.of(navigatorContext).toSegments(['rooms', room.id]);
            break;
        }
      });
      linuxNotificationIds[roomId] = notification.id;
    }
  }
}

enum DesktopNotificationActions { seen, openChat }
