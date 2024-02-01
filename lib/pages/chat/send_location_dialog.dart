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

import 'dart:async';

import 'package:fluffychat/pages/chat/events/map_bubble.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:matrix/matrix.dart';

import '../../config/app_config.dart';

class SendLocationDialog extends StatefulWidget {
  final Room room;

  const SendLocationDialog({
    required this.room,
    Key? key,
  }) : super(key: key);

  @override
  SendLocationDialogState createState() => SendLocationDialogState();
}

class SendLocationDialogState extends State<SendLocationDialog> {
  bool disabled = false;
  bool denied = false;
  bool isSending = false;
  Position? position;
  Object? error;

  @override
  void initState() {
    super.initState();
    requestLocation();
  }

  Future<void> requestLocation() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      setState(() => disabled = true);
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => denied = true);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() => denied = true);
      return;
    }
    try {
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 30),
        );
      } on TimeoutException {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 30),
        );
      }
      setState(() => this.position = position);
    } catch (e) {
      setState(() => error = e);
    }
  }

  void sendAction() async {
    setState(() => isSending = true);
    final body =
        'https://www.openstreetmap.org/?mlat=${position!.latitude}&mlon=${position!.longitude}#map=16/${position!.latitude}/${position!.longitude}';
    final uri =
        'geo:${position!.latitude},${position!.longitude};u=${position!.accuracy}';
    await showFutureLoadingDialog(
      context: context,
      future: () async {
        final room = widget.room;
        await room.sendLocation(body, uri);

        if (AppConfig.sendPresenceUpdates && room.client.userID != null) {
          room.client.setPresence(room.client.userID!, PresenceType.online);
        }
      },
    );
    Navigator.of(context, rootNavigator: false).pop();
  }

  @override
  Widget build(BuildContext context) {
    Widget contentWidget;
    if (position != null) {
      contentWidget = MapBubble(
        latitude: position!.latitude,
        longitude: position!.longitude,
      );
    } else if (disabled) {
      contentWidget = Text(L10n.of(context)!.locationDisabledNotice);
    } else if (denied) {
      contentWidget = Text(L10n.of(context)!.locationPermissionDeniedNotice);
    } else if (error != null) {
      contentWidget =
          Text(L10n.of(context)!.errorObtainingLocation(error.toString()));
    } else {
      contentWidget = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(),
          const SizedBox(width: 12),
          Text(L10n.of(context)!.obtainingLocation),
        ],
      );
    }
    if (PlatformInfos.isCupertinoStyle) {
      return CupertinoAlertDialog(
        title: Text(L10n.of(context)!.shareLocation),
        content: contentWidget,
        actions: [
          CupertinoDialogAction(
            onPressed: Navigator.of(context, rootNavigator: false).pop,
            child: Text(L10n.of(context)!.cancel),
          ),
          CupertinoDialogAction(
            onPressed: isSending ? null : sendAction,
            child: Text(L10n.of(context)!.send),
          ),
        ],
      );
    }
    return AlertDialog(
      title: Text(L10n.of(context)!.shareLocation),
      content: contentWidget,
      actions: [
        TextButton(
          onPressed: Navigator.of(context, rootNavigator: false).pop,
          child: Text(L10n.of(context)!.cancel),
        ),
        if (position != null)
          TextButton(
            onPressed: isSending ? null : sendAction,
            child: Text(L10n.of(context)!.send),
          ),
      ],
    );
  }
}
