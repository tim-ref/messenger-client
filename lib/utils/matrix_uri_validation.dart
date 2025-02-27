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

const _matrixUrlRegEx =
    r'(https:\/\/matrix.to\/#\/\@|matrix:([eru]|roomid)\/)[a-zA-Z0-9\.\_\-]+:[a-zA-Z0-9\.\_\-]+';

/// Check if the given value is a wellformed Matrix URI
/// https://spec.matrix.org/v1.3/appendices/#uris
bool checkExpectedMatrixUriIsValid(String value) => RegExp(_matrixUrlRegEx).hasMatch(value);
