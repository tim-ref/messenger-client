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

import 'package:fluffychat/tim/feature/fhir/fhir_endpoint_address_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:matrix/matrix.dart';
import 'package:rxdart/subjects.dart';

import 'package:fluffychat/tim/feature/fhir/fhir_query_builder.dart';
import 'package:fluffychat/tim/feature/fhir/search/fhir_search_constants.dart';

import '../practitioner_qualification_mapping.dart';

class SearchPractitionerForm extends StatefulWidget {
  final BehaviorSubject<String> searchQuery;

  const SearchPractitionerForm({
    Key? key,
    required this.searchQuery,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchPractitionerFormState();
}

class _SearchPractitionerFormState extends State<SearchPractitionerForm> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _telematikIdCtrl = TextEditingController();
  final TextEditingController _endpointCtrl = TextEditingController();
  final TextEditingController _qualificationsCtrl = TextEditingController();

  Map<String, String> searchParams = {};

  @override
  void initState() {
    _nameCtrl.addListener(
      () => _updateParams(MapEntry(practitionerName, _nameCtrl.text)),
    );
    _addressCtrl.addListener(
      () => _updateParams(MapEntry(address, _addressCtrl.text)),
    );
    _telematikIdCtrl.addListener(
      () => _updateParams(MapEntry(practitionerTelematikId, _telematikIdCtrl.text)),
    );
    _endpointCtrl.addListener(
      () {
        final searchText = _endpointCtrl.text;

        if (searchText.startsWith(uriPrefix) &&
            convertUriToSigil(searchText).isValidMatrixId) {
          searchParams.remove(displayName);
          _updateParams(MapEntry(mxid, searchText));
        } else {
          searchParams.remove(mxid);
          _updateParams(MapEntry(displayName, searchText));
        }
      },
    );
    _qualificationsCtrl.addListener(
      () {
        final l10n = L10n.of(context)!;
        // get correct id for current selected value
        final selectedL10nVal = practitionerQualificationMapping.keys.firstWhere(
          (element) => element.call(l10n) == _qualificationsCtrl.text,
          orElse: () => practitionerQualificationMapping.keys.first,
        );

        _updateParams(
          MapEntry(
            practitionerQualification,
            practitionerQualificationMapping[selectedL10nVal]!,
          ),
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _buildFormItem(
            'fhirSearchPractitionerNameTextField',
            L10n.of(context)!.timFhirSearchPractitionerRoleTextFieldLabel,
            _nameCtrl,
          ),
          _buildFormItem(
            'fhirSearchPractitionerAddressTextField',
            L10n.of(context)!.timFhirSearchAddressLabel,
            _addressCtrl,
          ),
          _buildFormItem(
            'fhirSearchPractitionerTelematikIdTextField',
            L10n.of(context)!.timFhirSearchTelematikIdLabel,
            _telematikIdCtrl,
          ),
          _buildFormItem(
            'fhirSearchPractitionerMxidTextField',
            L10n.of(context)!.timFhirSearchMatrixUserLabel,
            _endpointCtrl,
          ),
          _buildDropdownFormItem(
            'fhirSearchPractitionerQualificationsTextField',
            L10n.of(context)!.timFhirSearchQualificationLabel,
            _qualificationsCtrl,
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

  Widget _buildDropdownFormItem(
    String fhirSearchFieldName,
    String fhirSearchFieldId,
    TextEditingController controller,
  ) {
    final l10n = L10n.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                labelText: fhirSearchFieldId,
              ),
              isExpanded: true,
              menuMaxHeight: MediaQuery.sizeOf(context).height / 2,
              borderRadius: BorderRadius.circular(8),
              items: practitionerQualificationMapping.keys
                  .map((fn) => fn.call(l10n))
                  .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value is String) {
                  setState(() {
                    controller.text = value;
                  });
                }
              },
              value: controller.text,
            ),
          ),
        ],
      ),
    );
  }

  void _updateParams(MapEntry<String, String> searchParam) {
    if (_paramIsDirty(searchParam)) {
      searchParam.value.isNotEmpty
          ? searchParams.update(
              searchParam.key,
              (_) => searchParam.value.trim(),
              ifAbsent: () => searchParam.value.trim(),
            )
          : searchParams.remove(searchParam.key);
      widget.searchQuery.add(FhirQueryBuilder.buildPractitionerRoleQuery(searchParams));
    }
  }

  bool _paramIsDirty(MapEntry<String, String> searchParam) {
    if (searchParams.containsKey(searchParam.key) &&
        searchParams[searchParam.key] != searchParam.value) {
      return true;
    } else {
      return !searchParams.containsKey(searchParam.key) && searchParam.value.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _telematikIdCtrl.dispose();
    _endpointCtrl.dispose();
    _qualificationsCtrl.dispose();
    super.dispose();
  }
}
