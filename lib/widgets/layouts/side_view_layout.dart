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

import 'package:flutter/material.dart';

import 'package:vrouter/vrouter.dart';

import 'package:fluffychat/config/themes.dart';

class SideViewLayout extends StatelessWidget {
  final Widget mainView;
  final Widget? sideView;

  const SideViewLayout({Key? key, required this.mainView, this.sideView})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    var currentUrl = Uri.decodeFull(VRouter.of(context).url);
    if (!currentUrl.endsWith('/')) currentUrl += '/';
    final hideSideView = currentUrl.split('/').length == 4;
    final sideView = this.sideView;
    return sideView == null
        ? mainView
        : MediaQuery.of(context).size.width < FluffyThemes.columnWidth * 3.5 &&
                !hideSideView
            ? sideView
            : Row(
                children: [
                  Expanded(
                    child: ClipRRect(child: mainView),
                  ),
                  Container(
                    width: 1.0,
                    color: Theme.of(context).dividerColor,
                  ),
                  AnimatedContainer(
                    duration: FluffyThemes.animationDuration,
                    curve: FluffyThemes.animationCurve,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(),
                    width: hideSideView ? 0 : 360.0,
                    child: hideSideView ? null : sideView,
                  ),
                ],
              );
  }
}
