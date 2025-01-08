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

import 'package:fluffychat/tim/shared/provider/tim_provider.dart';
import 'package:fluffychat/tim/test_driver/contact_debug_widget.dart';
import 'package:fluffychat/tim/test_driver/displayname_debug_widget.dart';
import 'package:fluffychat/tim/test_driver/fhir_search_debug_widget.dart';
import 'package:fluffychat/tim/test_driver/mxid_debug_widget.dart';
import 'package:fluffychat/tim/test_driver/room_debug_widget.dart';
import 'package:fluffychat/tim/test_driver/test_driver_state_helper.dart';
import 'package:fluffychat/tim/test_driver/tim_auth_debug_widget.dart';
import 'package:fluffychat/tim/test_driver/tim_version_debug_widget.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import 'messages_debug_widget.dart';
import 'room_list_debug_widget.dart';

class DebugWidget extends StatefulWidget {
  const DebugWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DebugWidgetState();
}

class _DebugWidgetState extends State<DebugWidget> {
  late final TestDriverStateHelper? testDriverStateHelper;

  @override
  void initState() {
    testDriverStateHelper = TimProvider.of(context).testDriverStateHelper();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.amberAccent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder<LoginState?>(
                    stream: Matrix.of(context).client.onLoginStateChanged.stream,
                    builder: (context, snapshot) {
                      return Column(
                        key: ValueKey(snapshot.data),
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data?.toString() ?? "LoginState unknown",
                            key: const ValueKey("loginState"),
                          ),
                          const MxIdDebugWidget(
                            key: ValueKey("mxDebugWidget"),
                          ),
                          const DisplaynameDebugWidget(
                            key: ValueKey("displaynameDebugWidget"),
                          ),
                          const RoomDebugWidget(),
                          const RoomListDebugWidget(),
                          const MessagesDebugWidget(),
                          const ContactDebugWidget(),
                          const FhirSearchDebugWidget(),
                          const TimVersionDebugWidget(),
                          const TimAuthConceptDebugWidget(),
                        ].map(_wrapInPadding).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Padding _wrapInPadding(Widget widget) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: widget,
    );
