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

import 'dart:ui';

abstract class AppConfig {
  static const String _applicationName = 'FluffyChat';

  static String get applicationName => _applicationName;
  static String? _applicationWelcomeMessage;

  static String? get applicationWelcomeMessage => _applicationWelcomeMessage;
  static const String _defaultHomeserver = '';

  static String get defaultHomeserver => _defaultHomeserver;
  static double bubbleSizeFactor = 1;
  static double fontSizeFactor = 1;
  static const Color chatColor = primaryColor;
  static Color? colorSchemeSeed = primaryColor;
  static const double messageFontSize = 15.75;
  static const bool allowOtherHomeservers = true;
  static const bool enableRegistration = true;
  static const Color primaryColor = Color(0xFFADD52C);
  static const Color primaryColorLight = Color(0xFFC8F249);
  static const Color secondaryColor = Color(0xFF5B6147);
  static const String _privacyUrl = 'https://www.gematik.de/datenschutz';

  static String get privacyUrl => _privacyUrl;
  static const String enablePushTutorial =
      'https://gitlab.com/famedly/fluffychat/-/wikis/Push-Notifications-without-Google-Services';
  static const String encryptionTutorial =
      'https://gitlab.com/famedly/fluffychat/-/wikis/How-to-use-end-to-end-encryption-in-FluffyChat';
  static const String appOpenUrlScheme = 'im.fluffychat';
  static const String _webBaseUrl = 'https://fluffychat.im/web';

  static String get webBaseUrl => _webBaseUrl;
  static const String sourceCodeUrl = 'https://gitlab.com/famedly/fluffychat';
  static const String supportUrl = 'https://gitlab.com/famedly/fluffychat/issues';
  static const bool enableSentry = true;
  static const String sentryDns =
      'https://8591d0d863b646feb4f3dda7e5dcab38@o256755.ingest.sentry.io/5243143';
  static bool renderHtml = true;
  static bool hideRedactedEvents = false;
  static bool hideUnknownEvents = true;
  static bool hideUnimportantStateEvents = true;
  static bool showDirectChatsInSpaces = true;
  static bool separateChatTypes = false;
  static bool autoplayImages = true;
  static bool sendOnEnter = false;
  static bool sendTypingNotifications = false;
  static bool sendReadReceipts = false;
  static bool sendPresenceUpdates = false;
  static bool experimentalVoip = false;
  static const bool hideTypingUsernames = false;
  static const bool hideAllStateEvents = false;
  static const String inviteLinkPrefix = 'https://test1.eu.timref.akquinet.nx2.dev/#/';
  static const String deepLinkPrefix = 'im.fluffychat://chat/';
  static const String schemePrefix = 'matrix:';
  static const String pushNotificationsChannelId = 'timessenger_push';
  static const String pushNotificationsChannelName = 'TIMessenger push channel';
  static const String pushNotificationsChannelDescription = 'Push notifications for TIMessenger';
  static const String pushNotificationsAndroidAppId = 'de.akquinet.timref.messengerclient';
  static const String pushNotificationsIOSAppId = 'de.akquinet.timref.messenger-client';
  static const String pushNotificationsGatewayUrl =
      'https://matrix.push.akquinet.de/_matrix/push/v1/notify';
  static const String pushNotificationsPusherFormat = '';
  static const String emojiFontName = 'Noto Emoji';
  static const String emojiFontUrl = 'https://github.com/googlefonts/noto-emoji/';
  static const double borderRadius = 16.0;
  static const double columnWidth = 360.0;
}
