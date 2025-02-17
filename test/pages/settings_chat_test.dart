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

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pages/settings_chat/settings_chat.dart';
import 'package:fluffychat/utils/famedlysdk_store.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:provider/provider.dart';

class MatrixStateMock extends MatrixState {
  @override
  bool get webrtcIsSupported => false;

  @override
  Store get store => Store();

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

Widget _wrapWidget({
  required Widget child,
}) =>
    Localizations(
      delegates: L10n.localizationsDelegates,
      locale: const Locale("en"),
      child: Provider<MatrixState>(
        create: (_) => MatrixStateMock(),
        child: child,
      ),
    );

void main() {
  testWidgets('Test public read receipts setting', (WidgetTester tester) async {
    const settings = SettingsChat();
    final widget = _wrapWidget(child: settings);
    await tester.pumpWidget(widget);

    expect(AppConfig.sendPublicReadReceipts, false);

    final readReceipts = find.byKey(const Key("public_read_receipts_setting"));

    await tester.tap(readReceipts);
    await tester.pumpAndSettle();
    expect(
      AppConfig.sendPublicReadReceipts,
      true,
    );
  });
}
