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

abstract class SettingKeys {
  static const String wallpaper = 'chat.fluffy.wallpaper';
  static const String renderHtml = 'chat.fluffy.renderHtml';
  static const String hideRedactedEvents = 'chat.fluffy.hideRedactedEvents';
  static const String hideUnknownEvents = 'chat.fluffy.hideUnknownEvents';
  static const String hideUnimportantStateEvents =
      'chat.fluffy.hideUnimportantStateEvents';
  static const String showDirectChatsInSpaces =
      'chat.fluffy.showDirectChatsInSpaces';
  static const String separateChatTypes = 'chat.fluffy.separateChatTypes';
  static const String sentry = 'sentry';
  static const String theme = 'theme';
  static const String amoledEnabled = 'amoled_enabled';
  static const String codeLanguage = 'code_language';
  static const String showNoGoogle = 'chat.fluffy.show_no_google';
  static const String bubbleSizeFactor = 'chat.fluffy.bubble_size_factor';
  static const String fontSizeFactor = 'chat.fluffy.font_size_factor';
  static const String showNoPid = 'chat.fluffy.show_no_pid';
  static const String databasePassword = 'database-password';
  static const String appLockKey = 'chat.fluffy.app_lock';
  static const String unifiedPushRegistered =
      'chat.fluffy.unifiedpush.registered';
  static const String unifiedPushEndpoint = 'chat.fluffy.unifiedpush.endpoint';
  static const String notificationCurrentIds = 'chat.fluffy.notification_ids';
  static const String ownStatusMessage = 'chat.fluffy.status_msg';
  static const String dontAskForBootstrapKey =
      'chat.fluffychat.dont_ask_bootstrap';
  static const String autoplayImages = 'chat.fluffy.autoplay_images';
  static const String sendOnEnter = 'chat.fluffy.send_on_enter';
  static const String sendTypingNotifications = 'chat.fluffy.send_typing_notifications';
  static const String sendReadReceipts = 'chat.fluffy.send_read_receipts';
  static const String sendPresenceUpdates = 'chat.fluffy.send_presence_updates';
  static const String experimentalVoip = 'chat.fluffy.experimental_voip';
}
