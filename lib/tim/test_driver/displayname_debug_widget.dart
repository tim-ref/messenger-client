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

import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';

class DisplaynameDebugWidget extends StatelessWidget {
  const DisplaynameDebugWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _fetchDisplayName(context),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const CircularProgressIndicator();
          default:
            if (snapshot.hasData) {
              return Text(
                snapshot.data,
                key: const ValueKey("displayName"),
              );
            }
            return Container();
        }
      },
    );
  }

  Future<String?> _fetchDisplayName(BuildContext context) async {
    final client = Matrix.of(context).client;
    final mxId = client.userID;
    if (mxId?.isEmpty ?? true) {
      return Future.value(null);
    } else {
      return await client.getDisplayName(mxId!);
    }
  }
}
