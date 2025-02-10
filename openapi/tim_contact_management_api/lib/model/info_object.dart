//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class InfoObject {
  /// Returns a new [InfoObject] instance.
  InfoObject({
    required this.title,
    required this.version,
    this.description,
    this.contact,
  });

  /// Der Titel der Anwendung
  String title;

  /// Version der implementierten TiMessengerContactManagement.yaml Schnittstelle (Version der TiMessengerContactManagement.yaml Datei)
  String version;

  /// Short description of the application
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? description;

  /// Contact information
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? contact;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InfoObject &&
          other.title == title &&
          other.version == version &&
          other.description == description &&
          other.contact == contact;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (title.hashCode) +
      (version.hashCode) +
      (description == null ? 0 : description!.hashCode) +
      (contact == null ? 0 : contact!.hashCode);

  @override
  String toString() =>
      'InfoObject[title=$title, version=$version, description=$description, contact=$contact]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'title'] = this.title;
    json[r'version'] = this.version;
    if (this.description != null) {
      json[r'description'] = this.description;
    } else {
      json[r'description'] = null;
    }
    if (this.contact != null) {
      json[r'contact'] = this.contact;
    } else {
      json[r'contact'] = null;
    }
    return json;
  }

  /// Returns a new [InfoObject] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static InfoObject? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "InfoObject[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "InfoObject[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return InfoObject(
        title: mapValueOfType<String>(json, r'title')!,
        version: mapValueOfType<String>(json, r'version')!,
        description: mapValueOfType<String>(json, r'description'),
        contact: mapValueOfType<String>(json, r'contact'),
      );
    }
    return null;
  }

  static List<InfoObject> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <InfoObject>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InfoObject.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, InfoObject> mapFromJson(dynamic json) {
    final map = <String, InfoObject>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = InfoObject.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of InfoObject-objects as value to a dart map
  static Map<String, List<InfoObject>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<InfoObject>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = InfoObject.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'title',
    'version',
  };
}
