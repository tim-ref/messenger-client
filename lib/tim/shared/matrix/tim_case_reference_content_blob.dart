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

/// Expected case reference content blob for testing
const timCaseReferenceContentBlob = {
  "resourceType": "EncounterCaseReference",
  "id": "324534708",
  "meta": {
    "profile": [
      "http://gematik.de/fhir/TIM/CaseReference/StructureDefinition/EncounterCaseReference"
    ]
  },
  "identifier": [
    {
      "system": "http://example.de/StructureDefinition/identifier-interne-abrechnungsnummer",
      "value": "ABC1234567890"
    }
  ],
  "status": "in-progress",
  "class": {"code": "AMB", "display": "ambulatory"},
  "priority": {
    "coding": [
      {"code": "A", "display": "ASAP"}
    ]
  },
  "subject": {
    "resourceType": "PatientCaseReference",
    "id": "374885372",
    "meta": {
      "profile": [
        "http://gematik.de/fhir/TIM/CaseReference/StructureDefinition/PatientCaseReference"
      ]
    },
    "identifier": [
      {"system": "http://fhir.de/StructureDefinition/identifier-kvid-10", "value": "ABC1234567"}
    ],
    "name": [
      {
        "given": ["August"],
        "family": "Fröhlich"
      }
    ],
    "gender": "male",
    "birthDate": "2000-02-21",
    "communication": [
      {
        "language": {
          "coding": [
            {"code": "de"}
          ]
        }
      }
    ]
  },
  "period": {"start": "2022-05-02"},
  "reasonCode": [
    {
      "coding": [
        {"code": "368009", "display": "Heart valve disorder"}
      ]
    }
  ],
  "reasonReference": [
    {
      "resourceType": "ConditionCaseReference",
      "id": "ConditionExample",
      "meta": {
        "profile": [
          "http://gematik.de/fhir/TIM/CaseReference/StructureDefinition/ConditionCaseReference"
        ]
      },
      "identifier": [
        {
          "system": "http://example.de/StructureDefinition/identifier-interne-abrechnungsnummer",
          "value": "ABC1234567890"
        }
      ],
      "clinicalStatus": {
        "coding": [
          {"code": "active"}
        ]
      },
      "verificationStatus": {
        "coding": [
          {"code": "provisional"}
        ]
      },
      "category": [
        {
          "coding": [
            {"code": "encounter-diagnosis"}
          ]
        }
      ],
      "severity": {
        "coding": [
          {"code": "24484000", "display": "Severe"}
        ]
      },
      "code": {
        "coding": [
          {"code": "368009", "display": "Heart valve disorder"}
        ]
      },
      "subject": {"reference": "374885372"},
      "encounter": {"reference": "324534708"},
      "recordedDate": "2022-05-02",
      "note": [
        {"text": "Additional information"}
      ]
    },
    {
      "resourceType": "ProcedureCaseReference",
      "id": "ProcedureExample",
      "meta": {
        "profile": [
          "http://gematik.de/fhir/TIM/CaseReference/StructureDefinition/ProcedureCaseReference"
        ]
      },
      "identifier": [
        {
          "system": "http://example.de/StructureDefinition/identifier-interne-abrechnungsnummer",
          "value": "ABC1234567890"
        }
      ],
      "status": "preparation",
      "subject": {"reference": "374885372"},
      "encounter": {"reference": "324534708"},
      "note": [
        {"text": "Additional information"}
      ]
    }
  ]
};
