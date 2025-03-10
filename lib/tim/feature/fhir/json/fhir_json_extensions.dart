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

/// JSON keys for FHIR Extensions.
class _Key {
  static const url = 'url';
  static const valueCoding = 'valueCoding';
  static const system = 'system';
  static const code = 'code';
}

/// JSON values for CodeSystem [EndpointVisibilityCS](https://gematik.de/fhir/directory/CodeSystem/EndpointVisibilityCS)
class EndpointVisibilityCS {
  static const system = 'https://gematik.de/fhir/directory/CodeSystem/EndpointVisibilityCS';
  static const code = 'hide-versicherte';
}

/// JSON values for the FHIR extension [EndpointVisibility](https://gematik.de/fhir/directory/StructureDefinition/EndpointVisibility).
class _EndpointVisibility {
  static const url = "https://gematik.de/fhir/directory/StructureDefinition/EndpointVisibility";

  /// Eintrag für Versicherte verbergen
  /// See [EndpointVisibilityCodeSystem](https://gematik.de/fhir/directory/CodeSystem/EndpointVisibilityCS)
  static const valueCoding = {
    _Key.system: EndpointVisibilityCS.system,
    _Key.code: EndpointVisibilityCS.code,
  };
}

/// Contains functions for FHIR extensions in JSON.
/// See [Extensibility](https://hl7.org/fhir/R4/extensibility.html).
class ExtensionsJson {
  static bool isHideEndpointExtension(dynamic extension) {
    return switch (extension) {
      {
        _Key.url: _EndpointVisibility.url,
        _Key.valueCoding: {
          _Key.system: EndpointVisibilityCS.system,
          _Key.code: EndpointVisibilityCS.code,
        },
      } =>
        true,
      _ => false,
    };
  }

  /// Copy and add extension "endpointVisibility: hide-versicherte".
  static Map<String, dynamic> copyAndAddHideEndpointExtension(Map<String, dynamic> resource) {
    if (resource['extension']?.any(isHideEndpointExtension) == true) return resource;

    final newExtensions =
        List<Map<String, dynamic>>.from(resource['extension'] ?? const Iterable.empty());
    newExtensions.add({
      _Key.url: _EndpointVisibility.url,
      _Key.valueCoding: _EndpointVisibility.valueCoding,
    });
    final newResource = {...resource};
    newResource['extension'] = newExtensions;
    return newResource;
  }

  /// Copy and remove extension "endpointVisibility: hide-versicherte".
  static Map<String, dynamic> copyAndRemoveHideEndpointExtension(Map<String, dynamic> resource) {
    if (resource['extension']?.any(isHideEndpointExtension) != true) return resource;

    final newExtensions = List<Map<String, dynamic>>.from(resource['extension']);
    newExtensions.removeWhere(isHideEndpointExtension);
    final newResource = {...resource};
    if (newExtensions.isNotEmpty) {
      newResource['extension'] = newExtensions;
    } else {
      newResource.remove('extension');
    }
    return newResource;
  }
}
