/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - 2025 akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/tim/feature/fhir/search/fhir_search_result.dart';
import 'package:matrix/matrix.dart';
import 'package:rxdart/subjects.dart';
import 'package:tim_contact_management_api/api.dart';

/// A List of FhirSearchResults and the original parsed JSON-formatted String
typedef OptionalFhirSearchResultSet = ({List<FhirSearchResult>? entries, String? response});

class TestDriverStateHelper {
  late PublishSubject<List<Contact>?> contactApprovalListViewData;
  late PublishSubject<OptionalFhirSearchResultSet> fhirSearchResults;
  late PublishSubject<Timeline?> roomTimeline;

  void initTestDriverSubjects() {
    contactApprovalListViewData = PublishSubject<List<Contact>?>();
    fhirSearchResults = PublishSubject<OptionalFhirSearchResultSet>();
    roomTimeline = PublishSubject<Timeline?>();
  }

  void disposeTestDriverSubjects() {
    contactApprovalListViewData.close();
    fhirSearchResults.close();
    roomTimeline.close();
  }
}
