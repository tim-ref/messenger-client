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

class PractitionerVisibility {
  /// Has active TIM Endpoints
  final bool isGenerallyVisible;

  /// Has active TIM Endpoints hidden from insurees
  final bool? isVisibleExceptFromInsurees;

  PractitionerVisibility({required this.isGenerallyVisible, this.isVisibleExceptFromInsurees});

  PractitionerVisibility.none()
      : isGenerallyVisible = false,
        isVisibleExceptFromInsurees = null;
}
