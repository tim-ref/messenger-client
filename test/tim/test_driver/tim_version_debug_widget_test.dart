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

import 'package:fluffychat/tim/feature/tim_version/tim_version.dart';
import 'package:fluffychat/tim/feature/tim_version/tim_version_service.dart';
import 'package:fluffychat/tim/test_driver/tim_version_debug_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../feature/tim_version/mock_tim_version_service_provider.dart';
import '../utils/widget_wrapper.dart';
@GenerateNiceMocks([
  MockSpec<TimVersionService>(),
])
import 'tim_version_debug_widget_test.mocks.dart';

main() {
  late MockTimVersionService serviceStub;
  late Widget wrappedWidget;

  setUp(() async {
    serviceStub = MockTimVersionService();
    wrappedWidget = wrap(wrapWithTimVersionServiceProvider(
      child: const TimVersionDebugWidget(),
      timVersionService: serviceStub,
    ));
  });

  testWidgets('can show TI-M version classic', (tester) async {
    when(serviceStub.get()).thenAnswer((_) async => TimVersion.classic);
    await tester.pumpWidget(wrappedWidget);
    await tester.pumpAndSettle();

    expect(find.text("classic"), findsOneWidget);
  });

  testWidgets('can show TI-M version ePA', (tester) async {
    when(serviceStub.get()).thenAnswer((_) async => TimVersion.ePA);
    await tester.pumpWidget(wrappedWidget);
    await tester.pumpAndSettle();

    expect(find.text("ePA"), findsOneWidget);
  });

  testWidgets('should have Text Widget with expected key', (tester) async {
    await tester.pumpWidget(wrappedWidget);

    expect(find.byKey(const Key("Text: TI-M version")), findsOneWidget);
  });
}
