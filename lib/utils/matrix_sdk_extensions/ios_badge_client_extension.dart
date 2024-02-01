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

import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:matrix/matrix.dart';

import 'package:fluffychat/utils/platform_infos.dart';

extension IosBadgeClientExtension on Client {
  void updateIosBadge() {
    if (PlatformInfos.isIOS) {
      // Workaround for iOS not clearing notifications with fcm_shared_isolate
      if (!rooms.any(
        (r) => r.membership == Membership.invite || (r.notificationCount > 0),
      )) {
        // ignore: unawaited_futures
        FlutterLocalNotificationsPlugin().cancelAll();
        FlutterAppBadger.removeBadge();
      }
    }
  }
}
