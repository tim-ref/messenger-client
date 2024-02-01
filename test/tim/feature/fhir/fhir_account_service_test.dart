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

import 'package:fluffychat/tim/feature/fhir/dto/codeable_concept.dart';
import 'package:fluffychat/tim/feature/fhir/dto/coding.dart';
import 'package:fluffychat/tim/feature/fhir/dto/create_endpoint.dart';
import 'package:fluffychat/tim/feature/fhir/dto/endpoint.dart';
import 'package:fluffychat/tim/feature/fhir/dto/meta.dart';
import 'package:fluffychat/tim/feature/fhir/dto/resource_type.dart';
import 'package:fluffychat/tim/feature/fhir/fhir_repository.dart';
import 'package:fluffychat/tim/feature/fhir/settings/fhir_account_service.dart';
import 'package:fluffychat/tim/shared/tim_auth_repository.dart';
import 'package:fluffychat/tim/shared/tim_auth_state.dart';
import 'package:fluffychat/tim/shared/tim_auth_token.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'fhir_account_service_test.mocks.dart';

@GenerateMocks([TimAuthRepository, FhirRepository, TimAuthState])
void main() {
  late MockTimAuthRepository authRepository;
  late MockFhirRepository fhirRepository;
  late MockTimAuthState timAuthState;

  setUp(() {
    authRepository = MockTimAuthRepository();
    fhirRepository = MockFhirRepository();
    timAuthState = MockTimAuthState();

    when(authRepository.getHbaToken()).thenAnswer((_) async => _mockToken());
  });

  test('Should correctly handle empty fhir visibility search result', () async {
    // given
    final service =
        FhirAccountService(authRepository, fhirRepository, timAuthState);
    final emptySearchResultFile =
        File('test_resources/owner_search_empty.json');
    final emptySearchResultString = await emptySearchResultFile.readAsString();
    final emptySearchResult = jsonDecode(emptySearchResultString);
    final token = _mockToken();
    final expectedQuery =
        '_format=json&practitioner.active=true&practitioner.identifier=1-5-30000-TelematikId&endpoint.address=${Uri.encodeComponent('@test:newPractitionerRole.bar')}&_include=PractitionerRole:endpoint';
    when(fhirRepository.ownerSearch(expectedQuery, token))
        .thenAnswer((_) async {
      return emptySearchResult;
    });

    // when
    final visible =
        await service.getFhirVisibility(token, '@test:newPractitionerRole.bar');

    // then
    expectLater(visible, equals(false));
  });

  test(
      'Should should return correct visibility for PractitionerRole without Endpoint',
      () async {
    // given
    final service =
        FhirAccountService(authRepository, fhirRepository, timAuthState);
    final ownerSearchResultFile =
        File('test_resources/owner_search_without_endpoint.json');
    final ownerSearchResultString = await ownerSearchResultFile.readAsString();
    final ownerSearchResult = jsonDecode(ownerSearchResultString);
    final token = _mockToken();
    final expectedQuery =
        '_format=json&practitioner.active=true&practitioner.identifier=1-5-30000-TelematikId&endpoint.address=${Uri.encodeComponent('@test:newPractitionerRole.bar')}&_include=PractitionerRole:endpoint';
    when(fhirRepository.ownerSearch(expectedQuery, token))
        .thenAnswer((_) async {
      return ownerSearchResult;
    });

    // when
    final visible =
        await service.getFhirVisibility(token, '@test:newPractitionerRole.bar');

    // then
    expectLater(visible, equals(false));
  });

  test(
      'Should should return correct visibility for PractitionerRole with inactive Endpoint',
      () async {
    // given
    final service =
        FhirAccountService(authRepository, fhirRepository, timAuthState);
    final ownerSearchResultFile =
        File('test_resources/owner_search_with_inactive_endpoint.json');
    final ownerSearchResultString = await ownerSearchResultFile.readAsString();
    final ownerWithoutEndpoint = jsonDecode(ownerSearchResultString);
    final token = _mockToken();
    final expectedQuery =
        '_format=json&practitioner.active=true&practitioner.identifier=1-5-30000-TelematikId&endpoint.address=${Uri.encodeComponent('@test:newPractitionerRole.bar')}&_include=PractitionerRole:endpoint';
    when(fhirRepository.ownerSearch(expectedQuery, token))
        .thenAnswer((_) async {
      return ownerWithoutEndpoint;
    });

    // when
    final visible =
        await service.getFhirVisibility(token, '@test:newPractitionerRole.bar');

    // then
    expectLater(visible, equals(false));
  });

  test('Should should return correct visibility on rest error', () async {
    // given
    final service =
        FhirAccountService(authRepository, fhirRepository, timAuthState);
    final token = _mockToken();
    final expectedQuery =
        '_format=json&practitioner.active=true&practitioner.identifier=1-5-30000-TelematikId&endpoint.address=${Uri.encodeComponent('@test:newPractitionerRole.bar')}&_include=PractitionerRole:endpoint';
    when(fhirRepository.ownerSearch(expectedQuery, token))
        .thenThrow(const HttpException('error'));

    // expect
    expectLater(
      service.getFhirVisibility(token, '@test:newPractitionerRole.bar'),
      throwsA(isA<HttpException>()),
    );
  });

  test('Should correctly handle empty search result when setting visibility',
      () async {
    // given
    final service =
        FhirAccountService(authRepository, fhirRepository, timAuthState);
    final emptySearchResultFile =
        File('test_resources/owner_search_empty.json');
    final emptySearchResultString = await emptySearchResultFile.readAsString();
    final emptySearchResult = jsonDecode(emptySearchResultString);
    final token = _mockToken();
    final expectedQuery =
        '_format=json&practitioner.active=true&practitioner.identifier=${Uri.encodeComponent('1-5-30000-TelematikId')}&_include=PractitionerRole:endpoint';
    when(fhirRepository.ownerSearch(expectedQuery, token))
        .thenAnswer((_) async {
      return emptySearchResult;
    });

    // when
    service.setFhirVisibility(
      true,
      '@test:newPractitionerRole.bar',
      'endpointName',
      token,
    );

    // then
    verifyNever(
      fhirRepository.createResource(ResourceType.Endpoint, token, any),
    );
    verifyNever(
      fhirRepository.updateResource(ResourceType.Endpoint, any, token, any),
    );
    verifyNever(
      fhirRepository.updateResource(
        ResourceType.PractitionerRole,
        any,
        token,
        any,
      ),
    );
  });

  test(
      'Should add new Endpoint for PractitionerRole without pre existing endpoints when making user Fhir-visible',
      () async {
    // given
    final service =
        FhirAccountService(authRepository, fhirRepository, timAuthState);
    final oldPractitionerRoleFile =
        File('test_resources/owner_search_without_endpoint.json');
    final oldPractitionerRoleString =
        await oldPractitionerRoleFile.readAsString();
    final oldPractitionerRole = jsonDecode(oldPractitionerRoleString);

    final newPractitionerRoleFile = File(
      'test_resources/updated_practitioner_role_with_added_endpoint.json',
    );
    final newPractitionerRoleString =
        await newPractitionerRoleFile.readAsString();
    final newPractitionerRole =
        jsonEncode(jsonDecode(newPractitionerRoleString));

    final token = _mockToken();
    final expectedQuery =
        '_format=json&practitioner.active=true&practitioner.identifier=${Uri.encodeComponent('1-5-30000-TelematikId')}&_include=PractitionerRole:endpoint';
    final newEndpointMap =
        _createEndpoint('@test:newPractitionerRole.bar', 'endpointName')
            .toJson();
    when(fhirRepository.ownerSearch(expectedQuery, token))
        .thenAnswer((_) async => oldPractitionerRole);
    when(
      fhirRepository.createResource(
        ResourceType.Endpoint,
        token,
        jsonEncode(newEndpointMap),
      ),
    ).thenAnswer(
      (_) async => Endpoint(
        resourceType: ResourceType.Endpoint,
        id: 'endpointId',
        status: 'active',
        address: '@test:newPractitionerRole.bar',
        connectionType: Coding(),
        payloadType: [
          CodeableConcept(),
        ],
      ).toJson(),
    );
    when(
      fhirRepository.updateResource(
        ResourceType.PractitionerRole,
        'practitionerRoleId',
        token,
        newPractitionerRole,
      ),
    ).thenAnswer((_) async => {});

    // when
    service.setFhirVisibility(
      true,
      '@test:newPractitionerRole.bar',
      'endpointName',
      token,
    );

    // then
    // implicitly verified through stubs
    verifyNever(
      fhirRepository.deleteResource(
        ResourceType.Endpoint,
        'endpointId',
        token,
      ),
    );
  });

  test(
      'Should update Endpoint for PractitionerRole with inactive Endpoint when making user Fhir-visible',
      () async {
    // given
    final service =
        FhirAccountService(authRepository, fhirRepository, timAuthState);
    final ownerSearchResultFile =
        File('test_resources/owner_search_with_inactive_endpoint.json');
    final ownerSearchResultString = await ownerSearchResultFile.readAsString();
    final ownerSearchResult = jsonDecode(ownerSearchResultString);
    final endpoint = ownerSearchResult['entry']
        .map((entry) => entry['resource'])
        .where((resource) {
      return resource['resourceType'] == ResourceType.Endpoint.name &&
          resource['connectionType']['code'] == 'tim' &&
          resource['address'] == '@test:newPractitionerRole.bar';
    }).first;
    final token = _mockToken();
    final expectedQuery =
        '_format=json&practitioner.active=true&practitioner.identifier=${Uri.encodeComponent('1-5-30000-TelematikId')}&_include=PractitionerRole:endpoint';

    endpoint['status'] = 'active';
    when(fhirRepository.ownerSearch(expectedQuery, token))
        .thenAnswer((_) async => ownerSearchResult);
    when(
      fhirRepository.updateResource(
        ResourceType.Endpoint,
        endpoint['id'],
        token,
        jsonEncode(endpoint),
      ),
    ).thenAnswer((_) async => {});

    // when
    service.setFhirVisibility(
      true,
      '@test:newPractitionerRole.bar',
      'endpointName',
      token,
    );

    // then
    // implicitly verified through stubs
    verifyNever(
      fhirRepository.updateResource(
        ResourceType.PractitionerRole,
        'practitionerRoleId',
        token,
        any,
      ),
    );
    verifyNever(
      fhirRepository.deleteResource(
        ResourceType.Endpoint,
        'endpointId',
        token,
      ),
    );
  });

  test(
      'Should remove Endpoint for PractitionerRole with pre existing endpoints when making user Fhir-invisible',
      () async {
    // given
    final service =
        FhirAccountService(authRepository, fhirRepository, timAuthState);
    final oldPractitionerRoleFile =
        File('test_resources/owner_search_with_endpoint.json');
    final oldPractitionerRoleString =
        await oldPractitionerRoleFile.readAsString();
    final oldPractitionerRole = jsonDecode(oldPractitionerRoleString);

    final newPractitionerRoleFile = File(
      'test_resources/updated_practitioner_role_with_removed_endpoint.json',
    );
    final newPractitionerRoleString =
        await newPractitionerRoleFile.readAsString();
    final newPractitionerRole =
        jsonEncode(jsonDecode(newPractitionerRoleString));

    final token = _mockToken();
    final expectedQuery =
        '_format=json&practitioner.active=true&practitioner.identifier=${Uri.encodeComponent('1-5-30000-TelematikId')}&_include=PractitionerRole:endpoint';
    when(fhirRepository.ownerSearch(expectedQuery, token))
        .thenAnswer((_) async => oldPractitionerRole);
    when(
      fhirRepository.deleteResource(
        ResourceType.Endpoint,
        'endpointId',
        token,
      ),
    ).thenAnswer((_) async => {});
    when(
      fhirRepository.updateResource(
        ResourceType.PractitionerRole,
        'practitionerRoleId',
        token,
        newPractitionerRole,
      ),
    ).thenAnswer((_) async => {});

    // when
    service.setFhirVisibility(
      false,
      '@test:newPractitionerRole.bar',
      'endpointName',
      token,
    );

    // then
    // implicitly verified through stubs
  });

  test('Should not update PractitionerRole if creating the Endpoint fails',
      () async {
    // given
    final service =
        FhirAccountService(authRepository, fhirRepository, timAuthState);
    final oldPractitionerRoleFile =
        File('test_resources/owner_search_without_endpoint.json');
    final oldPractitionerRoleString =
        await oldPractitionerRoleFile.readAsString();
    final oldPractitionerRole = jsonDecode(oldPractitionerRoleString);
    final token = _mockToken();
    final expectedQuery =
        '_format=json&practitioner.active=true&practitioner.identifier=${Uri.encodeComponent('1-5-30000-TelematikId')}&_include=PractitionerRole:endpoint';

    when(fhirRepository.ownerSearch(expectedQuery, token))
        .thenAnswer((_) async => oldPractitionerRole);
    when(fhirRepository.createResource(ResourceType.Endpoint, token, any))
        .thenThrow(const HttpException('error'));

    // expect
    // implicitly verified through stubs
    expectLater(
      service.setFhirVisibility(
        true,
        '@test:newPractitionerRole.bar',
        'endpointName',
        token,
      ),
      throwsException,
    );
    verifyNever(
      fhirRepository.deleteResource(
        ResourceType.Endpoint,
        'endpointId',
        token,
      ),
    );

    verifyNever(
      fhirRepository.updateResource(
        ResourceType.PractitionerRole,
        'practitionerRoleId',
        token,
        any,
      ),
    );
  });

  test('Should not delete Endpoint if PractitionerRole update fails', () async {
    // given
    final service =
        FhirAccountService(authRepository, fhirRepository, timAuthState);
    final ownerSearchResultFile =
        File('test_resources/owner_search_with_endpoint.json');
    final ownerSearchResultString = await ownerSearchResultFile.readAsString();
    final Map<String, dynamic> ownerSearchResult =
        jsonDecode(ownerSearchResultString);
    final token = _mockToken();
    final expectedQuery =
        '_format=json&practitioner.active=true&practitioner.identifier=${Uri.encodeComponent('1-5-30000-TelematikId')}&_include=PractitionerRole:endpoint';

    final Map<dynamic, dynamic> practitionerRole = ownerSearchResult['entry']
        .map((entry) => entry['resource'])
        .where(
          (resource) =>
              resource['resourceType'] == ResourceType.PractitionerRole.name,
        )
        .first;
    final cp = {...practitionerRole};
    cp.removeWhere((key, value) => key == 'endpoint');

    when(fhirRepository.ownerSearch(expectedQuery, token))
        .thenAnswer((_) async => ownerSearchResult);
    when(
      fhirRepository.updateResource(
        ResourceType.PractitionerRole,
        'practitionerRoleId',
        token,
        jsonEncode(cp),
      ),
    ).thenThrow(const HttpException('error'));

    // expect
    // implicitly verified through stubs
    expectLater(
      service.setFhirVisibility(
        false,
        '@test:newPractitionerRole.bar',
        'endpointName',
        token,
      ),
      throwsException,
    );

    verifyNever(
      fhirRepository.deleteResource(
        ResourceType.Endpoint,
        'endpointId',
        token,
      ),
    );
  });

  test('Should revert PractitionerRole if delete Endpoint fails', () async {
    // given
    final service =
        FhirAccountService(authRepository, fhirRepository, timAuthState);
    final ownerSearchResultFile =
        File('test_resources/owner_search_with_endpoint.json');
    final ownerSearchResultString = await ownerSearchResultFile.readAsString();
    final ownerSearchResult = jsonDecode(ownerSearchResultString);
    final token = _mockToken();
    final expectedQuery =
        '_format=json&practitioner.active=true&practitioner.identifier=${Uri.encodeComponent('1-5-30000-TelematikId')}&_include=PractitionerRole:endpoint';

    final Map<dynamic, dynamic> oldPractitionerRole = ownerSearchResult['entry']
        .map((entry) => entry['resource'])
        .where(
          (resource) =>
              resource['resourceType'] == ResourceType.PractitionerRole.name,
        )
        .first;

    final newPractitionerRole = {...oldPractitionerRole};
    newPractitionerRole.removeWhere((key, value) => key == 'endpoint');

    when(fhirRepository.ownerSearch(expectedQuery, token))
        .thenAnswer((_) async => ownerSearchResult);
    when(
      fhirRepository.updateResource(
        ResourceType.PractitionerRole,
        'practitionerRoleId',
        token,
        jsonEncode(newPractitionerRole),
      ),
    ).thenAnswer((text) async => {});
    when(
      fhirRepository.deleteResource(
        ResourceType.Endpoint,
        'endpointId',
        token,
      ),
    ).thenThrow(const HttpException('error'));
    when(
      fhirRepository.updateResource(
        ResourceType.PractitionerRole,
        'practitionerRoleId',
        token,
        jsonEncode(oldPractitionerRole),
      ),
    ).thenAnswer((text) async => {});

    // when
    expectLater(
      service.setFhirVisibility(
        false,
        '@test:newPractitionerRole.bar',
        'endpointName',
        token,
      ),
      throwsException,
    );

    // expect
    // implicitly verified through stubs
  });
}

CreateEndpoint _createEndpoint(String mxid, String name) {
  return CreateEndpoint(
    resourceType: ResourceType.Endpoint,
    meta: Meta(
      tag: [
        Coding(
          system:
              Uri.parse('https://gematik.de/fhir/directory/CodeSystem/Origin'),
          code: 'owner',
        ),
      ],
      profile: [
        "https://gematik.de/fhir/directory/StructureDefinition/EndpointDirectory",
      ],
    ),
    status: 'active',
    address: mxid,
    name: name,
    connectionType: Coding(
      code: 'tim',
      system: Uri.parse(
        'https://gematik.de/fhir/directory/CodeSystem/EndpointDirectoryConnectionType',
      ),
    ),
    payloadType: [
      CodeableConcept(
        coding: [
          Coding(
            system: Uri.parse(
              'https://gematik.de/fhir/directory/CodeSystem/EndpointDirectoryPayloadType',
            ),
            code: 'tim-chat',
            display: 'TI-Messenger chat',
          ),
        ],
      ),
    ],
  );
}

TimAuthToken _mockToken() {
  return TimAuthToken(
    accessToken:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxLTUtMzAwMDAtVGVsZW1hdGlrSWQiLCJuYW1lIjoiSm9obiBEb2UiLCJpYXQiOjE1MTYyMzkwMjJ9.Ya2MCS0RNr7UW3qTApjcPU5ObikbbndMtmf3-V63dG4',
    tokenType: 'jwt',
    expiresIn: 1338490,
  );
}
