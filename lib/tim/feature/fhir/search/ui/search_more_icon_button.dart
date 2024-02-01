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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:vrouter/vrouter.dart';

class SearchMoreIconButton extends StatelessWidget {
  final String path;
  const SearchMoreIconButton({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Object>(
      key: const ValueKey("searchMoreIconButton"),
      itemBuilder: (context) {
        return <PopupMenuEntry<Object>>[
          PopupMenuItem(
            key: ValueKey("search:$path"),
            textStyle: Theme.of(context).textTheme.titleLarge,
            child: Text(L10n.of(context)!.timFhirSearchContextLabel),
            onTap: () => VRouter.of(context).to(path),
          ),
        ];
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 4, right: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_outlined,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            Icon(
              Icons.expand_more,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ],
        ),
      ),
    );
  }
}
