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

extension BeautifyStringExtension on String {
  String get beautified {
    var beautifiedStr = '';
    for (var i = 0; i < length; i++) {
      beautifiedStr += substring(i, i + 1);
      if (i % 4 == 3) {
        beautifiedStr += ' ';
      }
      if (i % 16 == 15) {
        beautifiedStr += '\n';
      }
    }
    return beautifiedStr;
  }
}
