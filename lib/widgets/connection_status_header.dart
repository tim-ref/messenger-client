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

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

import '../config/themes.dart';
import '../utils/localized_exception_extension.dart';
import 'matrix.dart';

class ConnectionStatusHeader extends StatefulWidget {
  const ConnectionStatusHeader({Key? key}) : super(key: key);

  @override
  ConnectionStatusHeaderState createState() => ConnectionStatusHeaderState();
}

class ConnectionStatusHeaderState extends State<ConnectionStatusHeader> {
  late final StreamSubscription _onSyncSub;

  @override
  void initState() {
    _onSyncSub = Matrix.of(context).client.onSyncStatus.stream.listen(
          (_) => setState(() {}),
        );
    super.initState();
  }

  @override
  void dispose() {
    _onSyncSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = Matrix.of(context).client;
    final status = client.onSyncStatus.value ??
        const SyncStatusUpdate(SyncStatus.waitingForResponse);
    final hide = client.onSync.value != null &&
        status.status != SyncStatus.error &&
        client.prevBatch != null;

    return material.Visibility(
      visible: !hide,
      child: AnimatedContainer(
        duration: FluffyThemes.animationDuration,
        curve: FluffyThemes.animationCurve,
        height: hide ? 0 : 36,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2,
                value: hide ? 1.0 : status.progress,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              status.toLocalizedString(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

extension on SyncStatusUpdate {
  String toLocalizedString(BuildContext context) {
    switch (status) {
      case SyncStatus.waitingForResponse:
        return L10n.of(context)!.loadingPleaseWait;
      case SyncStatus.error:
        return ((error?.exception ?? Object()) as Object)
            .toLocalizedString(context);
      case SyncStatus.processing:
      case SyncStatus.cleaningUp:
      case SyncStatus.finished:
      default:
        return L10n.of(context)!.synchronizingPleaseWait;
    }
  }
}
