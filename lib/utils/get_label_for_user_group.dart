/*
 * TIM-Referenzumgebung
 * Copyright (C) 2025 – akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_policy.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

/// Determines the Label for user group values. If [throwOnNonExisting] is false, the method returns the value as is.
/// This is useful when parsing a String that might be a group, but might also be a MXID, or server name.
String getLabelForUserGroup(
    L10n l10n,
  String value, {
  bool throwOnNonExisting = true,
}) {

  if (UserGroup.isInsuredPerson.name == value) {
    return l10n.userGroupInsuredPerson;
  } else if (throwOnNonExisting) {
    throw UnsupportedError('Trying to display an invalid user group $value');
  } else {
    return value;
  }
}
