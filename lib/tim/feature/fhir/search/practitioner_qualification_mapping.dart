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

import '../../../../utils/l10n_value.dart';

/// mapping taken from https://simplifier.net/packages/de.gematik.fhir.directory/0.10.2/files/2140638
final Map<L10nValue, String> practitionerQualificationMapping = {
  L10nValue((_) => '', 0): '',
  L10nValue((t) => t.practitionerRoleDoctor, 1): '1.2.276.0.76.4.30',
  L10nValue((t) => t.practitionerRoleDentist, 2): '1.2.276.0.76.4.31',
  L10nValue((t) => t.practitionerRolePharmacist, 3): '1.2.276.0.76.4.32',
  L10nValue((t) => t.practitionerRolePharmacistAssistant, 4):
      '1.2.276.0.76.4.33',
  L10nValue((t) => t.practitionerRolePharmacyEngineer, 5): '1.2.276.0.76.4.34',
  L10nValue((t) => t.practitionerRolePharmaceuticalTechnicalAssistant, 6):
      '1.2.276.0.76.4.35',
  L10nValue((t) => t.practitionerRolePharmaceuticalCommercialEmployee, 7):
      '1.2.276.0.76.4.36',
  L10nValue((t) => t.practitionerRolePharmacyHelper, 8): '1.2.276.0.76.4.37',
  L10nValue((t) => t.practitionerRolePharmacyAssistant, 9): '1.2.276.0.76.4.38',
  L10nValue((t) => t.practitionerRolePharmaceuticalAssistant, 10):
      '1.2.276.0.76.4.39',
  L10nValue((t) => t.practitionerRolePharmacyTechnician, 11):
      '1.2.276.0.76.4.40',
  L10nValue((t) => t.practitionerRolePharmacyTrainee, 12): '1.2.276.0.76.4.41',
  L10nValue((t) => t.practitionerRoleStudentPharmacist, 13):
      '1.2.276.0.76.4.42',
  L10nValue((t) => t.practitionerRolePtaIntern, 14): '1.2.276.0.76.4.43',
  L10nValue((t) => t.practitionerRolePkaAzubi, 15): '1.2.276.0.76.4.44',
  L10nValue((t) => t.practitionerRolePsychotherapist, 16): '1.2.276.0.76.4.45',
  L10nValue((t) => t.practitionerRolePsychologicalPsychotherapist, 17):
      '1.2.276.0.76.4.46',
  L10nValue((t) => t.practitionerRoleChildAndAdolescentPsychotherapist, 18):
      '1.2.276.0.76.4.47',
  L10nValue((t) => t.practitionerRoleParamedic, 19): '1.2.276.0.76.4.48',
  L10nValue((t) => t.practitionerRoleInsuredPersons, 20): '1.2.276.0.76.4.49',
  L10nValue((t) => t.practitionerRoleEmergencyParamedic, 21):
      '1.2.276.0.76.4.178',
  L10nValue((t) => t.practitionerRoleNursingAssistant, 22):
      '1.2.276.0.76.4.232',
  L10nValue((t) => t.practitionerRoleElderlyNurse, 23): '1.2.276.0.76.4.233',
  L10nValue((t) => t.practitionerRoleNursingProfessionals, 24):
      '1.2.276.0.76.4.234',
  L10nValue((t) => t.practitionerRoleMidwife, 25): '1.2.276.0.76.4.235',
  L10nValue((t) => t.practitionerRolePhysio, 26): '1.2.276.0.76.4.236',
  L10nValue((t) => t.practitionerRoleOptician, 27): '1.2.276.0.76.4.237',
  L10nValue((t) => t.practitionerRoleHearingAcoustician, 28):
      '1.2.276.0.76.4.238',
  L10nValue((t) => t.practitionerRoleOrthopedicShoemaker, 29):
      '1.2.276.0.76.4.239',
  L10nValue((t) => t.practitionerRoleOrthopaedicTechnician, 30):
      '1.2.276.0.76.4.240',
  L10nValue((t) => t.practitionerRoleDentalTechnician, 31):
      '1.2.276.0.76.4.241',
  L10nValue((t) => t.practitionerRoleOccupationalTherapist, 32):
      '1.2.276.0.76.4.274',
  L10nValue((t) => t.practitionerRoleSpeechTherapist, 33): '1.2.276.0.76.4.275',
  L10nValue((t) => t.practitionerRolePodiatrist, 34): '1.2.276.0.76.4.276',
  L10nValue((t) => t.practitionerRoleNutritionalTherapist, 35):
      '1.2.276.0.76.4.277',
};
