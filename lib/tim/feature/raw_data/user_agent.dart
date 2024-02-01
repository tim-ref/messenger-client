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

part 'user_agent.g.dart';

@JsonSerializable(createFactory: false)
class UserAgent {
  @JsonKey(name: 'Produktversion')
  final String? productVersion;
  @JsonKey(name: 'Produkttypversion')
  final String? productTypeVersion;
  @JsonKey(name: 'Auspraegung')
  final String? specification;
  @JsonKey(name: 'Plattform')
  final String? platform;
  @JsonKey(name: 'OS')
  final String? operatingSystem;
  @JsonKey(name: 'OS-Version')
  final String? operatingSystemVersion;
  @JsonKey(name: 'client_id')
  final String? clientId;
  @JsonKey(name: 'Matrix-Domain')
  final String? matrixDomain;

  UserAgent({
    this.productVersion,
    this.productTypeVersion,
    this.specification,
    this.platform,
    this.operatingSystem,
    this.operatingSystemVersion,
    this.clientId,
    this.matrixDomain,
  });

  Map<String, dynamic> toJson() => _$UserAgentToJson(this);
}
