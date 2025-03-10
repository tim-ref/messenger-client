/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - 2025 – akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/tim/shared/provider/tim_provider.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import '../feature/automated_invite_rejection/invite_rejection_policy.dart';
import '../feature/automated_invite_rejection/invite_rejection_policy_json.dart';
import '../feature/automated_invite_rejection/invite_rejection_policy_repository.dart';

class TimAuthConceptDebugWidget extends StatefulWidget {
  const TimAuthConceptDebugWidget({Key? key}) : super(key: key);

  @override
  State<TimAuthConceptDebugWidget> createState() => _TimAuthConceptDebugWidgetState();
}

class _TimAuthConceptDebugWidgetState extends State<TimAuthConceptDebugWidget> {
  @override
  Widget build(BuildContext context) => StreamBuilder<BasicEvent>(
        stream: TimProvider.of(context)
            .matrix()
            .client()
            .onAccountDataChange()
            .stream
            .where((event) => event.type == permissionConfigNameSpace),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            final data = parseRejectionPolicyFromJson(snapshot.requireData.content);
            final defaultSetting = switch (data) {
              AllowAllInvites() => 'allow all',
              BlockAllInvites() => 'block all',
            };

            final domainExceptions = switch (data) {
              AllowAllInvites(blockedServers: final serverExceptions) ||
              BlockAllInvites(allowedServers: final serverExceptions) =>
                serverExceptions,
            };

            final userExceptions = switch (data) {
              AllowAllInvites(blockedUsers: final userExceptions) ||
              BlockAllInvites(allowedUsers: final userExceptions) =>
                userExceptions,
            };

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(defaultSetting, key: const ValueKey("TimAuthMode")),
                Text(domainExceptions.join(';'), key: const ValueKey("TimAuthDomainExceptions")),
                Text(userExceptions.join(';'), key: const ValueKey("TimAuthUserExceptions")),
              ],
            );
          }
          return const Text("no tim auth concept list received yet");
        },
      );
}
