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

import 'dart:convert';

import 'package:fluffychat/tim/feature/fhir/search/fhir_search_result.dart';
import 'package:fluffychat/tim/shared/provider/tim_provider.dart';
import 'package:flutter/material.dart';

class FhirSearchDebugWidget extends StatelessWidget {
  const FhirSearchDebugWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FhirSearchResult>?>(
      stream: TimProvider.of(context)
          .testDriverStateHelper()!
          .fhirSearchResults
          .stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            snapshot.error.toString(),
            key: const ValueKey("fhirSearchResultsError"),
          );
        }
        if (snapshot.hasData) {
          return Text(
            jsonEncode(snapshot.requireData?.map((e) => e.toJson()).toList()),
            key: const ValueKey("fhirSearchResults"),
          );
        }
        return const Text("no search results yet");
      },
    );
  }
}
