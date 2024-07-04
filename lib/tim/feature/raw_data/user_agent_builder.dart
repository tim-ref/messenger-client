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
import 'package:flutter/foundation.dart';

const String defaultClientId = 'TIMRefMessengerClient';
const String userAgentHeaderName = 'X-TIM-User-Agent';

class UserAgentBuilder {
  UserAgent buildUserAgent() {
    return UserAgent(
      operatingSystemVersion: _getOperatingSystemVersion(),
      clientId: defaultClientId,
    );
  }

  String _getOperatingSystemVersion() {
    return kIsWeb ? 'web' : Platform.operatingSystemVersion;
  }
}
