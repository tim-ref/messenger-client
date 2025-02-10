/*
 * Modified by akquinet GmbH on 24.01.2025
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

/// Provides extra functionality for formatting the time.
extension DateTimeExtension on DateTime {
  /// Constructs a new [DateTime] instance
  /// with the given [secondsSinceEpoch].
  ///
  /// If [isUtc] is false then the date is in the local time zone.
  ///
  /// The constructed [DateTime] represents
  /// 1970-01-01T00:00:00Z + [secondsSinceEpoch] s in the given
  /// time zone (local or UTC).
  /// ```dart
  /// final newYearsDay =
  ///     DateTime.fromSecondsSinceEpoch(1640979000, isUtc:true);
  /// print(newYearsDay); // 2022-01-01 10:00:00.000Z
  /// ```
  static DateTime fromSecondsSinceEpoch(int secondsSinceEpoch, {isUtc}) =>
      DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch * 1000, isUtc: isUtc);

  /// The number of milliseconds since
  /// the "Unix epoch" 1970-01-01T00:00:00Z (UTC).
  ///
  /// This value is independent of the time zone.
  ///
  /// This value is at most
  /// 8,640,000,000,000s (100,000,000 days) from the Unix epoch.
  /// In other words: `secondsSinceEpoch.abs() <= 8640000000000`.
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;

  bool operator <(DateTime other) {
    return millisecondsSinceEpoch < other.millisecondsSinceEpoch;
  }

  bool operator >(DateTime other) {
    return millisecondsSinceEpoch > other.millisecondsSinceEpoch;
  }

  bool operator >=(DateTime other) {
    return millisecondsSinceEpoch >= other.millisecondsSinceEpoch;
  }

  bool operator <=(DateTime other) {
    return millisecondsSinceEpoch <= other.millisecondsSinceEpoch;
  }

  /// Two message events can belong to the same environment. That means that they
  /// don't need to display the time they were sent because they are close
  /// enaugh.
  static const minutesBetweenEnvironments = 5;

  /// Checks if two DateTimes are close enough to belong to the same
  /// environment.
  bool sameEnvironment(DateTime prevTime) {
    return millisecondsSinceEpoch - prevTime.millisecondsSinceEpoch <
        1000 * 60 * minutesBetweenEnvironments;
  }

  /// Returns a simple time String.
  /// TODO: Add localization
  String localizedTimeOfDay(BuildContext context) {
    if (MediaQuery.of(context).alwaysUse24HourFormat) {
      return '${_z(hour)}:${_z(minute)}';
    } else {
      return '${_z(hour % 12 == 0 ? 12 : hour % 12)}:${_z(minute)} ${hour > 11 ? "pm" : "am"}';
    }
  }

  /// Returns [localizedTimeOfDay()] if the ChatTime is today, the name of the week
  /// day if the ChatTime is this week and a date string else.
  String localizedTimeShort(BuildContext context) {
    final now = DateTime.now();

    final sameYear = now.year == year;

    final sameDay = sameYear && now.month == month && now.day == day;

    final sameWeek = sameYear &&
        !sameDay &&
        now.millisecondsSinceEpoch - millisecondsSinceEpoch < 1000 * 60 * 60 * 24 * 7;

    if (sameDay) {
      return localizedTimeOfDay(context);
    } else if (sameWeek) {
      switch (weekday) {
        case 1:
          return L10n.of(context)!.monday;
        case 2:
          return L10n.of(context)!.tuesday;
        case 3:
          return L10n.of(context)!.wednesday;
        case 4:
          return L10n.of(context)!.thursday;
        case 5:
          return L10n.of(context)!.friday;
        case 6:
          return L10n.of(context)!.saturday;
        case 7:
          return L10n.of(context)!.sunday;
      }
    } else if (sameYear) {
      return L10n.of(context)!.dateWithoutYear(
        month.toString().padLeft(2, '0'),
        day.toString().padLeft(2, '0'),
      );
    }
    return localizedDate(context);
  }

  /// If the DateTime is today, this returns [localizedTimeOfDay()], if not it also
  /// shows the date.
  /// TODO: Add localization
  String localizedTime(BuildContext context) {
    final now = DateTime.now();

    final sameYear = now.year == year;

    final sameDay = sameYear && now.month == month && now.day == day;

    return sameDay
        ? localizedTimeOfDay(context)
        : L10n.of(context)!.dateAndTimeOfDay(
            localizedTimeShort(context),
            localizedTimeOfDay(context),
          );
  }

  /// Return a combination of localized date and time String
  String localizedDateTime(BuildContext context) {
    return L10n.of(context)!.dateAndTimeOfDay(
      localizedDate(context),
      localizedTimeOfDay(context),
    );
  }

  /// Return a localized Date String
  String localizedDate(BuildContext context) {
    return L10n.of(context)!.dateWithYear(
      year.toString(),
      month.toString().padLeft(2, '0'),
      day.toString().padLeft(2, '0'),
    );
  }

  static String _z(int i) => i < 10 ? '0${i.toString()}' : i.toString();
}
