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
import 'dart:io';

import 'package:fluffychat/tim/feature/fhir/dto/bundle.dart';
import 'package:fluffychat/tim/feature/fhir/dto/resource_type.dart';
import 'package:fluffychat/tim/feature/fhir/fhir_config.dart';
import 'package:fluffychat/tim/feature/fhir/fhir_query_builder.dart';
import 'package:fluffychat/tim/feature/fhir/fhir_repository.dart';
import 'package:fluffychat/tim/feature/fhir/search/fhir_search_constants.dart';
import 'package:fluffychat/tim/shared/tim_auth_repository.dart';
import 'package:fluffychat/tim/shared/tim_auth_token.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../contact_approval/contact_approval_repository_test.mocks.dart';

@GenerateMocks([http.Client, TimAuthRepository])
void main() {
  late final MockClient httpClient;
  late final MockTimAuthRepository tokenRepo;
  late final FhirRepository fhirRepository;
  late final FhirConfig config;

  setUpAll(() {
    httpClient = MockClient();
    tokenRepo = MockTimAuthRepository();
    config = FhirConfig(
      host: 'https://host',
      searchBase: '/fhir',
      authBase: '/tim-authenticate',
      ownerBase: '/owner',
    );
    when(tokenRepo.getFhirToken())
        .thenAnswer((_) async => defaultOpenIdToken());
    fhirRepository = FhirRepository(httpClient, tokenRepo, config);
  });

  test('Should correctly deserialize the search result', () async {
    // given
    final mockDataFile = File('test_resources/titus_guzman_fhir.json');
    final mockDataString = await mockDataFile.readAsString();
    final query = FhirQueryBuilder.buildPractitionerRoleQuery(
        {practitionerName: 'Guzman, Titus'},);
    final uriString = 'https://host/fhir/PractitionerRole?$query';
    final expectedUri = Uri.parse(uriString);
    final expectedBundle = Bundle.fromJson(jsonDecode(mockDataString));

    when(
      httpClient.get(
        expectedUri,
        headers: expectedHeaders(),
      ),
    ).thenAnswer(
      (_) async => http.Response(
        mockDataString,
        200,
      ),
    );

    // when
    final actualEntries =
        await fhirRepository.search(ResourceType.PractitionerRole, query);

    // expect
    expect(actualEntries, equals(expectedBundle.entry));
  });

  test('Should correctly deserialize the search result for HealthcareService',
      () async {
    // given
    final mockDataFile =
        File('test_resources/healthcare_service_test_org_123.json');
    final mockDataString = await mockDataFile.readAsString();
    final query = FhirQueryBuilder.buildHealthcareServiceQuery(
        {organizationName: 'Test Organization 123'},);
    final uriString = 'https://host/fhir/HealthcareService?$query';
    final expectedUri = Uri.parse(uriString);
    final expectedBundle = Bundle.fromJson(jsonDecode(mockDataString));

    when(
      httpClient.get(
        expectedUri,
        headers: expectedHeaders(),
      ),
    ).thenAnswer(
      (_) async => http.Response(
        mockDataString,
        200,
      ),
    );

    // when
    final actualEntries =
        await fhirRepository.search(ResourceType.HealthcareService, query);

    // expect
    expect(actualEntries, equals(expectedBundle.entry));
  });

  test('Should correctly call all pages of a paginated search', () async {
    // given
    final allTitusesPage1String =
        await File('test_resources/all_tituses_fhir_page_1.json')
            .readAsString();
    final allTitusesPage2String =
        await File('test_resources/all_tituses_fhir_page_2.json')
            .readAsString();
    final allTitusesPage3String =
        await File('test_resources/all_tituses_fhir_page_3.json')
            .readAsString();

    final query = FhirQueryBuilder.buildPractitionerRoleQuery(
        {practitionerName: 'Titus'},);
    final uriString = 'https://host/fhir/PractitionerRole?$query';
    final expectedUri = Uri.parse(uriString);

    when(httpClient.get(expectedUri, headers: expectedHeaders()))
        .thenAnswer((_) async => http.Response(allTitusesPage1String, 200));
    final expectedPage1 = Bundle.fromJson(jsonDecode(allTitusesPage1String));

    when(httpClient.get(
      Uri.parse(
          'http://localhost:8080/fhir?_getpages=08a678eb-fdc0-4f4d-ac60-d7d8cf3ced90&_getpagesoffset=20&_count=20&_format=json&_pretty=true&_include=PractitionerRole%3Aendpoint&_include=PractitionerRole%3Apractitioner&_bundletype=searchset',),
      headers: expectedHeaders(),
    ),).thenAnswer((_) async => http.Response(allTitusesPage2String, 200));
    final expectedPage2 = Bundle.fromJson(jsonDecode(allTitusesPage2String));

    when(httpClient.get(
      Uri.parse(
          'http://localhost:8080/fhir?_getpages=08a678eb-fdc0-4f4d-ac60-d7d8cf3ced90&_getpagesoffset=40&_count=20&_format=json&_pretty=true&_include=PractitionerRole%3Aendpoint&_include=PractitionerRole%3Apractitioner&_bundletype=searchset',),
      headers: expectedHeaders(),
    ),).thenAnswer((_) async => http.Response(allTitusesPage3String, 200));
    final expectedPage3 = Bundle.fromJson(jsonDecode(allTitusesPage3String));

    final expectedEntries = [expectedPage1, expectedPage2, expectedPage3]
        .expand((bundle) => bundle.entry != null ? bundle.entry! : []);

    // when
    final actualEntries =
        await fhirRepository.search(ResourceType.PractitionerRole, query);

    // expect
    expect(actualEntries, equals(expectedEntries));
  });

  test('Should correctly get FHIR visibility', () async {
    // given
    final expectedQuery = FhirQueryBuilder.findOwnerByMxidAndTelematikId(
        '@test:foo.bar', '1-550-test.foo-bar',);
    final uriString = 'https://host/owner/PractitionerRole?$expectedQuery';
    final responseBodyString =
        await File('test_resources/owner_search_with_endpoint.json')
            .readAsString();

    when(httpClient.get(Uri.parse(uriString), headers: expectedHeaders()))
        .thenAnswer((_) async => http.Response(responseBodyString, 200));

    // when
    final searchResult =
        await fhirRepository.ownerSearch(expectedQuery, defaultOpenIdToken());

    // then
    expect(searchResult, equals(jsonDecode(responseBodyString)));
  });
}

Map<String, String> expectedHeaders() {
  return <String, String>{
    HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    'authorization': 'Bearer ${defaultOpenIdToken().accessToken}',
  };
}

TimAuthToken defaultOpenIdToken() {
  return TimAuthToken(
    accessToken: 'accessToken',
    tokenType: 'bearer',
    expiresIn: 3600,
  );
}
