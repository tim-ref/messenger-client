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

import 'dart:io';

import 'package:fluffychat/tim/feature/raw_data/user_agent.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:flutter/foundation.dart';

class UserAgentBuilder {
  UserAgent buildUserAgent() {
    return UserAgent(
      productVersion:
          '1.9.0', // TODO: should be derived from project settings!
      specification: 'Messenger-Client', // TODO: this probably, too.
      platform: _getPlatform(),
      operatingSystem: _getOperatingSystem(),
      operatingSystemVersion: _getOperatingSystemVersion(),
    );
  }

  String? _getPlatform() {
    if (PlatformInfos.isWeb) {
      return 'web';
    } else if (PlatformInfos.isDesktop) {
      return 'stationaer';
    } else if (PlatformInfos.isMobile) {
      return 'mobil';
    }
    return 'unknown';
  }

  String? _getOperatingSystem() {
    return kIsWeb ? 'web' : Platform.operatingSystem;
  }

  String? _getOperatingSystemVersion() {
    return kIsWeb ? 'web' : Platform.operatingSystemVersion;
  }
}
