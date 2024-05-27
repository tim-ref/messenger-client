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

import 'package:fluffychat/tim/feature/fhir/dto/coding.dart';
import 'package:fluffychat/tim/feature/fhir/dto/endpoint.dart';
import 'package:fluffychat/tim/feature/fhir/dto/endpoint_reference.dart';
import 'package:fluffychat/tim/feature/fhir/dto/entry.dart';
import 'package:fluffychat/tim/feature/fhir/dto/healthcare_service.dart';
import 'package:fluffychat/tim/feature/fhir/dto/organization.dart';
import 'package:fluffychat/tim/feature/fhir/dto/practitioner.dart';
import 'package:fluffychat/tim/feature/fhir/dto/practitioner_role.dart';
import 'package:fluffychat/tim/feature/fhir/dto/reference.dart';
import 'package:fluffychat/tim/feature/fhir/dto/resource_type.dart';
import 'package:fluffychat/tim/feature/fhir/fhir_repository.dart';
import 'package:fluffychat/tim/feature/fhir/search/healthcare_service_search_result.dart';
import 'package:fluffychat/tim/feature/fhir/search/practitioner_search_result.dart';

import 'fhir_search_result.dart';

/// A List of practitioners and the JSON-formatted String from which they were parsed
typedef PractitionerSearchResultSet = ({List<PractitionerSearchResult> entries, String response});

/// A List of healthcare services and the JSON-formatted String from which they were parsed
typedef HealthcareServiceSearchResultSet = ({
  List<HealthcareServiceSearchResult> entries,
  String response
});

/// A List of FHIR search result items and the JSON-formatted String from which they were parsed
typedef FhirSearchResultSet = ({List<FhirSearchResult> entries, String response});

class FhirSearchService {
  final FhirRepository _repository;

  FhirSearchService(this._repository);

  Future<PractitionerSearchResultSet> searchPractitionerRole(String query) async {
    final (entries: entries, response: fullResult) =
        await _repository.search(ResourceType.PractitionerRole, query);

    if (entries == null || entries.isEmpty) {
      return (entries: <PractitionerSearchResult>[], response: fullResult);
    }

    final practitionerRoles = _getPractitionerRoles(entries);
    final practitioners = _getPractitioners(entries);
    final endpoints = _getEndpoints(entries);

    return (
      entries: practitionerRoles
          .where((pr) => _hasMatchingPractitioner(pr, practitioners))
          .where((pr) => _hasMatchingEndpoints(pr, endpoints))
          .map((PractitionerRole pr) =>
              mapPractitionerRoleToSearchResult(pr, practitioners, endpoints))
          .toList(),
      response: fullResult
    );
  }

  Future<HealthcareServiceSearchResultSet> searchHealthcareService(
    String query,
  ) async {
    final (entries: entries, response: fullResponse) = await _repository.search(
      ResourceType.HealthcareService,
      query,
    );

    if (entries == null || entries.isEmpty) {
      return (entries: <HealthcareServiceSearchResult>[], response: fullResponse);
    }

    final healthcareServices = _getHealthcareServices(entries);
    final organizations = _getOrganizations(entries);
    final endpoints = _getEndpoints(entries);

    return (
      entries: healthcareServices
          .where((hs) => _hasMatchingOrganization(hs, organizations))
          .where((hs) => _hasMatchingEndpoints(hs, endpoints))
          .map(
            (HealthcareService hs) =>
                _mapHealthcareServiceToSearchResult(hs, organizations, endpoints),
          )
          .toList(),
      response: fullResponse
    );
  }

  List<PractitionerRole> _getPractitionerRoles(List<Entry> entries) {
    return entries
        .where(
          (entry) => _matchesResourceType(entry, ResourceType.PractitionerRole),
        )
        .map((entry) => entry.resource as PractitionerRole)
        .toList()
        .where((pr) => pr.endpoint != null && pr.endpoint!.isNotEmpty)
        .where(_hasValidPractitionerReference)
        .where(_hasValidEndpointReferences)
        .toList();
  }

  List<HealthcareService> _getHealthcareServices(List<Entry> entries) {
    return entries
        .where((entry) => _matchesResourceType(entry, ResourceType.HealthcareService))
        .map((entry) => entry.resource as HealthcareService)
        .toList()
        .where((pr) => pr.endpoint != null && pr.endpoint!.isNotEmpty)
        .where(_hasValidOrganizationReference)
        .where(_hasValidEndpointReferences)
        .toList();
  }

  List<Practitioner> _getPractitioners(List<Entry> entries) {
    return entries
        .where((entry) => _matchesResourceType(entry, ResourceType.Practitioner))
        .map((entry) => entry.resource as Practitioner)
        .toList();
  }

  List<Organization> _getOrganizations(List<Entry> entries) {
    return entries
        .where((entry) => _matchesResourceType(entry, ResourceType.Organization))
        .map((entry) => entry.resource as Organization)
        .toList();
  }

  List<Endpoint> _getEndpoints(List<Entry> entries) {
    return entries
        .where((entry) => _matchesResourceType(entry, ResourceType.Endpoint))
        .map((entry) => entry.resource as Endpoint)
        .toList();
  }

  bool _matchesResourceType(entry, ResourceType resourceType) =>
      entry.resource.resourceType == resourceType;

  bool _hasValidPractitionerReference(PractitionerRole practitionerRole) {
    return practitionerRole.practitioner?.reference != null;
  }

  bool _hasValidEndpointReferences(EndpointReference resource) {
    return resource.endpoint != null &&
        resource.endpoint!.where((e) => e.reference != null).isNotEmpty;
  }

  bool _hasValidOrganizationReference(HealthcareService healthcareService) {
    return healthcareService.providedBy.reference != null &&
        healthcareService.providedBy.reference!.isNotEmpty;
  }

  String _getResourceIdFromReference(Reference reference) {
    return reference.reference!.split('/')[1];
  }

  bool _hasMatchingPractitioner(PractitionerRole pr, List<Practitioner> practitioners) {
    final practitionerId = _getResourceIdFromReference(pr.practitioner!);
    return practitioners.map((p) => p.id).contains(practitionerId);
  }

  bool _hasMatchingOrganization(HealthcareService hs, List<Organization> organizations) {
    final organizationId = _getResourceIdFromReference(hs.providedBy);
    return organizations.map((o) => o.id).contains(organizationId);
  }

  bool _hasMatchingEndpoints(EndpointReference endpointReference, List<Endpoint> endpoints) {
    final endpointIds = endpointReference.endpoint!.map((e) => _getResourceIdFromReference(e));
    return endpoints.where((e) => endpointIds.contains(e.id)).isNotEmpty;
  }

  PractitionerSearchResult mapPractitionerRoleToSearchResult(
    PractitionerRole pr,
    List<Practitioner> practitioners,
    List<Endpoint> endpoints,
  ) {
    final practitionerId = _getResourceIdFromReference(pr.practitioner!);
    final endpointIds = pr.endpoint!.map((e) => _getResourceIdFromReference(e));

    final practitioner = practitioners.where((element) => element.id == practitionerId).first;
    final practitionerEndpoints =
        endpoints.where((element) => endpointIds.contains(element.id)).toList();

    final List<Coding> codings = [];
    practitioner.qualification?.forEach((element) {
      if (element.code.coding != null) {
        codings.addAll(element.code.coding!);
      }
    });

    return PractitionerSearchResult(
      endpointNames: practitionerEndpoints
          .where((element) => element.name != null)
          .map((e) => e.name!)
          .toList(),
      endpointAdresses: practitionerEndpoints.map((e) => e.address).toList(),
      endpointIds: practitionerEndpoints.map((e) => e.id).toList(),
      practitionerName: practitioner.name?.first.text,
      practitionerQualifications: codings,
    );
  }

  HealthcareServiceSearchResult _mapHealthcareServiceToSearchResult(
    HealthcareService hs,
    List<Organization> organizations,
    List<Endpoint> endpoints,
  ) {
    final organizationId = _getResourceIdFromReference(hs.providedBy);
    final endpointIds = hs.endpoint!.map((e) => _getResourceIdFromReference(e));

    final organization = organizations.where((element) => element.id == organizationId).first;
    final healthcareServiceEndpoints =
        endpoints.where((element) => endpointIds.contains(element.id)).toList();

    return HealthcareServiceSearchResult(
      id: hs.id,
      name: hs.name,
      organizationName: organization.name,
      nameList: healthcareServiceEndpoints.map((e) => e.name ?? "").toList(),
      managingOrganization: organizationId,
      addressList: healthcareServiceEndpoints.map((e) => e.address).toList(),
      endpointIdList: healthcareServiceEndpoints.map((e) => e.id).toList(),
      payloadTypeList: healthcareServiceEndpoints.map((e) => e.payloadType).toList(),
      connectionTypeList: healthcareServiceEndpoints.map((e) => e.connectionType).toList(),
      statusList: healthcareServiceEndpoints.map((e) => e.status).toList(),
    );
  }
}
