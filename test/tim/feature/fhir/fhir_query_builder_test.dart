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

import 'package:fluffychat/tim/feature/fhir/fhir_query_builder.dart';
import 'package:fluffychat/tim/feature/fhir/search/fhir_search_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final String defaultPractitionerRoleParams;
  late final String defaultHealthcareServiceParams;

  setUpAll(() {
    defaultPractitionerRoleParams =
        '${defaultQueryParams.join('&')}&${practitionerRoleDefaultQueryParams.join('&')}';
    defaultHealthcareServiceParams =
        '${defaultQueryParams.join('&')}&${healthcareServiceDefaultQueryParams.join('&')}';
  });

  test('Should build the correct PractitionerRole query for Name', () {
    // given
    const enteredName = "FirstName LastName";
    final expectedQuery =
        '$defaultPractitionerRoleParams&$practitionerName$containsModifier=${Uri.encodeComponent(enteredName)}';

    //expect
    expect(
      FhirQueryBuilder.buildPractitionerRoleQuery(
          {practitionerName: enteredName},),
      equals(expectedQuery),
    );
  });

  test('Should build the correct PractitionerRole query for Address', () {
    // given
    const enteredAddress = "SomeStreet SomeCity";
    final expectedQuery =
        '$defaultPractitionerRoleParams&$address$containsModifier=${Uri.encodeComponent(enteredAddress)}';

    //expect
    expect(
      FhirQueryBuilder.buildPractitionerRoleQuery({address: enteredAddress}),
      equals(expectedQuery),
    );
  });

  test('Should build the correct PractitionerRole query for Telematik ID', () {
    const enteredTelematikId = "123567%%SomeID";
    final expectedQuery =
        '$defaultPractitionerRoleParams&$practitionerTelematikId$containsModifier=${Uri.encodeComponent(enteredTelematikId)}';

    //expect
    expect(
      FhirQueryBuilder.buildPractitionerRoleQuery(
          {practitionerTelematikId: enteredTelematikId},),
      equals(expectedQuery),
    );
  });

  test('Should build the correct PractitionerRole query for Mxid', () {
    const enteredMxid = "@Localpart:home.de";
    final expectedQuery =
        '$defaultPractitionerRoleParams&$mxid$containsModifier=${Uri.encodeComponent(enteredMxid)}';

    //expect
    expect(
      FhirQueryBuilder.buildPractitionerRoleQuery({mxid: enteredMxid}),
      equals(expectedQuery),
    );
  });

  test('Should build the correct PractitionerRole query for Qualification', () {
    const enteredQualification = "Some Qualification the user has";
    final expectedQuery =
        '$defaultPractitionerRoleParams&$practitionerQualification$containsModifier=${Uri.encodeComponent(enteredQualification)}';

    //expect
    expect(
      FhirQueryBuilder.buildPractitionerRoleQuery(
          {practitionerQualification: enteredQualification},),
      equals(expectedQuery),
    );
  });

  test(
      'Should build the correct PractitionerRole query for all possible Params combined',
      () {
    const enteredName = "FirstName LastName";
    const enteredAddress = "SomeStreet SomeCity";
    const enteredTelematikId = "123567%%SomeID";
    const enteredMxid = "@Localpart:home.de";
    const enteredQualification = "Some Qualification the user has";
    final expectedQuery =
        '$defaultPractitionerRoleParams&$practitionerName$containsModifier=${Uri.encodeComponent(enteredName)}&$address$containsModifier=${Uri.encodeComponent(enteredAddress)}&$practitionerTelematikId$containsModifier=${Uri.encodeComponent(enteredTelematikId)}&$mxid$containsModifier=${Uri.encodeComponent(enteredMxid)}&$practitionerQualification$containsModifier=${Uri.encodeComponent(enteredQualification)}';

    //expect
    expect(
      FhirQueryBuilder.buildPractitionerRoleQuery({
        practitionerName: enteredName,
        address: enteredAddress,
        practitionerTelematikId: enteredTelematikId,
        mxid: enteredMxid,
        practitionerQualification: enteredQualification,
      }),
      equals(expectedQuery),
    );
  });

  test('Should build the correct HealthcareService query for Name', () {
    // given
    const enteredName = "Healthcare Service Name";
    final expectedQuery =
        '$defaultHealthcareServiceParams&$healthcareServiceName$containsModifier=${Uri.encodeComponent(enteredName)}';

    //expect
    expect(
      FhirQueryBuilder.buildHealthcareServiceQuery(
          {healthcareServiceName: enteredName},),
      equals(expectedQuery),
    );
  });

  test('Should build the correct HealthcareService query for Organization Name',
      () {
    // given
    const enteredName = "Organization Name";
    final expectedQuery =
        '$defaultHealthcareServiceParams&$organizationName$containsModifier=${Uri.encodeComponent(enteredName)}';

    //expect
    expect(
      FhirQueryBuilder.buildHealthcareServiceQuery(
          {organizationName: enteredName},),
      equals(expectedQuery),
    );
  });

  test('Should build the correct HealthcareService query for Address', () {
    // given
    const enteredAddress = "SomeStreet SomeCity";
    final expectedQuery =
        '$defaultHealthcareServiceParams&$address$containsModifier=${Uri.encodeComponent(enteredAddress)}';

    //expect
    expect(
      FhirQueryBuilder.buildHealthcareServiceQuery({address: enteredAddress}),
      equals(expectedQuery),
    );
  });

  test('Should build the correct HealthcareService query for Telematik ID', () {
    // given
    const enteredTelematikId = "123567%%SomeID";

    final expectedQuery =
        '$defaultHealthcareServiceParams&$organizationTelematikId$containsModifier=${Uri.encodeComponent(enteredTelematikId)}';

    //expect
    expect(
      FhirQueryBuilder.buildHealthcareServiceQuery(
          {organizationTelematikId: enteredTelematikId},),
      equals(expectedQuery),
    );
  });

  test('Should build the correct HealthcareService query for Organization Type',
      () {
    // given
    const enteredOrganizationType = "Some organization Type";

    final expectedQuery =
        '$defaultHealthcareServiceParams&$organizationType$containsModifier=${Uri.encodeComponent(enteredOrganizationType)}';

    //expect
    expect(
      FhirQueryBuilder.buildHealthcareServiceQuery(
          {organizationType: enteredOrganizationType},),
      equals(expectedQuery),
    );
  });
  test(
      'Should build the correct HealthcareService query for all possible Params combined',
      () {
    const enteredName = "FirstName LastName";
    const enteredOrganizationName = "Organization Name";
    const enteredAddress = "SomeStreet SomeCity";
    const enteredTelematikId = "123567%%SomeID";
    const enteredOrganizationType = "Some organization Type";
    final expectedQuery =
        '$defaultHealthcareServiceParams&$healthcareServiceName$containsModifier=${Uri.encodeComponent(enteredName)}&$organizationName$containsModifier=${Uri.encodeComponent(enteredOrganizationName)}&$address$containsModifier=${Uri.encodeComponent(enteredAddress)}&$organizationTelematikId$containsModifier=${Uri.encodeComponent(enteredTelematikId)}&$organizationType$containsModifier=${Uri.encodeComponent(enteredOrganizationType)}';

    //expect
    expect(
      FhirQueryBuilder.buildHealthcareServiceQuery({
        healthcareServiceName: enteredName,
        organizationName: enteredOrganizationName,
        address: enteredAddress,
        organizationTelematikId: enteredTelematikId,
        organizationType: enteredOrganizationType,
      }),
      equals(expectedQuery),
    );
  });
}
