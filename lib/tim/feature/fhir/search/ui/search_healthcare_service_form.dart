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

import 'package:fluffychat/tim/feature/fhir/fhir_query_builder.dart';
import 'package:fluffychat/tim/feature/fhir/search/fhir_search_constants.dart';

class SearchHealthcareServiceForm extends StatefulWidget {
  final BehaviorSubject<String> searchQuery;

  const SearchHealthcareServiceForm({
    Key? key,
    required this.searchQuery,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchHealthcareServiceFormState();
}

class _SearchHealthcareServiceFormState
    extends State<SearchHealthcareServiceForm> {
  final TextEditingController _idCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _orgaNameCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _telematikIdCtrl = TextEditingController();
  final TextEditingController _orgaTypeCtrl = TextEditingController();

  Map<String, String> searchParams = {};

  @override
  void initState() {
    _idCtrl.addListener(
      () => _updateParams(MapEntry(healthcareId, _idCtrl.text)),
    );
    _nameCtrl.addListener(
      () => _updateParams(MapEntry(healthcareServiceName, _nameCtrl.text)),
    );
    _orgaNameCtrl.addListener(
      () => _updateParams(MapEntry(organizationName, _orgaNameCtrl.text)),
    );
    _addressCtrl.addListener(
      () => _updateParams(MapEntry(address, _addressCtrl.text)),
    );
    _telematikIdCtrl.addListener(
      () => _updateParams(
          MapEntry(organizationTelematikId, _telematikIdCtrl.text),),
    );
    _orgaTypeCtrl.addListener(
      () => _updateParams(MapEntry(organizationType, _orgaTypeCtrl.text)),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _buildFormItem(
            'fhirSearchHealthcareServiceIdTextField',
            L10n.of(context)!.timFhirSearchHealthcareServiceIdTextFieldLabel,
            _idCtrl,
          ),
          _buildFormItem(
            'fhirSearchHealthcareServiceNameTextField',
            L10n.of(context)!.timFhirSearchHealthcareServiceNameTextFieldLabel,
            _nameCtrl,
          ),
          _buildFormItem(
            'fhirSearchOrganizationNameTextField',
            L10n.of(context)!.timFhirSearchOrganizationNameTextFieldLabel,
            _orgaNameCtrl,
          ),
          _buildFormItem(
            'fhirSearchAddressTextField',
            L10n.of(context)!.timFhirSearchAddressLabel,
            _addressCtrl,
          ),
          _buildFormItem(
            'fhirSearchOrganizationTelematikIdTextField',
            L10n.of(context)!.timFhirSearchTelematikIdLabel,
            _telematikIdCtrl,
          ),
          _buildFormItem(
            'fhirSearchOrganizationTypeTextField',
            L10n.of(context)!.timFhirSearchOrganizationTypeTextFieldLabel,
            _orgaTypeCtrl,
          ),
        ],
      );

  Widget _buildFormItem(
    String fhirSearchFieldName,
    String fhirSearchFieldId,
    TextEditingController controller,
  ) =>
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        child: Semantics(
          label: fhirSearchFieldName,
          container: true,
          textField: true,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: fhirSearchFieldId,
            ),
          ),
        ),
      );

  void _updateParams(MapEntry<String, String> searchParam) {
    if (_paramIsDirty(searchParam)) {
      searchParam.value.isNotEmpty
          ? searchParams.update(
              searchParam.key,
              (_) => searchParam.value.trim(),
              ifAbsent: () => searchParam.value.trim(),
            )
          : searchParams.remove(searchParam.key);
      widget.searchQuery
          .add(FhirQueryBuilder.buildHealthcareServiceQuery(searchParams));
    }
  }

  bool _paramIsDirty(MapEntry<String, String> searchParam) {
    if (searchParams.containsKey(searchParam.key) &&
        searchParams[searchParam.key] != searchParam.value) {
      return true;
    } else {
      return !searchParams.containsKey(searchParam.key) &&
          searchParam.value.isNotEmpty;
    }
  }
}
