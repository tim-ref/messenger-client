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

import 'package:matrix/matrix.dart';

import 'package:fluffychat/tim/feature/fhir/dto/codeable_concept.dart';
import 'package:fluffychat/tim/feature/fhir/dto/coding.dart';
import 'package:fluffychat/tim/feature/fhir/dto/create_endpoint.dart';
import 'package:fluffychat/tim/feature/fhir/dto/meta.dart';
import 'package:fluffychat/tim/feature/fhir/dto/resource_type.dart';

const fhirUrlMetaOrigin = 'https://gematik.de/fhir/directory/CodeSystem/Origin';
const fhirUrlProfile =
    'https://gematik.de/fhir/directory/StructureDefinition/EndpointDirectory';
const fhirUrlConnectionType =
    'https://gematik.de/fhir/directory/CodeSystem/EndpointDirectoryConnectionType';
const fhirUrlPayloadType =
    'https://gematik.de/fhir/directory/CodeSystem/EndpointDirectoryPayloadType';

class FhirDataHelper {
  final Map<dynamic, dynamic> queryResponse;
  late final Map<dynamic, dynamic>? oldPractitionerRole;
  late final Map<dynamic, dynamic>? oldTimEndpoint;

  FhirDataHelper(
    String mxid,
    this.queryResponse,
  ) {
    if (queryResponse['total'] > 0) {
      oldPractitionerRole = _getPractitionerRoleFromResponse();
      oldTimEndpoint = _getTimEndpointForMxid(mxid);
    }
  }

  bool get isFhirVisible => queryResponse['total'] > 0 && hasActiveTimEndpoint;

  bool get hasActiveTimEndpoint =>
      oldTimEndpoint != null && oldTimEndpoint?['status'] == 'active';

  bool validSearchResponseToSetVisibility() {
    return queryResponse['total'] > 0 &&
        queryResponse['entry']
                .map((entry) => entry['resource'])
                .where((resource) =>
                    resource['resourceType'] ==
                    ResourceType.PractitionerRole.name,)
                .length >
            0;
  }

  CreateEndpoint newEndpoint({required String mxid, required String name}) {
    return CreateEndpoint(
      resourceType: ResourceType.Endpoint,
      meta: Meta(
        tag: [
          Coding(
            system: Uri.parse(fhirUrlMetaOrigin),
            code: 'owner',
          ),
        ],
        profile: [
          fhirUrlProfile,
        ],
      ),
      status: 'active',
      address: mxid,
      name: name,
      connectionType: Coding(
        code: 'tim',
        system: Uri.parse(fhirUrlConnectionType),
      ),
      payloadType: [
        CodeableConcept(
          coding: [
            Coding(
              system: Uri.parse(fhirUrlPayloadType),
              code: 'tim-chat',
              display: 'TI-Messenger chat',
            ),
          ],
        ),
      ],
    );
  }

  Map<dynamic, dynamic> getUpdatedEndpoint() {
    if (oldTimEndpoint == null) {
      throw Exception('Cannot update Endpoint because old Endpoint is null');
    }
    final endpoint = {...oldTimEndpoint!};
    endpoint['status'] = 'active';
    return endpoint;
  }

  Map<dynamic, dynamic> getUpdatedPractitionerRole(
    bool visible,
    String endpointId,
  ) {
    if (oldPractitionerRole == null) {
      throw Exception(
          'Cannot update PractitionerRole because old PractitionerRole is null',);
    }
    final pr = {...oldPractitionerRole!};
    if (visible) {
      _addEndpointReference(pr, endpointId);
    } else {
      final endpointReferences = List.from(pr['endpoint'] as List);
      endpointReferences
          .removeWhere((element) => element['reference'].contains(endpointId));
      if (endpointReferences.isEmpty) {
        pr.removeWhere((key, value) => key == 'endpoint');
      } else {
        pr['endpoint'] = endpointReferences;
      }
    }
    return pr;
  }

  void _addEndpointReference(Map<dynamic, dynamic> pr, String endpointId) {
    final endpoints = pr['endpoint'] as List<dynamic>?;
    if (endpoints != null &&
        !_alreadyContainsEndpointReference(endpoints, endpointId)) {
      endpoints.add(
        {'reference': '${ResourceType.Endpoint.name}/$endpointId'},
      );
    } else if (endpoints == null) {
      pr.putIfAbsent(
        'endpoint',
        () => [
          {'reference': '${ResourceType.Endpoint.name}/$endpointId'},
        ],
      );
    }
  }

  Map<dynamic, dynamic> _getPractitionerRoleFromResponse() {
    try {
      return queryResponse['entry']
          .map((entry) => entry['resource'])
          .where((resource) =>
              resource['resourceType'] == ResourceType.PractitionerRole.name,)
          .first;
    } catch (e, s) {
      Logs().e('No PractitionerRole in Entries', e, s);
      rethrow;
    }
  }

  Map<dynamic, dynamic>? _getTimEndpointForMxid(String mxid) {
    try {
      final endpoints = queryResponse['entry']
          .map((entry) => entry['resource'])
          .where((resource) {
        return resource['resourceType'] == ResourceType.Endpoint.name &&
            resource['connectionType']['code'] == 'tim' &&
            resource['address'] == mxid;
      });
      return endpoints.isNotEmpty ? endpoints.first : null;
    } catch (ignored) {
      return null;
    }
  }

  bool _alreadyContainsEndpointReference(
      List<dynamic> endpointReferences, String endpointId,) {
    return endpointReferences
        .where((reference) => reference['reference'].contains(endpointId))
        .isNotEmpty;
  }
}
