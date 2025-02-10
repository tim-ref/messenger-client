//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Contact {
  /// Returns a new [Contact] instance.
  Contact({
    required this.displayName,
    required this.mxid,
    required this.inviteSettings,
  });

  /// Name of the contact.
  String displayName;

  /// MXID of the contact (@localpart:domain)). See
  String mxid;

  ContactInviteSettings inviteSettings;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contact &&
          other.displayName == displayName &&
          other.mxid == mxid &&
          other.inviteSettings == inviteSettings;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (displayName.hashCode) + (mxid.hashCode) + (inviteSettings.hashCode);

  @override
  String toString() =>
      'Contact[displayName=$displayName, mxid=$mxid, inviteSettings=$inviteSettings]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'displayName'] = this.displayName;
    json[r'mxid'] = this.mxid;
    json[r'inviteSettings'] = this.inviteSettings;
    return json;
  }

  /// Returns a new [Contact] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Contact? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "Contact[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "Contact[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Contact(
        displayName: mapValueOfType<String>(json, r'displayName')!,
        mxid: mapValueOfType<String>(json, r'mxid')!,
        inviteSettings:
            ContactInviteSettings.fromJson(json[r'inviteSettings'])!,
      );
    }
    return null;
  }

  static List<Contact> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <Contact>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Contact.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Contact> mapFromJson(dynamic json) {
    final map = <String, Contact>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Contact.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Contact-objects as value to a dart map
  static Map<String, List<Contact>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<Contact>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Contact.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'displayName',
    'mxid',
    'inviteSettings',
  };
}
