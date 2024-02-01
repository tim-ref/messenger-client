// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tim_auth_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimAuthToken _$TimAuthTokenFromJson(Map<String, dynamic> json) => TimAuthToken(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      matrixServerName: json['matrix_server_name'] as String?,
      expiresIn: json['expires_in'] as int,
    );

Map<String, dynamic> _$TimAuthTokenToJson(TimAuthToken instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'matrix_server_name': instance.matrixServerName,
      'expires_in': instance.expiresIn,
    };
