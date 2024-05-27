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

import 'package:fluffychat/tim/feature/fhir/dto/resource_type.dart';
import 'package:fluffychat/tim/feature/fhir/search/fhir_search_service.dart';
import 'package:fluffychat/tim/feature/fhir/search/ui/search_form.dart';
import 'package:fluffychat/tim/feature/fhir/search/ui/search_result_view.dart';
import 'package:fluffychat/tim/feature/fhir/search/ui/search_title.dart';
import 'package:fluffychat/tim/shared/provider/tim_provider.dart';
import 'package:fluffychat/tim/test_driver/test_driver_state_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vrouter/vrouter.dart';

const OptionalFhirSearchResultSet EMPTY_RESULT = (entries: null, response: '');

class FhirSearchView extends StatefulWidget {
  const FhirSearchView({Key? key}) : super(key: key);

  @override
  State<FhirSearchView> createState() => _FhirSearchViewState();
}

class _FhirSearchViewState extends State<FhirSearchView> {
  final BehaviorSubject<ResourceType> _selectedSearchType =
      BehaviorSubject.seeded(ResourceType.PractitionerRole);
  final BehaviorSubject<String> _searchQuery = BehaviorSubject.seeded('');

  late FhirSearchService _searchService;
  late final PublishSubject<OptionalFhirSearchResultSet>? _fhirSearchResults;

  Future<FhirSearchResultSet>? _searchResults;
  String? roomId;

  @override
  void initState() {
    _searchService = TimProvider.of(context).fhirSearchService();
    _fhirSearchResults = TimProvider.of(context).testDriverStateHelper()?.fhirSearchResults;
    _selectedSearchType.distinct().listen((resourceType) {
      _resetSearchQuery();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    roomId = context.vRouter.pathParameters['roomid'];
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _buildAppBar(),
        resizeToAvoidBottomInset: true,
        body: StreamBuilder<ResourceType>(
          stream: _selectedSearchType.stream,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return _buildSearchLoadingIndicator();
              default:
                return _buildSearchAndResultsView();
            }
          },
        ),
        floatingActionButton: _buildSearchButton(),
      );

  AppBar _buildAppBar() => AppBar(
        title: SearchTitle(_selectedSearchType),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      );

  Widget _buildSearchLoadingIndicator() => const Center(child: CircularProgressIndicator());

  Widget _buildSearchAndResultsView() => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          SearchForm(
            selectedSearchType: _selectedSearchType,
            searchQuery: _searchQuery,
          ),
          FutureBuilder<FhirSearchResultSet>(
            future: _searchResults,
            builder: (context, searchResultSnapshot) {
              if (searchResultSnapshot.hasData && searchResultSnapshot.data!.entries.isNotEmpty) {
                return const Divider();
              } else {
                return Container();
              }
            },
          ),
          SearchResultView(_searchResults),
        ],
      );

  Widget _buildSearchButton() => FloatingActionButton.extended(
        onPressed: _search,
        key: const ValueKey("timFhirSearchButton"),
        label: Text(L10n.of(context)!.timFhirSearchButtonLabel),
      );

  void _search() {
    if (_searchQuery.value.isEmpty) {
      return;
    }
    _fhirSearchResults?.add(EMPTY_RESULT);
    final query = _searchQuery.value;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      if (_selectedSearchType.value == ResourceType.HealthcareService) {
        _searchResults = _searchService.searchHealthcareService(query);
      } else {
        _searchResults = _searchService.searchPractitionerRole(query);
      }
    });
  }

  @override
  void dispose() {
    _searchQuery.close();
    _selectedSearchType.close();
    super.dispose();
  }

  void _resetSearchQuery() {
    _searchQuery.add('');
  }
}
