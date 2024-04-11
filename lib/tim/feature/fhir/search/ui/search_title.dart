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

import 'package:rxdart/rxdart.dart';

import 'package:fluffychat/tim/feature/fhir/dto/resource_type.dart';
import 'package:fluffychat/tim/feature/fhir/search/resource_type_localization_helper.dart';

class SearchTitle extends StatelessWidget {
  final BehaviorSubject<ResourceType> selectedSearchType;

  const SearchTitle(this.selectedSearchType, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ResourceType>(
      stream: selectedSearchType.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          default:
            return PopupMenuButton<Object>(
              key: const ValueKey("selectedSearchType"),
              itemBuilder: (context) {
                return <PopupMenuEntry<Object>>[
                  PopupMenuItem(
                    key: const ValueKey("practitionerRole"),
                    textStyle: Theme.of(context).textTheme.titleLarge,
                    child: Text(
                        L10n.of(context)!.timFhirResourceTypePractitionerRole,),
                    onTap: () {
                      selectedSearchType.add(ResourceType.PractitionerRole);
                    },
                  ),
                  PopupMenuItem(
                    key: const ValueKey("healthcareService"),
                    textStyle: Theme.of(context).textTheme.titleLarge,
                    child: Text(
                        L10n.of(context)!.timFhirResourceTypeHealthcareService,),
                    onTap: () {
                      selectedSearchType.add(ResourceType.HealthcareService);
                    },
                  ),
                ];
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      L10n.of(context)!.timFhirSearchTitle(
                        ResourceTypeLocalizationHelper
                            .getAppBarTitleByResourceType(
                          context,
                          snapshot.data!,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.expand_more,
                    key: const ValueKey("expandMoreIcon"),
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ],
              ),
            );
        }
      },
    );
  }
}
