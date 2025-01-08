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
import 'package:fluffychat/tim/shared/tim_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimVersionDebugWidget extends StatefulWidget {
  const TimVersionDebugWidget({
    super.key,
  });

  @override
  State<TimVersionDebugWidget> createState() => _TimVersionDebugWidgetState();
}

class _TimVersionDebugWidgetState extends State<TimVersionDebugWidget> {
  late final Future<TimVersion> _futureVersion;

  @override
  void initState() {
    super.initState();
    _futureVersion = context.read<TimServices>().timVersionService.get();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("TI-M version: "),
        FutureBuilder<TimVersion>(
          future: _futureVersion,
          builder: (BuildContext context, AsyncSnapshot<TimVersion?> snapshot) {
            var text = "loading";
            if (snapshot.hasData) {
              text = switch (snapshot.data!) {
                TimVersion.classic => "classic",
                TimVersion.ePA => "ePA",
              };
            } else if (snapshot.hasError) {
              text = "error: ${snapshot.error}";
            }
            return Text(
              text,
              key: const Key("Text: TI-M version"),
            );
          },
        ),
      ],
    );
  }
}
