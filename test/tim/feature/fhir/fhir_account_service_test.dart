/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - 2025 – akquinet GmbH
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
import 'package:fluffychat/tim/feature/fhir/settings/fhir_practitioner_visibility.dart';
import 'package:fluffychat/tim/shared/tim_auth_repository.dart';
import 'package:fluffychat/tim/shared/tim_auth_state.dart';
import 'package:fluffychat/tim/shared/tim_auth_token.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<TimAuthRepository>(),
  MockSpec<FhirRepository>(),
  MockSpec<TimAuthState>(),
])
import 'fhir_account_service_test.mocks.dart';

void main() {
  late MockTimAuthRepository stubAuthRepository;
  late MockFhirRepository mockFhirRepository;
  late MockTimAuthState stubTimAuthState;
  late FhirAccountService service;

  setUp(() {
    stubAuthRepository = MockTimAuthRepository();
    mockFhirRepository = MockFhirRepository();
    stubTimAuthState = MockTimAuthState();
    service = FhirAccountService(stubAuthRepository, mockFhirRepository, stubTimAuthState);

    when(stubAuthRepository.getHbaToken()).thenAnswer((_) async => _mockToken());
  });

  group('Get Practitioner visibility', () {
    test('Should correctly handle empty fhir visibility search result', () async {
      // given
      final emptySearchResult = await _loadJsonFile('test_resources/owner_search_empty.json');
      final token = _mockToken();
      final expectedQuery =
          '_format=json&practitioner.active=true&practitioner.identifier=1-5-30000-TelematikId&endpoint.address=${Uri.encodeComponent('@test:newPractitionerRole.bar')}&_include=PractitionerRole:endpoint';
      when(mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token))
          .thenAnswer((_) async => emptySearchResult);

      // when
      final visible = await service.fetchPractitionerVisibility(
        token,
        '@test:newPractitionerRole.bar',
      );

      // then
      expect(
        visible,
        isA<PractitionerVisibility>()
            .having((e) => e.isGenerallyVisible, 'isGenerallyVisible', isFalse)
            .having((e) => e.isVisibleExceptFromInsurees, 'isVisibleExceptFromInsurees', isNull),
      );
    });

    test('Should return correct visibility for PractitionerRole without Endpoint', () async {
      // given
      final ownerSearchResult =
          await _loadJsonFile('test_resources/owner_search_without_endpoint.json');
      final token = _mockToken();
      final expectedQuery =
          '_format=json&practitioner.active=true&practitioner.identifier=1-5-30000-TelematikId&endpoint.address=${Uri.encodeComponent('@test:newPractitionerRole.bar')}&_include=PractitionerRole:endpoint';
      when(mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token))
          .thenAnswer((_) async => ownerSearchResult);

      // when
      final visible = await service.fetchPractitionerVisibility(
        token,
        '@test:newPractitionerRole.bar',
      );

      // then
      expect(
        visible,
        isA<PractitionerVisibility>()
            .having((e) => e.isGenerallyVisible, 'isGenerallyVisible', isFalse)
            .having((e) => e.isVisibleExceptFromInsurees, 'isVisibleExceptFromInsurees', isNull),
      );
    });

    test('Should return correct visibility for PractitionerRole with inactive Endpoint', () async {
      // given
      final ownerWithoutEndpoint =
          await _loadJsonFile('test_resources/owner_search_with_inactive_endpoint.json');
      final token = _mockToken();
      final expectedQuery =
          '_format=json&practitioner.active=true&practitioner.identifier=1-5-30000-TelematikId&endpoint.address=${Uri.encodeComponent('@test:newPractitionerRole.bar')}&_include=PractitionerRole:endpoint';
      when(mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token))
          .thenAnswer((_) async => ownerWithoutEndpoint);

      // when
      final visible = await service.fetchPractitionerVisibility(
        token,
        '@test:newPractitionerRole.bar',
      );

      // then
      expect(
        visible,
        isA<PractitionerVisibility>()
            .having((e) => e.isGenerallyVisible, 'isGenerallyVisible', isFalse)
            .having((e) => e.isVisibleExceptFromInsurees, 'isVisibleExceptFromInsurees', isNull),
      );
    });

    test('Should return correct visibility for PractitionerRole with active Endpoint', () async {
      // given
      final ownerWithoutEndpoint =
          await _loadJsonFile('test_resources/owner_search_with_active_endpoint.json');
      final token = _mockToken();
      final expectedQuery =
          '_format=json&practitioner.active=true&practitioner.identifier=1-5-30000-TelematikId&endpoint.address=${Uri.encodeComponent('@test:newPractitionerRole.bar')}&_include=PractitionerRole:endpoint';
      when(mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token))
          .thenAnswer((_) async => ownerWithoutEndpoint);

      // when
      final visible = await service.fetchPractitionerVisibility(
        token,
        '@test:newPractitionerRole.bar',
      );

      // then
      expect(
        visible,
        isA<PractitionerVisibility>()
            .having((e) => e.isGenerallyVisible, 'isGenerallyVisible', isTrue)
            .having((e) => e.isVisibleExceptFromInsurees, 'isVisibleExceptFromInsurees', isFalse),
      );
    });

    test('Should return correct visibility for PractitionerRole with active hidden Endpoint',
        () async {
      // given
      final ownerWithoutEndpoint =
          await _loadJsonFile('test_resources/owner_search_with_active_hidden_endpoint.fhir.json');
      final token = _mockToken();
      final expectedQuery =
          '_format=json&practitioner.active=true&practitioner.identifier=1-5-30000-TelematikId&endpoint.address=${Uri.encodeComponent('@test:newPractitionerRole.bar')}&_include=PractitionerRole:endpoint';
      when(mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token))
          .thenAnswer((_) async => ownerWithoutEndpoint);

      // when
      final visible = await service.fetchPractitionerVisibility(
        token,
        '@test:newPractitionerRole.bar',
      );

      // then
      expect(
        visible,
        isA<PractitionerVisibility>()
            .having((e) => e.isGenerallyVisible, 'isGenerallyVisible', isTrue)
            .having((e) => e.isVisibleExceptFromInsurees, 'isVisibleExceptFromInsurees', isTrue),
      );
    });

    test('Should throw Exception on REST error', () async {
      // given
      final token = _mockToken();
      when(mockFhirRepository.searchPractitionerRoleAsOwner(any, any))
          .thenThrow(const HttpException('error'));

      // expect
      await expectLater(
        service.fetchPractitionerVisibility(token, '@test:newPractitionerRole.bar'),
        throwsA(isA<HttpException>()),
      );
    });
  });

  group('Set Practitioner visibility', () {
    test('Should correctly handle empty search result when setting visibility', () async {
      // given
      final emptySearchResult = await _loadJsonFile('test_resources/owner_search_empty.json');
      final token = _mockToken();
      final expectedQuery =
          '_format=json&practitioner.active=true&practitioner.identifier=${Uri.encodeComponent(
        '1-5-30000-TelematikId',
      )}&_include=PractitionerRole:endpoint';
      when(mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token))
          .thenAnswer((_) async => emptySearchResult);

      // when
      final newVisibility = await service.setUsersVisibility(
        isVisible: true,
        owningPractitionersMxid: '@test:newPractitionerRole.bar',
        endpointName: 'endpointName',
        token: token,
      );

      // then
      expect(newVisibility, isFalse);

      verify(mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token));
      verifyNoMoreInteractions(mockFhirRepository);
    });

    test(
        'Should add new Endpoint for PractitionerRole without pre-existing endpoints when making user Fhir-visible',
        () async {
      // given
      final oldPractitionerRole =
          await _loadJsonFile('test_resources/owner_search_without_endpoint.json');

      final newPractitionerRole = jsonEncode(
        await _loadJsonFile('test_resources/updated_practitioner_role_with_added_endpoint.json'),
      );

      final token = _mockToken();
      final expectedQuery =
          '_format=json&practitioner.active=true&practitioner.identifier=${Uri.encodeComponent(
        '1-5-30000-TelematikId',
      )}&_include=PractitionerRole:endpoint';
      final newEndpointMap =
          _createEndpoint('@test:newPractitionerRole.bar', 'endpointName').toJson();
      when(mockFhirRepository.searchPractitionerRoleAsOwner(any, any))
          .thenAnswer((_) async => oldPractitionerRole);
      when(mockFhirRepository.createResource(any, any, any)).thenAnswer(
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

      // when
      final newVisibility = await service.setUsersVisibility(
        isVisible: true,
        owningPractitionersMxid: '@test:newPractitionerRole.bar',
        endpointName: 'endpointName',
        token: token,
      );

      // then
      expect(newVisibility, isTrue);

      verifyInOrder([
        mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token),
        mockFhirRepository.createResource(
          ResourceType.Endpoint,
          token,
          jsonEncode(newEndpointMap),
        ),
        mockFhirRepository.updateResource(
          ResourceType.PractitionerRole,
          'practitionerRoleId',
          token,
          newPractitionerRole,
        ),
      ]);
      verifyNoMoreInteractions(mockFhirRepository);
    });

    test(
        'Should update Endpoint for PractitionerRole with inactive Endpoint when making user Fhir-visible',
        () async {
      // given
      final ownerSearchResult = await _loadJsonFile(
        'test_resources/owner_search_with_inactive_endpoint.json',
      );
      final endpoint =
          ownerSearchResult['entry'].map((entry) => entry['resource']).where((resource) {
        return resource['resourceType'] == ResourceType.Endpoint.name &&
            resource['connectionType']['code'] == 'tim' &&
            resource['address'] == '@test:newPractitionerRole.bar';
      }).first;
      final token = _mockToken();
      final expectedQuery =
          '_format=json&practitioner.active=true&practitioner.identifier=${Uri.encodeComponent(
        '1-5-30000-TelematikId',
      )}&_include=PractitionerRole:endpoint';

      endpoint['status'] = 'active';
      when(mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token))
          .thenAnswer((_) async => ownerSearchResult);

      // when
      final newVisibility = await service.setUsersVisibility(
        isVisible: true,
        owningPractitionersMxid: '@test:newPractitionerRole.bar',
        endpointName: 'endpointName',
        token: token,
      );

      // then
      expect(newVisibility, isTrue);

      verifyInOrder([
        mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token),
        mockFhirRepository.updateResource(
          ResourceType.Endpoint,
          'endpointId',
          token,
          jsonEncode(endpoint),
        ),
      ]);
      verifyNoMoreInteractions(mockFhirRepository);
    });

    test(
        'Should remove Endpoint for PractitionerRole with pre existing endpoints when making user Fhir-invisible',
        () async {
      // given
      final oldPractitionerRole =
          await _loadJsonFile('test_resources/owner_search_with_endpoint.json');

      final newPractitionerRole = jsonEncode(
        await _loadJsonFile(
          'test_resources/updated_practitioner_role_with_removed_endpoint.json',
        ),
      );

      final token = _mockToken();
      final expectedQuery =
          '_format=json&practitioner.active=true&practitioner.identifier=${Uri.encodeComponent(
        '1-5-30000-TelematikId',
      )}&_include=PractitionerRole:endpoint';
      when(mockFhirRepository.searchPractitionerRoleAsOwner(any, any))
          .thenAnswer((_) async => oldPractitionerRole);

      // when
      final newVisibility = await service.setUsersVisibility(
        isVisible: false,
        owningPractitionersMxid: '@test:newPractitionerRole.bar',
        endpointName: 'endpointName',
        token: token,
      );

      // then
      expect(newVisibility, isFalse);

      verifyInOrder([
        mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token),
        mockFhirRepository.updateResource(
          ResourceType.PractitionerRole,
          'practitionerRoleId',
          token,
          newPractitionerRole,
        ),
        mockFhirRepository.deleteResource(ResourceType.Endpoint, 'endpointId', token),
      ]);
      verifyNoMoreInteractions(mockFhirRepository);
    });

    test('Should not update PractitionerRole if creating the Endpoint fails', () async {
      // given
      final oldPractitionerRole =
          await _loadJsonFile('test_resources/owner_search_without_endpoint.json');
      final token = _mockToken();
      final expectedQuery =
          '_format=json&practitioner.active=true&practitioner.identifier=${Uri.encodeComponent(
        '1-5-30000-TelematikId',
      )}&_include=PractitionerRole:endpoint';

      when(mockFhirRepository.searchPractitionerRoleAsOwner(any, any))
          .thenAnswer((_) async => oldPractitionerRole);
      when(mockFhirRepository.createResource(any, any, any))
          .thenThrow(const HttpException('error'));

      // expect
      await expectLater(
        service.setUsersVisibility(
          isVisible: true,
          owningPractitionersMxid: '@test:newPractitionerRole.bar',
          endpointName: 'endpointName',
          token: token,
        ),
        throwsException,
      );

      verifyInOrder([
        mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token),
        mockFhirRepository.createResource(ResourceType.Endpoint, token, any),
      ]);
      verifyNoMoreInteractions(mockFhirRepository);
    });

    test('Should not delete Endpoint if PractitionerRole update fails', () async {
      // given
      final Map<String, dynamic> ownerSearchResult =
          await _loadJsonFile('test_resources/owner_search_with_endpoint.json');
      final token = _mockToken();
      final expectedQuery =
          '_format=json&practitioner.active=true&practitioner.identifier=${Uri.encodeComponent(
        '1-5-30000-TelematikId',
      )}&_include=PractitionerRole:endpoint';

      final Map<dynamic, dynamic> practitionerRole = ownerSearchResult['entry']
          .map((entry) => entry['resource'])
          .where(
            (resource) => resource['resourceType'] == ResourceType.PractitionerRole.name,
          )
          .first;
      final cp = {...practitionerRole};
      cp.removeWhere((key, value) => key == 'endpoint');

      when(mockFhirRepository.searchPractitionerRoleAsOwner(any, any))
          .thenAnswer((_) async => ownerSearchResult);
      when(mockFhirRepository.updateResource(any, any, any, any))
          .thenThrow(const HttpException('error'));

      // expect
      // implicitly verified through stubs
      await expectLater(
        service.setUsersVisibility(
          isVisible: false,
          owningPractitionersMxid: '@test:newPractitionerRole.bar',
          endpointName: 'endpointName',
          token: token,
        ),
        throwsException,
      );

      verifyInOrder([
        mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token),
        mockFhirRepository.updateResource(
          ResourceType.PractitionerRole,
          'practitionerRoleId',
          token,
          jsonEncode(cp),
        ),
      ]);

      verifyNoMoreInteractions(mockFhirRepository);
    });

    test('Should revert PractitionerRole if delete Endpoint fails', () async {
      // given
      final ownerSearchResult =
          await _loadJsonFile('test_resources/owner_search_with_endpoint.json');
      final token = _mockToken();
      final expectedQuery =
          '_format=json&practitioner.active=true&practitioner.identifier=${Uri.encodeComponent(
        '1-5-30000-TelematikId',
      )}&_include=PractitionerRole:endpoint';

      final Map<dynamic, dynamic> oldPractitionerRole = ownerSearchResult['entry']
          .map((entry) => entry['resource'])
          .where(
            (resource) => resource['resourceType'] == ResourceType.PractitionerRole.name,
          )
          .first;

      final newPractitionerRole = {...oldPractitionerRole};
      newPractitionerRole.removeWhere((key, value) => key == 'endpoint');

      when(mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token))
          .thenAnswer((_) async => ownerSearchResult);
      when(mockFhirRepository.deleteResource(any, any, any))
          .thenThrow(const HttpException('error'));

      // when
      await expectLater(
        service.setUsersVisibility(
          isVisible: false,
          owningPractitionersMxid: '@test:newPractitionerRole.bar',
          endpointName: 'endpointName',
          token: token,
        ),
        throwsException,
      );

      // expect
      verifyInOrder([
        mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token),
        mockFhirRepository.updateResource(
          ResourceType.PractitionerRole,
          'practitionerRoleId',
          token,
          jsonEncode(newPractitionerRole),
        ),
        mockFhirRepository.deleteResource(ResourceType.Endpoint, 'endpointId', token),
        mockFhirRepository.updateResource(
          ResourceType.PractitionerRole,
          'practitionerRoleId',
          token,
          jsonEncode(oldPractitionerRole),
        ),
      ]);
      verifyNoMoreInteractions(mockFhirRepository);
    });
  });

  group('Set Practitioner visibility towards insurees', () {
    test('Can add visibility extension to active TIM Endpoint of Practitioner', () async {
      // given
      final searchResultBundle =
          await _loadJsonFile('test_resources/owner_search_with_active_endpoint.json');
      final activeHiddenTimEndpoint =
          await _loadJsonFile('test_resources/active_hidden_tim_endpoint.fhir.json');
      final token = _mockToken();
      final expectedQuery =
          '_format=json&practitioner.active=true&practitioner.identifier=${Uri.encodeComponent(
        '1-5-30000-TelematikId',
      )}&_include=PractitionerRole:endpoint';
      when(mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token))
          .thenAnswer((_) async => searchResultBundle);

      // when
      final newVisibility = await service.setUsersVisibilityTowardsInsurees(
        shouldBeVisible: false,
        owningPractitionersMxid: '@test:newPractitionerRole.bar',
        endpointName: 'endpointName',
        token: token,
      );

      // then
      expect(newVisibility, isFalse);

      final [_, u] = verifyInOrder([
        mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token),
        mockFhirRepository.updateResource(ResourceType.Endpoint, 'endpointId', token, captureAny),
      ]);
      verifyNoMoreInteractions(mockFhirRepository);

      final actualEndpoint = u.captured.single;
      expect(
        actualEndpoint,
        contains('https://gematik.de/fhir/directory/StructureDefinition/EndpointVisibility'),
      );
      expect(actualEndpoint, equals(jsonEncode(activeHiddenTimEndpoint)));
    });

    test('Can remove visibility extension from active TIM Endpoint of Practitioner', () async {
      // given
      final searchResultBundle =
          await _loadJsonFile('test_resources/owner_search_with_active_hidden_endpoint.fhir.json');
      final activeTimEndpoint = await _loadJsonFile('test_resources/active_tim_endpoint.fhir.json');
      final token = _mockToken();
      final expectedQuery =
          '_format=json&practitioner.active=true&practitioner.identifier=${Uri.encodeComponent(
        '1-5-30000-TelematikId',
      )}&_include=PractitionerRole:endpoint';
      when(mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token))
          .thenAnswer((_) async => searchResultBundle);

      // when
      final newVisibility = await service.setUsersVisibilityTowardsInsurees(
        shouldBeVisible: true,
        owningPractitionersMxid: '@test:newPractitionerRole.bar',
        endpointName: 'endpointName',
        token: token,
      );

      // then
      expect(newVisibility, isTrue);

      final [_, u] = verifyInOrder([
        mockFhirRepository.searchPractitionerRoleAsOwner(expectedQuery, token),
        mockFhirRepository.updateResource(ResourceType.Endpoint, 'endpointId', token, captureAny),
      ]);
      verifyNoMoreInteractions(mockFhirRepository);

      final actualEndpoint = u.captured.single;
      expect(
        actualEndpoint,
        isNot(
          contains('https://gematik.de/fhir/directory/StructureDefinition/EndpointVisibility'),
        ),
      );
      expect(actualEndpoint, equals(jsonEncode(activeTimEndpoint)));
    });
  });
}

CreateEndpoint _createEndpoint(String mxid, String name) {
  return CreateEndpoint(
    resourceType: ResourceType.Endpoint,
    meta: Meta(
      tag: [
        Coding(
          system: Uri.parse('https://gematik.de/fhir/directory/CodeSystem/Origin'),
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

dynamic _loadJsonFile(String path) async {
  final file = File(path);
  final string = await file.readAsString();
  return jsonDecode(string);
}
