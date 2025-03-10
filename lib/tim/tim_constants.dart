/*
 * TIM-Referenzumgebung
 * Copyright (C) 2025 - akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

const String enableTestDriver = "ENABLE_TEST_DRIVER";
const String enableDebugWidget = "ENABLE_DEBUG_WIDGET";
const String debugWidgetVisible = "DEBUG_WIDGET_VISIBLE";

const String contactMgmtAPIPath = '/tim-contact-mgmt';
const String timInformationPath = '/tim-information';
const String tokenDispenserUser = 'TOKEN_DISPENSER_USER';
const String tokenDispenserPassword = 'TOKEN_DISPENSER_PASSWORD';

const String fhirAuthTokenStorageKey = 'fhirAuthToken';
const String defaultTokenDispenserUrl = 'TOKEN_DISPENSER_URL';

const String defaultHistoryVisibility =  'invited';

/// Types of room within TIM specification
enum TimRoomType {
  /// default room type if no case reference is needed
  defaultValue(value: 'de.gematik.tim.roomtype.default.v1'),

  /// special case reference for rooms, will be replaced by FHIR search API in the future
  caseReference(value: 'de.gematik.tim.roomtype.casereference.v1');

  const TimRoomType({required this.value});

  /// the defined room type value
  final String value;
}

/// Types of initial state events within TIM specification
enum TimRoomStateEventType {
  /// default room state event if no case reference is needed
  defaultValue(value: 'de.gematik.tim.room.default.v1'),

  /// special case reference event for custom rooms
  caseReference(value: 'de.gematik.tim.room.casereference.v1'),

  /// custom room name event
  roomName(value: 'de.gematik.tim.room.name'),

  /// custom room topic event
  roomTopic(value: 'de.gematik.tim.room.topic');

  const TimRoomStateEventType({required this.value});

  /// the defined room state event value
  final String value;
}
