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

import 'dart:async';

import 'package:fluffychat/tim/shared/provider/tim_provider.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import '../feature/automated_invite_rejection/invite_rejection_policy.dart';
import '../feature/automated_invite_rejection/invite_rejection_policy_json.dart';
import '../feature/automated_invite_rejection/invite_rejection_policy_repository.dart';
import '../shared/tim_services.dart';

class TimAuthConceptDebugWidget extends StatefulWidget {
  const TimAuthConceptDebugWidget({Key? key}) : super(key: key);

  @override
  State<TimAuthConceptDebugWidget> createState() => _TimAuthConceptDebugWidgetState();
}

class _TimAuthConceptDebugWidgetState extends State<TimAuthConceptDebugWidget> {
  late Stream<BasicEvent> _accountDataStream;
  late StreamSubscription<BasicEvent> _streamSubscription;

  Set<String> domainExceptions = {};
  Set<String> userExceptions = {};
  String defaultSetting = "";
  bool isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _accountDataStream = TimProvider.of(context)
        .matrix()
        .client()
        .onAccountDataChange()
        .stream
        .where((event) => event.type == permissionConfigNameSpace);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getInitialAccountData(TimProvider.of(context));
    });

    // Listen to the stream
    _streamSubscription = _accountDataStream.listen(_updateAccountData);
  }

  Future<void> _getInitialAccountData(TimServices timService) async {
    final policy = await timService.inviteRejectionPolicyRepository().getCurrentPolicy();

    if (mounted) {
      setState(() {
        switch (policy) {
          case AllowAllInvites():
            domainExceptions = policy.blockedDomains;
            userExceptions = policy.blockedUsers;
            defaultSetting = 'allow all';
            break;
          case BlockAllInvites():
            domainExceptions = policy.allowedDomains;
            userExceptions = policy.allowedUsers;
            defaultSetting = 'block all';
            break;
        }
        isInitialLoading = false;
      });
    }
  }

  void _updateAccountData(BasicEvent event) {
    final data = parseRejectionPolicyFromJson(event.content);

    if (mounted) {
      setState(() {
        defaultSetting = data is AllowAllInvites ? 'allow all' : 'block all';

        domainExceptions = switch (data) {
          AllowAllInvites() => data.blockedDomains,
          BlockAllInvites() => data.allowedDomains,
        };

        userExceptions = switch (data) {
          AllowAllInvites() => data.blockedUsers,
          BlockAllInvites() => data.allowedUsers,
        };
      });
    }
  }

  @override
  void dispose() {
    // Cancel the stream subscription
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isInitialLoading
        ? Container()
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(defaultSetting, key: const ValueKey("TimAuthMode")),
        Text(domainExceptions.join(';'), key: const ValueKey("TimAuthDomainExceptions")),
        Text(userExceptions.join(';'), key: const ValueKey("TimAuthUserExceptions")),
      ],
    );
  }
}
