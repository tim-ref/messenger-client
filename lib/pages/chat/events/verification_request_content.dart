/*
 * Modified by akquinet GmbH on 10.04.2024
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
import 'package:matrix/matrix.dart';

import '../../../config/app_config.dart';

class VerificationRequestContent extends StatelessWidget {
  final Event event;
  final Timeline timeline;

  const VerificationRequestContent({
    required this.event,
    required this.timeline,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final events = event.aggregatedEvents(timeline, 'm.reference');
    final done = events.where((e) => e.type == EventTypes.KeyVerificationDone);
    final start = events.where((e) => e.type == EventTypes.KeyVerificationStart);
    final cancel = events.where((e) => e.type == EventTypes.KeyVerificationCancel);
    final fullyDone = done.length >= 2;
    final started = start.isNotEmpty;
    final canceled = cancel.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            color: Theme.of(context).colorScheme.background,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.lock_outlined,
                color: canceled ? Colors.red : (fullyDone ? Colors.green : Colors.grey),
              ),
              const SizedBox(width: 8),
              Text(
                canceled
                    ? 'Error ${cancel.first.content.tryGet<String>('code')}: ${cancel.first.content.tryGet<String>('reason')}'
                    : (fullyDone
                        ? L10n.of(context)!.verifySuccess
                        : (started
                            ? L10n.of(context)!.loadingPleaseWait
                            : L10n.of(context)!.newVerificationRequest)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
