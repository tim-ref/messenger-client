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

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:fluffychat/tim/feature/hba/authentication/authenticator.dart';

class HbaPage extends StatelessWidget {
  const HbaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Logs().i("Render HbaPage");

    final token = context.vRouter.queryParameters["code"];

    Logs().i("HBA token: $token");

    if (token == null) {
      return Text(L10n.of(context)!.timHbaTokenMissing);
    } else {
      final auth = Authenticator();
      auth.publishAuthToken(token);
      return Text(L10n.of(context)!.timFetchedHbaToken);
    }
  }
}
