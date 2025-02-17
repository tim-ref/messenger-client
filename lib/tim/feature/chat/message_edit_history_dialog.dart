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

import 'package:fluffychat/utils/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import '../../../widgets/matrix.dart';
import '../../shared/provider/tim_provider.dart';

class MessageEditHistoryDialog extends StatefulWidget {
  final Room room;
  final Event event;

  const MessageEditHistoryDialog({
    required this.room,
    required this.event,
    Key? key,
  }) : super(key: key);

  @override
  MessageEditHistoryDialogState createState() => MessageEditHistoryDialogState();
}

class MessageEditHistoryDialogState extends State<MessageEditHistoryDialog> {
  Future<List<Event>>? future;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        future = fetchRelatedEvents(context);
      });
    });
  }

  Future<List<Event>> fetchRelatedEvents(BuildContext context) async {
    final relatingEvents = await Matrix.of(context)
        .client
        .getRelatingEventsWithRelType(widget.room.id, widget.event.eventId, RelationshipTypes.edit);

    final List<Event> decryptedEvents = [];

    for (int i = 0; i < relatingEvents.chunk.length; i++) {
      final event = Event.fromMatrixEvent(relatingEvents.chunk[i], widget.room);
      final decryptedEvent = await TimProvider.of(context).matrix().crypto().decryptRoomEvent(
            widget.room.id,
            event,
          );
      decryptedEvents.add(decryptedEvent);
    }

    final initialEventId =
        decryptedEvents.firstOrNull?.content.tryGetMap("m.relates_to")?["event_id"] as String?;
    if (initialEventId != null) {
      final initialEvent =
          await Matrix.of(context).client.getOneRoomEvent(widget.room.id, initialEventId);
      final initialDecryptedEvent =
          await TimProvider.of(context).matrix().crypto().decryptRoomEvent(
                widget.room.id,
                Event.fromMatrixEvent(initialEvent, widget.room),
              );

      decryptedEvents.add(initialDecryptedEvent);
    }
    return decryptedEvents;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(L10n.of(context)!.messageEditHistory),
      content: SizedBox(
        height: 300,
        child: future == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : FutureBuilder(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("${L10n.of(context)!.errorLoadingFuture} ${snapshot.error}");
                  } else if (snapshot.hasData) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: snapshot.requireData.map((e) {
                          final content = e.content.tryGetMap("m.new_content")?["body"] ?? e.body;

                          return Text(
                            '$content - ${e.originServerTs.localizedTimeShort(context)}',
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    return Text(
                      L10n.of(context)!.oopsSomethingWentWrong,
                    );
                  }
                },
              ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: false).pop();
          },
          child: Text(L10n.of(context)!.close),
        ),
      ],
    );
  }
}
