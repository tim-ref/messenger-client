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

import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const user = "user";
  const domain = "domain";
  const mxid = "@$user:$domain";

  group("allow all policy", () {
    test("invite from user who is not blocked -> should not be rejected", () async {
      final inviteRejectionPolicy = AllowAllInvites.blockingNone();
      final result = doesReject(inviteRejectionPolicy, mxid, domain);

      expect(result, isFalse);
    });

    test("invite from user who is blocked by mxid -> should be rejected", () async {
      final inviteRejectionPolicy = AllowAllInvites(
        blockedUsers: {mxid},
        blockedDomains: {},
      );
      final result = doesReject(inviteRejectionPolicy, mxid, domain);

      expect(result, isTrue);
    });

    test("invite from user who is blocked by domain -> should be rejected", () async {
      final inviteRejectionPolicy = AllowAllInvites(
        blockedUsers: {},
        blockedDomains: {domain},
      );
      final result = doesReject(inviteRejectionPolicy, mxid, domain);

      expect(result, isTrue);
    });

    test("invite from user who is blocked by mxid and domain -> should be rejected", () async {
      final inviteRejectionPolicy = AllowAllInvites(
        blockedUsers: {mxid},
        blockedDomains: {domain},
      );
      final result = doesReject(inviteRejectionPolicy, mxid, domain);

      expect(result, isTrue);
    });
  });

  group("block all policy", () {
    test("invite from user who is not allowed -> should be rejected", () async {
      final inviteRejectionPolicy = BlockAllInvites.allowingNone();
      final result = doesReject(inviteRejectionPolicy, mxid, domain);

      expect(result, isTrue);
    });

    test("invite from user who is allowed by mxid -> should not be rejected", () async {
      final inviteRejectionPolicy = BlockAllInvites(
        allowedUsers: {mxid},
        allowedDomains: {},
      );
      final result = doesReject(inviteRejectionPolicy, mxid, domain);

      expect(result, isFalse);
    });

    test("invite from user who is allowed by domain -> should not be rejected", () async {
      final inviteRejectionPolicy = BlockAllInvites(
        allowedUsers: {},
        allowedDomains: {domain},
      );
      final result = doesReject(inviteRejectionPolicy, mxid, domain);

      expect(result, isFalse);
    });
  });
}
