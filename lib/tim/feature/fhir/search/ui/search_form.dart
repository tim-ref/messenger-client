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

import 'package:rxdart/rxdart.dart';

import 'package:fluffychat/tim/feature/fhir/dto/resource_type.dart';
import 'package:fluffychat/tim/feature/fhir/search/ui/search_healthcare_service_form.dart';
import 'package:fluffychat/tim/feature/fhir/search/ui/search_practitioner_form.dart';

class SearchForm extends StatelessWidget {
  final BehaviorSubject<ResourceType> selectedSearchType;
  final BehaviorSubject<String> searchQuery;

  const SearchForm({
    Key? key,
    required this.selectedSearchType,
    required this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ResourceType>(
      stream: selectedSearchType.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(),
            );
          default:
            final resourceType = snapshot.data!;
            switch (resourceType) {
              case ResourceType.HealthcareService:
                return SearchHealthcareServiceForm(searchQuery: searchQuery);
              default:
                return SearchPractitionerForm(searchQuery: searchQuery);
            }
        }
      },
    );
  }
}
