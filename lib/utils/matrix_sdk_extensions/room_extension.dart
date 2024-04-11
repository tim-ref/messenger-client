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

import 'package:fluffychat/tim/tim_constants.dart';
import 'package:matrix/matrix.dart';

/// Extend the Matrix SDK Room class with TIM custom room functionality
///
/// To get the correct values use these functions over Matrix SDK Room class
extension RoomExtension on Room {
  /// The name of the room if set by a participant.
  String get displayName {
    final state = getState(TimRoomStateEventType.roomName.value) ?? getState(EventTypes.RoomName);
    final contentName = state?.content['name'];
    return (contentName is String) ? contentName : '';
  }

  /// The topic of the room if set by a participant.
  String get displayTopic {
    final state = getState(TimRoomStateEventType.roomTopic.value) ?? getState(EventTypes.RoomName);
    final contentTopic = state?.content['topic'];
    return contentTopic is String ? contentTopic : '';
  }

  /// The type of the room, defaults to TimRoomTypes.timDefault
  String get roomType {
    return getState(EventTypes.RoomCreate)?.content['type'] ?? TimRoomType.defaultValue.value;
  }

  /// Check if room type is casereference
  bool get isCaseReferenceRoom => roomType == TimRoomType.caseReference.value;

  /// Content of CustomRoom Type Initial State Events
  Map<String, dynamic> get caseReferenceContent {
    final state = getState(TimRoomStateEventType.caseReference.value) ??
        getState(TimRoomStateEventType.defaultValue.value);
    return state?.content ?? {};
  }

  /// Returns a localized displayname for this server. If the room is a groupchat
  /// without a name, then it will return the localized version of 'Group with Alice' instead
  /// of just 'Alice' to make it different to a direct chat.
  /// Empty chats will become the localized version of 'Empty Chat'.
  /// This method requires a localization class which implements [MatrixLocalizations]
  String getLocalizedDisplaynameFromCustomNameEvent([
    MatrixLocalizations i18n = const MatrixDefaultLocalizations(),
  ]) {
    if (displayName.isNotEmpty) return displayName;

    final canonicalAlias = this.canonicalAlias.localpart;
    if (canonicalAlias != null && canonicalAlias.isNotEmpty) {
      return canonicalAlias;
    }

    final directChatMatrixID = this.directChatMatrixID;
    final heroes = summary.mHeroes ?? (directChatMatrixID == null ? [] : [directChatMatrixID]);
    if (heroes.isNotEmpty) {
      final result = heroes
          .where((hero) => hero.isNotEmpty)
          .map((hero) => unsafeGetUserFromMemoryOrFallback(hero).calcDisplayname())
          .join(', ');
      if (isAbandonedDMRoom) {
        return i18n.wasDirectChatDisplayName(result);
      }

      return isDirectChat ? result : i18n.groupWith(result);
    }
    switch (membership) {
      case Membership.invite:
        final sender = getState(EventTypes.RoomMember, client.userID!)
            ?.senderFromMemoryOrFallback
            .calcDisplayname();
        if (sender != null) return sender;
        break;
      case Membership.join:
        final invitation = getState(EventTypes.RoomMember, client.userID!);
        if (invitation != null && invitation.unsigned?['prev_sender'] != null) {
          final name = unsafeGetUserFromMemoryOrFallback(invitation.unsigned?['prev_sender'])
              .calcDisplayname();
          return i18n.wasDirectChatDisplayName(name);
        }
        break;
      default: // ignore other Membership states
    }
    return i18n.emptyChat;
  }

  /// Call the Matrix API to change the name of this room.
  /// Returns the event ID of the new room event.
  Future<String> setDisplayName(String value) => client.setRoomStateWithKey(
        id,
        TimRoomStateEventType.roomName.value,
        '',
        {'name': value},
      );

  /// Call the Matrix API to change the topic of this room.
  Future<String> setDisplayTopic(String value) => client.setRoomStateWithKey(
        id,
        TimRoomStateEventType.roomTopic.value,
        '',
        {'topic': value},
      );
}
