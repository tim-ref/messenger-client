// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Contact _$ContactFromJson(Map<String, dynamic> json) => Contact(
      displayName: json['displayName'] as String,
      mxid: json['mxid'] as String,
      inviteSettings: InviteSettings.fromJson(
          json['inviteSettings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ContactToJson(Contact instance) => <String, dynamic>{
      'displayName': instance.displayName,
      'mxid': instance.mxid,
      'inviteSettings': instance.inviteSettings,
    };
