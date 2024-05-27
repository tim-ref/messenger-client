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

import 'package:fluffychat/tim/feature/fhir/search/fhir_search_result.dart';
import 'package:fluffychat/tim/feature/fhir/search/fhir_search_service.dart';
import 'package:fluffychat/tim/feature/fhir/search/healthcare_service_search_result.dart';
import 'package:fluffychat/tim/feature/fhir/search/practitioner_search_result.dart';
import 'package:fluffychat/tim/feature/fhir/search/ui/healthcare_service_search_result_list_tile.dart';
import 'package:fluffychat/tim/feature/fhir/search/ui/practitioner_search_result_list_tile.dart';
import 'package:fluffychat/tim/shared/provider/tim_provider.dart';
import 'package:fluffychat/tim/test_driver/test_driver_state_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

final OptionalFhirSearchResultSet EMPTY_RESULT = (entries: [], response: '');

class SearchResultView extends StatelessWidget {
  final Future<FhirSearchResultSet>? _searchResult;

  const SearchResultView(this._searchResult, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fhirSearchResults = TimProvider.of(context).testDriverStateHelper()?.fhirSearchResults;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FutureBuilder<FhirSearchResultSet>(
        future: _searchResult,
        builder: (context, searchResultSnapshot) {
          switch (searchResultSnapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            default:
              if (searchResultSnapshot.hasError) {
                fhirSearchResults?.addError(searchResultSnapshot.error!);
                Logs().e(
                  'Error in Fhir Search',
                  searchResultSnapshot.error,
                  searchResultSnapshot.stackTrace,
                );
                return _buildSearchError(searchResultSnapshot);
              } else if (searchResultSnapshot.hasData &&
                  searchResultSnapshot.data!.entries.isNotEmpty) {
                fhirSearchResults?.add(searchResultSnapshot.data!);
                return _buildSearchResults(searchResultSnapshot.data!.entries);
              } else {
                fhirSearchResults?.add(EMPTY_RESULT);
                return _buildSearchEmpty(context);
              }
          }
        },
      ),
    );
  }

  Widget _buildSearchError(AsyncSnapshot<FhirSearchResultSet> snapshot) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(snapshot.error.toString()),
        ),
      );

  Widget _buildSearchResults(List<FhirSearchResult> results) => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: results.length,
        itemBuilder: (BuildContext context, int index) {
          final entry = results[index];
          if (entry is PractitionerSearchResult) {
            return PractitionerSearchResultListTile(entry);
          }
          return HealthcareServiceSearchResultListTile(
            entry as HealthcareServiceSearchResult,
          );
        },
      );

  Widget _buildSearchEmpty(BuildContext context) => Center(
        child: Text(L10n.of(context)!.timFhirSearchEmpty),
      );
}
