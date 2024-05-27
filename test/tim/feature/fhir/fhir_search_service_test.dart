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

import 'package:fluffychat/tim/feature/fhir/dto/entry.dart';
import 'package:fluffychat/tim/feature/fhir/dto/resource_type.dart';
import 'package:fluffychat/tim/feature/fhir/fhir_query_builder.dart';
import 'package:fluffychat/tim/feature/fhir/fhir_repository.dart';
import 'package:fluffychat/tim/feature/fhir/search/fhir_search_constants.dart';
import 'package:fluffychat/tim/feature/fhir/search/fhir_search_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'fhir_search_service_test.mocks.dart';
import 'fhir_search_service_test_data.dart';

@GenerateMocks([FhirRepository])
void main() {
  late final MockFhirRepository fhirRepository;
  late final FhirSearchService searchService;

  setUpAll(() {
    fhirRepository = MockFhirRepository();
    searchService = FhirSearchService(fhirRepository);
  });

  test('searchPractitionerRole() should correctly map results for complete Dataset', () async {
    // given
    final expectedQuery = buildPRQuery();
    when(fhirRepository.search(ResourceType.PractitionerRole, expectedQuery)).thenAnswer((_) async {
      return (
        entries: FhirSearchServiceTestData.practitionerRoleCompleteEntries(),
        response: '{"resourceType":"Bundle"}'
      );
    });

    //when
    final (entries: entries, response: response) =
        await searchService.searchPractitionerRole(expectedQuery);

    // expect
    expect(entries.length, equals(1));
    expect(entries[0].practitionerName, equals('Dr FirstName LastName'));
    expect(entries[0].endpointAdresses![0], equals('@endpoint1:test.de'));
    expect(entries[0].endpointNames![0], equals('Tim Endpoint 1'));
    expect(response, equals('{"resourceType":"Bundle"}'));
  });

  test('searchPractitionerRole() Should not map results missing Practitioner reference', () async {
    // given
    final expectedQuery = buildPRQuery();
    when(fhirRepository.search(ResourceType.PractitionerRole, expectedQuery)).thenAnswer((_) async {
      return (
        entries: FhirSearchServiceTestData.practitionerRoleEntriesMissingPractitionerReference(),
        response: '{"resourceType":"Bundle"}'
      );
    });

    //when
    final (entries: entries, response: response) =
        await searchService.searchPractitionerRole(expectedQuery);

    // expect
    expect(entries, isEmpty);
    expect(response, equals('{"resourceType":"Bundle"}'));
  });

  test('searchPractitionerRole() Should not map results missing Practitioner reference value',
      () async {
    // given
    final expectedQuery = buildPRQuery();
    when(fhirRepository.search(ResourceType.PractitionerRole, expectedQuery)).thenAnswer((_) async {
      return (
        entries:
            FhirSearchServiceTestData.practitionerRoleEntriesMissingPractitionerReferenceValue(),
        response: '{"resourceType":"Bundle"}'
      );
    });

    //when
    final (entries: entries, response: response) =
        await searchService.searchPractitionerRole(expectedQuery);

    // expect
    expect(entries, isEmpty);
    expect(response, equals('{"resourceType":"Bundle"}'));
  });

  test('searchPractitionerRole() Should not map results missing endpoint reference', () async {
    // given
    final expectedQuery = buildPRQuery();
    when(fhirRepository.search(ResourceType.PractitionerRole, expectedQuery)).thenAnswer((_) async {
      return (
        entries: FhirSearchServiceTestData.practitionerRoleEntriesMissingEndpointReference(),
        response: '{"resourceType":"Bundle"}'
      );
    });

    //when
    final (entries: entries, response: response) =
        await searchService.searchPractitionerRole(expectedQuery);

    // expect
    expect(entries, isEmpty);
    expect(response, equals('{"resourceType":"Bundle"}'));
  });

  test('searchPractitionerRole() Should not map results missing Endpoint reference value',
      () async {
    // given
    final expectedQuery = buildPRQuery();
    when(fhirRepository.search(ResourceType.PractitionerRole, expectedQuery)).thenAnswer((_) async {
      return (
        entries: FhirSearchServiceTestData.practitionerRoleEntriesMissingEndpointReferenceValue(),
        response: '{"resourceType":"Bundle"}'
      );
    });

    //when
    final (entries: entries, response: response) =
        await searchService.searchPractitionerRole(expectedQuery);

    // expect
    expect(entries, isEmpty);
    expect(response, equals('{"resourceType":"Bundle"}'));
  });

  test('searchPractitionerRole() should not include results missing matching Practitioner',
      () async {
    // given
    final expectedQuery = buildPRQuery();
    when(fhirRepository.search(ResourceType.PractitionerRole, expectedQuery)).thenAnswer((_) async {
      final ResourceSearchResult entries = (
        entries: FhirSearchServiceTestData.practitionerRoleCompleteEntries(),
        response: '{"resourceType":"Bundle"}'
      );
      entries.entries.addAll(
        FhirSearchServiceTestData.practitionerRoleEntriesWithoutPractitioner(),
      );
      return entries;
    });

    //when
    final (entries: entries, response: response) =
        await searchService.searchPractitionerRole(expectedQuery);

    // expect
    expect(entries.length, equals(1));
    expect(entries[0].practitionerName, equals('Dr FirstName LastName'));
    expect(entries[0].endpointAdresses![0], equals('@endpoint1:test.de'));
    expect(entries[0].endpointNames![0], equals('Tim Endpoint 1'));
    expect(entries[0].practitionerQualifications![0].code, equals('131723.123'));
    expect(
      entries[0].practitionerQualifications![0].display,
      equals('Test Qualification'),
    );
    expect(response, equals('{"resourceType":"Bundle"}'));
  });

  test('searchPractitionerRole() should not include results without endpoints', () async {
    // given
    final expectedQuery = buildPRQuery();
    when(fhirRepository.search(ResourceType.PractitionerRole, expectedQuery)).thenAnswer((_) async {
      final ResourceSearchResult entries = (
        entries: FhirSearchServiceTestData.practitionerRoleCompleteEntries(),
        response: '{"resourceType":"Bundle"}'
      );
      entries.entries.addAll(
        FhirSearchServiceTestData.practitionerRoleEntriesWithoutEndpoint(),
      );
      return entries;
    });

    //when
    final (entries: entries, response: response) =
        await searchService.searchPractitionerRole(expectedQuery);

    // expect
    expect(entries.length, equals(1));
    expect(entries[0].practitionerName, equals('Dr FirstName LastName'));
    expect(entries[0].endpointAdresses![0], equals('@endpoint1:test.de'));
    expect(entries[0].endpointNames!.length, equals(1));
    expect(entries[0].endpointNames![0], equals('Tim Endpoint 1'));
    expect(entries[0].endpointIds!.length, equals(1));
    expect(entries[0].endpointIds![0], equals('1'));
    expect(response, equals('{"resourceType":"Bundle"}'));
  });

  test('searchPractitionerRole() should correctly handle empty search response', () async {
    // given
    final expectedQuery = buildPRQuery();
    when(fhirRepository.search(ResourceType.PractitionerRole, expectedQuery)).thenAnswer((_) async {
      return (entries: <Entry>[], response: '{"resourceType":"Bundle"}');
    });

    //when
    final (entries: entries, response: response) =
        await searchService.searchPractitionerRole(expectedQuery);

    // expect
    expect(entries, isEmpty);
    expect(response, equals('{"resourceType":"Bundle"}'));
  });

  test(' searchHealthcareService() Should correctly map results for complete Dataset', () async {
    // given
    final expectedQuery = _buildHSQuery();
    when(fhirRepository.search(ResourceType.HealthcareService, expectedQuery))
        .thenAnswer((_) async {
      return (
        entries: FhirSearchServiceTestData.healthcareServiceCompleteEntries(),
        response: '{"resourceType":"Bundle"}'
      );
    });

    //when
    final (entries: entries, response: response) =
        await searchService.searchHealthcareService(expectedQuery);

    // expect
    expect(entries.length, equals(1));
    expect(entries[0].name, equals('healthcareService name'));
    expect(entries[0].organizationName, equals('Organization'));
    expect(entries[0].endpointIdList, equals(['id']));
    expect(entries[0].addressList, equals(['@Test:mockdata.com']));
    expect(entries[0].statusList, equals(['active']));
    expect(entries[0].managingOrganization, equals('id'));
    expect(
      entries[0].connectionTypeList.first.system,
      equals(Uri.parse('https://someSystem.com')),
    );
    expect(entries[0].connectionTypeList.first.version, equals('1'));
    expect(entries[0].connectionTypeList.first.code, equals('some code'));
    expect(entries[0].connectionTypeList.first.display, equals('some display'));
    expect(entries[0].payloadTypeList.length, equals(1));
    expect(entries[0].payloadTypeList.first.length, equals(1));
    expect(entries[0].payloadTypeList.first.first.coding!.length, equals(1));
    expect(
      entries[0].payloadTypeList.first.first.coding!.first.system,
      equals(Uri.parse('https://someSystem.com')),
    );
    expect(
      entries[0].payloadTypeList.first.first.coding!.first.version,
      equals('1'),
    );
    expect(
      entries[0].payloadTypeList.first.first.coding!.first.code,
      equals('some code'),
    );
    expect(
      entries[0].payloadTypeList.first.first.coding!.first.display,
      equals('some display'),
    );
    expect(response, equals('{"resourceType":"Bundle"}'));
  });

  test('searchHealthcareService() should correctly handle empty search response', () async {
    // given
    final expectedQuery = _buildHSQuery();
    when(fhirRepository.search(ResourceType.HealthcareService, expectedQuery))
        .thenAnswer((_) async {
      return (entries: <Entry>[], response: '{"resourceType":"Bundle"}');
    });

    //when
    final (entries: entries, response: response) =
        await searchService.searchHealthcareService(expectedQuery);

    // expect
    expect(entries, isEmpty);
    expect(response, equals('{"resourceType":"Bundle"}'));
  });
}

String buildPRQuery() => FhirQueryBuilder.buildPractitionerRoleQuery(
      {practitionerName: "FirstName"},
    );

String _buildHSQuery() => FhirQueryBuilder.buildHealthcareServiceQuery(
      {organizationName: "OrganizationName", address: "SomeAddress"},
    );
