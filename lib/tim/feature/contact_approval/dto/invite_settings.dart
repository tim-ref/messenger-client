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

part 'invite_settings.g.dart';

@JsonSerializable()
class InviteSettings {
  @JsonKey(fromJson: _startFromJson, toJson: _startToJson)
  final DateTime start;
  @JsonKey(fromJson: _endFromJson, toJson: _endToJson)
  final DateTime? end;

  InviteSettings({required this.start, this.end});

  factory InviteSettings.fromJson(Map<String, dynamic> json) =>
      _$InviteSettingsFromJson(json);

  InviteSettings copyWith({DateTime? newEnd}) =>
      InviteSettings(start: start, end: newEnd ?? end);

  Map<String, dynamic> toJson() => _$InviteSettingsToJson(this);

  static DateTime _startFromJson(int secondsSinceEpoch) =>
      DateTime.fromMillisecondsSinceEpoch(
              _toMillisecondsSinceEpoch(secondsSinceEpoch))
          .toUtc();

  static int _startToJson(DateTime time) =>
      _toSecondsSinceEpoch(time.toUtc().millisecondsSinceEpoch);

  static DateTime? _endFromJson(
          int? secondsSinceEpoch) =>
      secondsSinceEpoch != null
          ? DateTime.fromMillisecondsSinceEpoch(
                  _toMillisecondsSinceEpoch(secondsSinceEpoch))
              .toUtc()
          : null;

  static int? _endToJson(DateTime? time) => time != null
      ? _toSecondsSinceEpoch(time.toUtc().millisecondsSinceEpoch)
      : null;

  static int _toMillisecondsSinceEpoch(int secondsSinceEpoch) =>
      secondsSinceEpoch * 1000;

  static _toSecondsSinceEpoch(int millisecondsSinceEpoch) =>
      millisecondsSinceEpoch ~/ 1000;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InviteSettings &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;
}
