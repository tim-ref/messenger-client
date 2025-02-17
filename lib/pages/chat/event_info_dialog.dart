/*
 * Modified by akquinet GmbH on 21.11.2024
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:convert';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/utils/adaptive_bottom_sheet.dart';
import 'package:fluffychat/utils/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

import '../../widgets/user_avatar.dart';

extension EventInfoDialogExtension on Event {
  void showInfoDialog(BuildContext context) => showAdaptiveBottomSheet(
        context: context,
        builder: (context) => EventInfoDialog(l10n: L10n.of(context)!, event: this),
      );
}

class EventInfoDialog extends StatelessWidget {
  final Event event;
  final L10n l10n;

  EventInfoDialog({
    required this.event,
    required this.l10n,
    Key? key,
  }) : super(key: key);

  String get prettyJson {
    const JsonDecoder decoder = JsonDecoder();
    const JsonEncoder encoder = JsonEncoder.withIndent('    ');
    final object = decoder.convert(jsonEncode(event.toJson()));
    return encoder.convert(object);
  }

  @override
  Widget build(BuildContext context) {
    String? redactedEventTime;
    try {
      redactedEventTime = DateTime.fromMillisecondsSinceEpoch(
        (event.unsigned?.tryGetMap('redacted_because')?['origin_server_ts']),
      ).localizedDateTime(context);
    } catch (e) {
      redactedEventTime = null;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)!.messageInfo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_downward_outlined),
          onPressed: Navigator.of(context, rootNavigator: false).pop,
          tooltip: L10n.of(context)!.close,
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: UserAvatar(user: event.senderFromMemoryOrFallback),
            title: Text(L10n.of(context)!.sender),
            subtitle: Text(
              '${event.senderFromMemoryOrFallback.calcDisplayname()} [${event.senderId}]',
            ),
          ),
          ListTile(
            title: Text(L10n.of(context)!.time),
            subtitle: Text(event.originServerTs.localizedDateTime(context)),
          ),
          if (redactedEventTime != null)
            ListTile(
              title: Text(L10n.of(context)!.redactedTime),
              subtitle: Text(redactedEventTime),
            ),
          ListTile(
            title: Text(L10n.of(context)!.messageType),
            subtitle: Text(event.humanreadableType),
          ),
          ListTile(title: Text('${L10n.of(context)!.sourceCode}:')),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Material(
              borderRadius: BorderRadius.circular(AppConfig.borderRadius),
              color: Theme.of(context).colorScheme.surface,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                scrollDirection: Axis.horizontal,
                child: SelectableText(prettyJson),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on Event {
  String get humanreadableType {
    if (type == EventTypes.Message) {
      return messageType.split('m.').last;
    }
    if (type.startsWith('m.room.')) {
      return type.split('m.room.').last;
    }
    if (type.startsWith('m.')) {
      return type.split('m.').last;
    }
    return type;
  }
}
