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

const String address = 'location.address';
const String mxid = 'endpoint.address';
const String displayName = 'endpoint.name';
const String healthcareServiceName = 'name';
const String healthcareId = '_id';
const String organizationName = 'organization.name';
const String organizationType = 'organization.type';
const String organizationTelematikId = 'organization.identifier';
const String practitionerName = 'practitioner.name';
const String practitionerTelematikId = 'practitioner.identifier';
const String practitionerQualification = 'practitioner.qualification';

const String containsModifier = ':contains';

const List<String> practitionerRoleDefaultQueryParams = [
  'practitioner.active=true',
  '_include=PractitionerRole:practitioner',
  '_include=PractitionerRole:endpoint',
];

const List<String> healthcareServiceDefaultQueryParams = [
  'organization.active=true',
  '_include=HealthcareService:endpoint',
  '_include=HealthcareService:organization',
];

const List<String> defaultQueryParams = [
  '_format=json',
  'endpoint:Endpoint.connection-type=tim',
  'endpoint:Endpoint.status=active',
];
