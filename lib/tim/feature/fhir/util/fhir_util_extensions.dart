/*
 * TIM-Referenzumgebung
 * Copyright (C) 2025 - akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fhir/r4.dart';

/// JSON values for CodeSystem [EndpointVisibilityCS](https://gematik.de/fhir/directory/CodeSystem/EndpointVisibilityCS)
class EndpointVisibilityCS {
  static const system = 'https://gematik.de/fhir/directory/CodeSystem/EndpointVisibilityCS';
  static const code = 'hide-versicherte';
}

/// JSON values for the FHIR extension [EndpointVisibility](https://gematik.de/fhir/directory/StructureDefinition/EndpointVisibility).
class _EndpointVisibility {
  static const url = "https://gematik.de/fhir/directory/StructureDefinition/EndpointVisibility";
}

/// Contains functions for FHIR extensions in JSON.
/// See [Extensibility](https://hl7.org/fhir/R4/extensibility.html).
class ExtensionsJson {
  static bool isHideEndpointExtension(FhirExtension extension) =>
      extension.url == FhirUri(_EndpointVisibility.url) &&
      extension.valueCoding?.system == FhirUri(EndpointVisibilityCS.system) &&
      extension.valueCoding?.code == FhirCode(EndpointVisibilityCS.code);

  /// Copy and add extension "endpointVisibility: hide-versicherte".
  static FhirEndpoint copyAndAddHideEndpointExtension(FhirEndpoint resource) {
    if (resource.extension_?.any(isHideEndpointExtension) == true) return resource;

    final extension = FhirExtension(
      url: FhirUri(_EndpointVisibility.url),
      valueCoding: Coding(
        system: FhirUri(EndpointVisibilityCS.system),
        code: FhirCode(EndpointVisibilityCS.code),
      ),
    );

    return resource.copyWith(
      extension_: [
        ...?resource.extension_,
        extension,
      ],
    );
  }

  /// Copy and remove extension "endpointVisibility: hide-versicherte".
  static FhirEndpoint copyAndRemoveHideEndpointExtension(FhirEndpoint resource) {
    if (resource.extension_?.any(isHideEndpointExtension) != true) return resource;

    final filteredExtensions =
        resource.extension_?.where((extension) => !isHideEndpointExtension(extension)).toList();
    return resource.copyWith(
      extension_: filteredExtensions?.isNotEmpty == true ? filteredExtensions : null,
    );
  }
}
