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
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:fluffychat/tim/feature/raw_data/user_agent_builder.dart';

class RawDataDelegatingIOClient extends IOClient {
  final IOClient _client;
  final UserAgentBuilder _userAgentBuilder;

  RawDataDelegatingIOClient(this._client, this._userAgentBuilder);

  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) {
    final userAgent = _userAgentBuilder.buildUserAgent();
    request.headers.putIfAbsent(userAgentHeaderName, userAgent.toCommaSeparatedStringList);
    return _client.send(request);
  }
}
