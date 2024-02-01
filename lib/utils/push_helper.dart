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

import 'dart:convert';
import 'dart:ui';

import 'package:fluffychat/config/app_config.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fluffychat/config/setting_keys.dart';
import 'package:fluffychat/utils/client_manager.dart';
import 'package:fluffychat/utils/voip/callkeep_manager.dart';

Future<void> pushHelper(
  PushNotification notification, {
  Client? client,
  L10n? l10n,
  String? activeRoomId,
  void Function(NotificationResponse?)? onSelectNotification,
}) async {
  try {
    await _tryPushHelper(
      notification,
      client: client,
      l10n: l10n,
      activeRoomId: activeRoomId,
      onSelectNotification: onSelectNotification,
    );
  } catch (e, s) {
    Logs().wtf('Push Helper has crashed!', e, s);
  }
}

Future<void> _tryPushHelper(
  PushNotification notification, {
  Client? client,
  L10n? l10n,
  String? activeRoomId,
  void Function(NotificationResponse?)? onSelectNotification,
}) async {
  final isBackgroundMessage = client == null;
  Logs().v(
    'Push helper has been started (background=$isBackgroundMessage).',
    notification.toJson(),
  );

  // All the TIM push gateway is receiving is
  // the room_id, event_id, senderDisplayName and the message priority.

  if (!isBackgroundMessage) return;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('notifications_icon'),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveNotificationResponse: onSelectNotification,
    onDidReceiveBackgroundNotificationResponse: onSelectNotification,
  );

  client ??= (await ClientManager.getClients(initialize: false)).first;
  final event = await getEventByPushNotification(notification, client);
  if (event == null) {
    Logs().v('Notification is a clearing indicator.');
    if (notification.counts?.unread == 0) {
      if (notification.counts == null || notification.counts?.unread == 0) {
        await flutterLocalNotificationsPlugin.cancelAll();
        final store = await SharedPreferences.getInstance();
        await store.setString(
          SettingKeys.notificationCurrentIds,
          json.encode({}),
        );
      }
    }
    return;
  }
  Logs().v('Push helper got notification event of type ${event.type}.');

  if (event.type.startsWith('m.call')) {
    // make sure bg sync is on (needed to update hold, unhold events)
    // prevent over write from app life cycle change
    client.backgroundSync = true;
  }

  if (event.type == EventTypes.CallInvite) {
    CallKeepManager().initialize();
  } else if (event.type == EventTypes.CallHangup) {
    client.backgroundSync = false;
  }

  if (event.type.startsWith('m.call') && event.type != EventTypes.CallInvite) {
    Logs().v('Push message is a m.call but not invite. Do not display.');
    return;
  }

  if ((event.type.startsWith('m.call') && event.type != EventTypes.CallInvite) ||
      event.type == 'org.matrix.call.sdp_stream_metadata_changed') {
    Logs().v('Push message was for a call, but not call invite.');
    return;
  }

  final sender = notification.senderDisplayName ?? "";
  l10n ??= await L10n.delegate.load(PlatformDispatcher.instance.locale);
  flutterLocalNotificationsPlugin.show(
    0,
    l10n.newMessageInFluffyChat,
    l10n.openAppToReadMessages,
    NotificationDetails(
      iOS: const DarwinNotificationDetails(),
      android: AndroidNotificationDetails(
        AppConfig.pushNotificationsChannelId,
        sender.isNotEmpty ? sender : AppConfig.pushNotificationsChannelName,
        channelDescription: AppConfig.pushNotificationsChannelDescription,
        number: notification.counts?.unread,
        ticker: l10n.unreadChats(notification.counts?.unread ?? 1),
        importance: Importance.max,
        priority: Priority.max,
        subText: sender,
        groupKey: sender,
      ),
    ),
  );

  Logs().v('Push helper has been completed!');
}

/// Workaround for the problem that local notification IDs must be int but we
/// sort by [roomId] which is a String. To make sure that we don't have duplicated
/// IDs we map the [roomId] to a number and store this number.
Future<int> mapRoomIdToInt(String roomId) async {
  final store = await SharedPreferences.getInstance();
  final idMap = Map<String, int>.from(
    jsonDecode(store.getString(SettingKeys.notificationCurrentIds) ?? '{}'),
  );
  int? currentInt;
  try {
    currentInt = idMap[roomId];
  } catch (_) {
    currentInt = null;
  }
  if (currentInt != null) {
    return currentInt;
  }
  var nCurrentInt = 0;
  while (idMap.values.contains(nCurrentInt)) {
    nCurrentInt++;
  }
  idMap[roomId] = nCurrentInt;
  await store.setString(SettingKeys.notificationCurrentIds, json.encode(idMap));
  return nCurrentInt;
}

Future<Event?> getEventByPushNotification(
  PushNotification notification,
  Client client,
) async {
  // Check if the notification contains an event at all:
  final eventId = notification.eventId;
  final roomId = notification.roomId;
  if (eventId == null || roomId == null) return null;

  // Load the event from the notification or from the database or from server:
  MatrixEvent? matrixEvent;
  final content = notification.content ?? {};
  final sender = notification.sender;
  final type = notification.type;
  if (sender != null && type != null) {
    matrixEvent = MatrixEvent(
      content: content,
      senderId: sender,
      type: type,
      originServerTs: DateTime.now(),
      eventId: eventId,
      roomId: roomId,
    );
  }

  if (matrixEvent == null) {
    return null;
  }

  final event = Event.fromMatrixEvent(
    matrixEvent,
    Room(
      id: roomId,
      client: client,
    ),
    status: EventStatus.sent,
  );

  return event;
}
