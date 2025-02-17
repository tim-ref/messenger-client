/*
 * Modified by akquinet GmbH on 06.02.2025
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

import '../date_time_extension.dart';

extension PresenceExtension on CachedPresence {
  String getLocalizedLastActiveAgo(BuildContext context) {
    final lastActiveTimestamp = this.lastActiveTimestamp;
    if (lastActiveTimestamp != null) {
      return L10n.of(context)!.lastActiveAgo(lastActiveTimestamp.localizedTimeShort(context));
    }
    return L10n.of(context)!.lastSeenLongTimeAgo;
  }

  String getLocalizedStatusMessage(BuildContext context) {
    final statusMsg = this.statusMsg;
    if (statusMsg != null && statusMsg.isNotEmpty) {
      return statusMsg;
    }
    if (currentlyActive ?? false) {
      return L10n.of(context)!.currentlyActive;
    }
    return getLocalizedLastActiveAgo(context);
  }

  Color get color {
    switch (presence) {
      case PresenceType.online:
        return Colors.green;
      case PresenceType.offline:
        return Colors.transparent;
      case PresenceType.unavailable:
        return Colors.red;
    }
  }
}
