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
import 'package:fluffychat/tim/feature/raw_data/raw_data_delegating_io_client.dart';
import 'package:fluffychat/tim/feature/raw_data/user_agent.dart';
import 'package:fluffychat/tim/feature/raw_data/user_agent_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'raw_data_delegating_io_client_test.mocks.dart';

@GenerateMocks([IOClient, UserAgentBuilder])
void main() {
  late final MockIOClient ioClient;
  late final MockUserAgentBuilder userAgentBuilder;

  setUpAll(() {
    userAgentBuilder = MockUserAgentBuilder();
    ioClient = MockIOClient();
  });

  test('Should add correct Useragent header', () {
    // given
    final client = RawDataDelegatingIOClient(ioClient, userAgentBuilder);
    final request = Request('PUT', Uri.parse('http://localhost:8080/foo/bar'));
    final userAgent = UserAgent(
      operatingSystemVersion: 'operatingSystemVersion',
      clientId: defaultClientId,
    );
    when(userAgentBuilder.buildUserAgent()).thenReturn(userAgent);
    when(ioClient.send(request)).thenAnswer(
      (_) async => IOStreamedResponse(Stream.value([1, 3, 3, 7]), 200),
    );

    // when
    client.send(request);

    // expect
    expect(
      request.headers[userAgentHeaderName],
      equals(userAgent.toCommaSeparatedStringList()),
    );
    verify(ioClient.send(request)).called(1);
  });
}
