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

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

/// A to-be-translated value.
///
/// This is modelled as a function depending on [L10n] rather than an l10n key because Flutter l10n
/// does not seem to support dynamic key lookup.
@immutable
class L10nValue extends Equatable {
  const L10nValue(String Function(L10n t) fn, [this.id] ) : _fn = fn;

  final String Function(L10n t) _fn;

  String call(L10n l) => _fn(l);

  final int? id;

  @override
  List<Object?> get props => [id];
}
