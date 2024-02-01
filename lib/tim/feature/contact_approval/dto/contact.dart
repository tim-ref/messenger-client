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

import 'package:json_annotation/json_annotation.dart';

import 'package:fluffychat/tim/feature/contact_approval/dto/invite_settings.dart';

part 'contact.g.dart';

@JsonSerializable()
class Contact {
  final String displayName;
  final String mxid;
  final InviteSettings inviteSettings;

  Contact({
    required this.displayName,
    required this.mxid,
    required this.inviteSettings,
  });

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);

  Contact copyWith({InviteSettings? newInviteSettings}) => Contact(
        displayName: displayName,
        mxid: mxid,
        inviteSettings: newInviteSettings ?? inviteSettings,
      );

  Map<String, dynamic> toJson() => _$ContactToJson(this);

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contact &&
          runtimeType == other.runtimeType &&
          displayName == other.displayName &&
          mxid == other.mxid &&
          inviteSettings == other.inviteSettings;
}
