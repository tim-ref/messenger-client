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

import 'package:fluffychat/tim/feature/fhir/dto/codeable_concept.dart';
import 'package:fluffychat/tim/feature/fhir/dto/coding.dart';
import 'package:fluffychat/tim/feature/fhir/dto/endpoint.dart';
import 'package:fluffychat/tim/feature/fhir/dto/entry.dart';
import 'package:fluffychat/tim/feature/fhir/dto/healthcare_service.dart';
import 'package:fluffychat/tim/feature/fhir/dto/human_name.dart';
import 'package:fluffychat/tim/feature/fhir/dto/organization.dart';
import 'package:fluffychat/tim/feature/fhir/dto/practitioner.dart';
import 'package:fluffychat/tim/feature/fhir/dto/practitioner_role.dart';
import 'package:fluffychat/tim/feature/fhir/dto/qualification.dart';
import 'package:fluffychat/tim/feature/fhir/dto/reference.dart';
import 'package:fluffychat/tim/feature/fhir/dto/resource_type.dart';

class FhirSearchServiceTestData {
  static List<Entry> practitionerRoleCompleteEntries() {
    return [
      Entry(
        resource: PractitionerRole(
          resourceType: ResourceType.PractitionerRole,
          id: '1',
          practitioner: Reference(reference: 'Practitioner/1'),
          endpoint: [
            Reference(reference: 'Endpoint/1'),
          ],
        ),
      ),
      Entry(
        resource: Practitioner(
          resourceType: ResourceType.Practitioner,
          id: '1',
          name: [
            HumanName(text: 'Dr FirstName LastName'),
          ],
          qualification: [
            Qualification(
              code: CodeableConcept(
                coding: [
                  Coding(
                    code: '131723.123',
                    display: 'Test Qualification',
                    system: Uri.tryParse('https://test_mock.de/coding/system'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Entry(
        resource: Endpoint(
          connectionType: Coding(
            system: Uri.parse('https://someSystem.com'),
            version: '1',
            code: 'some code',
            display: 'some display',
          ),
          resourceType: ResourceType.Endpoint,
          id: '1',
          name: "Tim Endpoint 1",
          address: '@endpoint1:test.de',
          status: 'active',
          payloadType: [
            CodeableConcept(
              coding: [
                Coding(
                  system: Uri.parse('https://someSystem.com'),
                  version: '1',
                  code: 'some code',
                  display: 'some display',
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  static List<Entry> practitionerRoleEntriesWithoutPractitioner() {
    return [
      Entry(
        resource: PractitionerRole(
          resourceType: ResourceType.PractitionerRole,
          id: '2',
          practitioner: Reference(reference: 'Practitioner/2'),
          endpoint: [
            Reference(reference: 'Endpoint/2'),
          ],
        ),
      ),
      Entry(
        resource: Endpoint(
          connectionType: Coding(
            system: Uri.parse('https://someSystem.com'),
            version: '1',
            code: 'some code',
            display: 'some display',
          ),
          resourceType: ResourceType.Endpoint,
          id: '2',
          name: "Tim Endpoint 2",
          address: '@endpoint2:test.de',
          status: 'active',
          payloadType: [
            CodeableConcept(
              coding: [
                Coding(
                  system: Uri.parse('https://someSystem.com'),
                  version: '1',
                  code: 'some code',
                  display: 'some display',
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  static List<Entry> practitionerRoleEntriesWithoutEndpoint() {
    return [
      Entry(
        resource: PractitionerRole(
          resourceType: ResourceType.PractitionerRole,
          id: '1',
          practitioner: Reference(reference: 'Practitioner/1'),
          endpoint: [
            Reference(reference: 'Endpoint/2'),
          ],
        ),
      ),
      Entry(
        resource: Practitioner(
            resourceType: ResourceType.Practitioner,
            id: '1',
            name: [
              HumanName(text: 'Dr FirstName LastName'),
            ],),
      ),
    ];
  }

  static List<Entry> practitionerRoleEntriesMissingPractitionerReference() {
    return [
      Entry(
        resource: PractitionerRole(
          resourceType: ResourceType.PractitionerRole,
          id: '1',
          endpoint: [
            Reference(reference: 'Endpoint/1'),
          ],
        ),
      ),
      Entry(
        resource: Practitioner(
            resourceType: ResourceType.Practitioner,
            id: '1',
            name: [
              HumanName(text: 'Dr FirstName LastName'),
            ],),
      ),
      Entry(
        resource: Endpoint(
          connectionType: Coding(
            system: Uri.parse('https://someSystem.com'),
            version: '1',
            code: 'some code',
            display: 'some display',
          ),
          resourceType: ResourceType.Endpoint,
          id: '1',
          name: "Tim Endpoint 1",
          address: '@endpoint1:test.de',
          status: 'active',
          payloadType: [
            CodeableConcept(
              coding: [
                Coding(
                  system: Uri.parse('https://someSystem.com'),
                  version: '1',
                  code: 'some code',
                  display: 'some display',
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  static List<Entry>
      practitionerRoleEntriesMissingPractitionerReferenceValue() {
    return [
      Entry(
        resource: PractitionerRole(
          resourceType: ResourceType.PractitionerRole,
          id: '1',
          practitioner: Reference(),
          endpoint: [
            Reference(reference: 'Endpoint/1'),
          ],
        ),
      ),
      Entry(
        resource: Practitioner(
            resourceType: ResourceType.Practitioner,
            id: '1',
            name: [
              HumanName(text: 'Dr FirstName LastName'),
            ],),
      ),
      Entry(
        resource: Endpoint(
          connectionType: Coding(
            system: Uri.parse('https://someSystem.com'),
            version: '1',
            code: 'some code',
            display: 'some display',
          ),
          resourceType: ResourceType.Endpoint,
          id: '1',
          name: "Tim Endpoint 1",
          address: '@endpoint1:test.de',
          status: 'active',
          payloadType: [
            CodeableConcept(
              coding: [
                Coding(
                  system: Uri.parse('https://someSystem.com'),
                  version: '1',
                  code: 'some code',
                  display: 'some display',
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  static List<Entry> practitionerRoleEntriesMissingEndpointReference() {
    return [
      Entry(
        resource: PractitionerRole(
          resourceType: ResourceType.PractitionerRole,
          id: '1',
          practitioner: Reference(reference: 'Practitioner/1'),
        ),
      ),
      Entry(
        resource: Practitioner(
            resourceType: ResourceType.Practitioner,
            id: '1',
            name: [
              HumanName(text: 'Dr FirstName LastName'),
            ],),
      ),
      Entry(
        resource: Endpoint(
          connectionType: Coding(
            system: Uri.parse('https://someSystem.com'),
            version: '1',
            code: 'some code',
            display: 'some display',
          ),
          resourceType: ResourceType.Endpoint,
          id: '1',
          name: "Tim Endpoint 1",
          address: '@endpoint1:test.de',
          status: 'active',
          payloadType: [
            CodeableConcept(
              coding: [
                Coding(
                  system: Uri.parse('https://someSystem.com'),
                  version: '1',
                  code: 'some code',
                  display: 'some display',
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  static List<Entry> practitionerRoleEntriesMissingEndpointReferenceValue() {
    return [
      Entry(
        resource: PractitionerRole(
          resourceType: ResourceType.PractitionerRole,
          id: '1',
          practitioner: Reference(reference: 'Practitioner/1'),
          endpoint: [
            Reference(),
          ],
        ),
      ),
      Entry(
        resource: Practitioner(
            resourceType: ResourceType.Practitioner,
            id: '1',
            name: [
              HumanName(text: 'Dr FirstName LastName'),
            ],),
      ),
      Entry(
        resource: Endpoint(
          connectionType: Coding(
            system: Uri.parse('https://someSystem.com'),
            version: '1',
            code: 'some code',
            display: 'some display',
          ),
          resourceType: ResourceType.Endpoint,
          id: '1',
          name: "Tim Endpoint 1",
          address: '@endpoint1:test.de',
          status: 'active',
          payloadType: [
            CodeableConcept(
              coding: [
                Coding(
                  system: Uri.parse('https://someSystem.com'),
                  version: '1',
                  code: 'some code',
                  display: 'some display',
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  static List<Entry> healthcareServiceCompleteEntries() {
    return [
      Entry(
        resource: HealthcareService(
          resourceType: ResourceType.HealthcareService,
          id: 'id',
          providedBy: Reference(reference: 'Organization/id'),
          name: 'healthcareService name',
          location: [
            Reference(reference: 'Location/id'),
          ],
          endpoint: [
            Reference(reference: 'Endpoint/id'),
          ],
        ),
      ),
      Entry(
        resource: Organization(
          resourceType: ResourceType.Organization,
          id: 'id',
          name: 'Organization',
        ),
      ),
      Entry(
        resource: Endpoint(
          resourceType: ResourceType.Endpoint,
          id: 'id',
          connectionType: Coding(
            system: Uri.parse('https://someSystem.com'),
            version: '1',
            code: 'some code',
            display: 'some display',
          ),
          status: 'active',
          address: '@Test:mockdata.com',
          name: 'Matrix id of Test',
          payloadType: [
            CodeableConcept(
              coding: [
                Coding(
                  system: Uri.parse('https://someSystem.com'),
                  version: '1',
                  code: 'some code',
                  display: 'some display',
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }
}
