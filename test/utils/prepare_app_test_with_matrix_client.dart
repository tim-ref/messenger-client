/*
 * TIM-Referenzumgebung
 * Copyright (C) 2025 - akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';
import 'package:vrouter/vrouter.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

import '../pages/settings_chat_test.dart';

Future<void> prepareAppTestWithMatrixClient({
  required Widget child,
  required WidgetTester tester,
  required Client client,
}) async {
  await tester.pumpWidget(
    VRouter(
      localizationsDelegates: L10n.localizationsDelegates,
      key: GlobalKey<VRouterState>(),
      supportedLocales: L10n.supportedLocales,
      routes: [
        VWidget(
          path: '/',
          widget: Builder(
            builder: (context) {
              return Provider<MatrixState>(
                create: (_) => MatrixStateMock(),
                child: Matrix(
                  router: null,
                  context: context,
                  clients: [client],
                  child: child,
                ),
              );
            },
          ),
        ),
      ],
    ),
  );

  await tester.pump(const Duration(milliseconds: 300));
}
