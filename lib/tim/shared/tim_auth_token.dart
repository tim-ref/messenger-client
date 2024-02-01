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

import 'package:json_annotation/json_annotation.dart';

part 'tim_auth_token.g.dart';

@JsonSerializable()
class TimAuthToken {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  @JsonKey(name: 'matrix_server_name')
  final String? matrixServerName;

  /// Validity period in seconds
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  TimAuthToken({
    required this.accessToken,
    required this.tokenType,
    this.matrixServerName,
    required this.expiresIn,
  });

  factory TimAuthToken.fromJson(Map<String, dynamic> json) => _$TimAuthTokenFromJson(json);

  Map<String, dynamic> toJson() => _$TimAuthTokenToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimAuthToken &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          tokenType == other.tokenType &&
          matrixServerName == other.matrixServerName &&
          expiresIn == other.expiresIn;
}
