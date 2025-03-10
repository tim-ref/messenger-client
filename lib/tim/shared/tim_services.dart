/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - 2025 - akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_policy_repository.dart';
import 'package:fluffychat/tim/feature/automated_invite_rejection/invite_rejection_service.dart';
import 'package:fluffychat/tim/feature/contact_approval/contact_approval_repository.dart';
import 'package:fluffychat/tim/feature/fhir/search/fhir_search_service.dart';
import 'package:fluffychat/tim/feature/fhir/settings/fhir_account_service.dart';
import 'package:fluffychat/tim/feature/tim_version/tim_version_service.dart';
import 'package:fluffychat/tim/shared/matrix/tim_matrix.dart';
import 'package:fluffychat/tim/shared/tim_auth_state.dart';
import 'package:fluffychat/tim/test_driver/test_driver_state_helper.dart';

import '../feature/automated_invite_rejection/insurer_information_repository.dart';

/// Container providing services used in TIM.
/// These abstractions are meant to improve decoupling between TIM and FluffyChat as well as testability.
///
/// Services are merged to one object here to ease implementation of a provider in the widget hirarchy.
/// We prefer provider to separate dependency injection (like get_it) because we have objects in the widget tree that
/// differ per hierarchy, e.g. Matrix objects.
abstract class TimServices {
  TimMatrix matrix();

  ContactApprovalRepository contactsApprovalRepository();

  FhirSearchService fhirSearchService();

  FhirAccountService fhirAccountService();

  InviteRejectionPolicyRepository inviteRejectionPolicyRepository();

  InsurerInformationRepository insurerInformationRepository();

  TimVersionService get timVersionService;

  InviteRejectionService inviteRejectionService();

  TimAuthState timAuthState();

  TestDriverStateHelper? testDriverStateHelper();

  String? tokenDispenserUrl;
}
