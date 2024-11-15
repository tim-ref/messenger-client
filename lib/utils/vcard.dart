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

import 'package:collection/collection.dart';

// AFO 5.4.12 2D-Barcode erstellen und anzeigen
// https://gemspec.gematik.de/docs/gemSpec/gemSpec_TI-Messenger-Client/latest/#5.4.12

// accept vcard version 4.0 only, cause it's the only version with IMPP property
const vCardBegin = r'BEGIN:VCARD';
const vCardEnd = r'END:VCARD';
const vCardVersionKey = r'VERSION';
const vCardSupportedVersion = r'4.0';
const vCardVersionRegEx = vCardVersionKey + keyValueSeparator + vCardSupportedVersion;
const vCardNKey = r'N';
const vCardNRegEx = r'((.*);){4}(.*)';
const vCardFNKey = r'FN';
const vCardFNValueRegEx = r'.*';
const vCardFnRegEx = vCardFNKey + keyValueSeparator + vCardFNValueRegEx;
const vCardIMPPKey = r'IMPP';
const lineBreakRegEx = r'((\r\n)|\n)';
const lineBreak = '\r\n';
const keyValueSeparator = r':';
const vCardNamePartsSeparator = r';';
const vCardNameValuesSeparator = r',';
const vCardRegex = vCardBegin +
    lineBreakRegEx +
    vCardVersionRegEx +
    lineBreakRegEx +
    r'(' +
    r'.*' +
    lineBreakRegEx +
    r')*' +
    vCardEnd;

class VCard {
  final String version;
  final VCardName? name;
  final List<String> formattedNames;
  final List<String> impps;

  const VCard({
    this.version = vCardSupportedVersion,
    this.name,
    required this.formattedNames,
    required this.impps,
  });

  static VCard fromString(String value) {
    if (!RegExp(vCardRegex).hasMatch(value) || !RegExp(vCardFnRegEx).hasMatch(value)) {
      throw VCardFormatException('No valid vcard data\n\r$value');
    }

    final properties = value.split(RegExp(lineBreakRegEx));
    final propertiesMap = properties.map((e) {
      final key = e.substring(0, e.indexOf(keyValueSeparator));
      final value = e.substring(e.indexOf(keyValueSeparator) + 1);

      return MapEntry((key.contains(';')) ? key.split(';').first : key, value);
    });

    return VCard(
      version: propertiesMap.firstWhere((it) => it.key == vCardVersionKey).value,
      name: propertiesMap.any((it) => it.key == vCardNKey)
          ? VCardName.fromString(propertiesMap.firstWhere((it) => it.key == vCardNKey).value)
          : null,
      formattedNames: propertiesMap.where((it) => it.key == 'FN').map((e) => e.value).toList(),
      impps: propertiesMap.where((it) => it.key == 'IMPP').map((e) => e.value).toList(),
    );
  }

  @override
  String toString() {
    String result =
        vCardBegin + lineBreak + vCardVersionKey + keyValueSeparator + version + lineBreak;
    if (name != null) result += vCardNKey + keyValueSeparator + name.toString() + lineBreak;
    for (int i = 0; i < formattedNames.length; i++) {
      result += vCardFNKey + keyValueSeparator + formattedNames[i] + lineBreak;
    }
    for (int i = 0; i < impps.length; i++) {
      result += vCardIMPPKey + keyValueSeparator + impps[i] + lineBreak;
    }
    result += vCardEnd;
    return result;
  }

  @override
  bool operator ==(other) =>
      other is VCard &&
      version == other.version &&
      name == other.name &&
      _deepEquals(other.formattedNames, formattedNames) &&
      _deepEquals(other.impps, impps);

  @override
  int get hashCode => Object.hash(version, name, formattedNames, impps);
}

class VCardName {
  final Set<String>? familyNames;
  final Set<String>? givenNames;
  final Set<String>? additionalNames;
  final Set<String>? honoricPrefixes;
  final Set<String>? honoricSuffixes;

  const VCardName({
    this.familyNames,
    this.givenNames,
    this.additionalNames,
    this.honoricPrefixes,
    this.honoricSuffixes,
  });

  static VCardName fromString(String value) {
    final regex = RegExp(vCardNRegEx);
    if (!regex.hasMatch(value)) throw VCardFormatException('No valid vcard name\n\r$value');

    final parts = value.split(vCardNamePartsSeparator);

    return VCardName(
      familyNames: (parts[0].isNotEmpty) ? parts[0].split(vCardNameValuesSeparator).toSet() : null,
      givenNames: (parts[1].isNotEmpty) ? parts[1].split(vCardNameValuesSeparator).toSet() : null,
      additionalNames:
          (parts[2].isNotEmpty) ? parts[2].split(vCardNameValuesSeparator).toSet() : null,
      honoricPrefixes:
          (parts[3].isNotEmpty) ? parts[3].split(vCardNameValuesSeparator).toSet() : null,
      honoricSuffixes:
          (parts[4].isNotEmpty) ? parts[4].split(vCardNameValuesSeparator).toSet() : null,
    );
  }

  @override
  String toString() =>
      '${familyNames?.join(vCardNameValuesSeparator) ?? ''}$vCardNamePartsSeparator'
      '${givenNames?.join(vCardNameValuesSeparator) ?? ''}$vCardNamePartsSeparator'
      '${additionalNames?.join(vCardNameValuesSeparator) ?? ''}$vCardNamePartsSeparator'
      '${honoricPrefixes?.join(vCardNameValuesSeparator) ?? ''}$vCardNamePartsSeparator'
      '${honoricSuffixes?.join(vCardNameValuesSeparator) ?? ''}';

  @override
  bool operator ==(other) =>
      other is VCardName &&
      _deepEquals(familyNames, other.familyNames) &&
      _deepEquals(givenNames, other.givenNames) &&
      _deepEquals(additionalNames, other.additionalNames) &&
      _deepEquals(honoricPrefixes, other.honoricPrefixes) &&
      _deepEquals(honoricSuffixes, other.honoricSuffixes);

  @override
  int get hashCode =>
      Object.hash(familyNames, givenNames, additionalNames, honoricPrefixes, honoricSuffixes);
}

final Function _deepEquals = const DeepCollectionEquality().equals;

sealed class VCardBaseException implements Exception {
  final String? message;

  const VCardBaseException([this.message]);

  @override
  String toString() => 'VCardException: ${message ?? ''}';
}

final class VCardFormatException extends VCardBaseException {
  const VCardFormatException([super.message]);
}
