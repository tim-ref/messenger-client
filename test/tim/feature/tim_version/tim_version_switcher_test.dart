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
import 'package:fluffychat/tim/feature/tim_version/tim_version_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils/widget_wrapper.dart';
import 'mock_tim_version_service_provider.dart';
@GenerateNiceMocks([
  MockSpec<TimVersionService>(),
])
import 'tim_version_switcher_test.mocks.dart';

const _classicKey = Key("radio button: TI-M version classic");
const _ePAKey = Key("radio button: TI-M version ePA");

main() {
  late MockTimVersionService serviceMock;
  late Widget wrappedWidget;

  setUp(() async {
    serviceMock = MockTimVersionService();
    wrappedWidget = wrap(wrapWithTimVersionServiceProvider(
      child: const TimVersionSwitcher(),
      timVersionService: serviceMock,
    ));
  });

  testWidgets('can set TI-M version ePA', (tester) async {
    await tester.pumpWidget(wrappedWidget);

    final ePaRadioFinder = find.byKey(_ePAKey);

    expect(ePaRadioFinder, findsOneWidget);

    await tester.tap(ePaRadioFinder);
    await tester.pump();

    verify(serviceMock.set(TimVersion.ePA));
  });

  testWidgets('can set TI-M version classic', (tester) async {
    await tester.pumpWidget(wrappedWidget);

    final ePaRadioFinder = find.byKey(_ePAKey);
    await tester.tap(ePaRadioFinder);
    await tester.pump();

    final classicRadioFinder = find.byKey(_classicKey);

    expect(classicRadioFinder, findsOneWidget);

    await tester.tap(classicRadioFinder);
    await tester.pump();

    verify(serviceMock.set(TimVersion.classic));
  });
}
