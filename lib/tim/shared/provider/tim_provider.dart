/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - 2025 akquinet GmbH
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
import 'package:fluffychat/tim/feature/fhir/fhir_config.dart';
import 'package:fluffychat/tim/feature/fhir/fhir_repository.dart';
import 'package:fluffychat/tim/feature/fhir/search/fhir_search_service.dart';
import 'package:fluffychat/tim/feature/fhir/settings/fhir_account_service.dart';
import 'package:fluffychat/tim/feature/hba/authentication/hba_authentication.dart';
import 'package:fluffychat/tim/feature/hba/authentication/hba_authentication_factory.dart';
import 'package:fluffychat/tim/feature/raw_data/raw_data_delegating_client.dart';
import 'package:fluffychat/tim/feature/raw_data/user_agent_builder.dart';
import 'package:fluffychat/tim/feature/tim_version/tim_version_repository.dart';
import 'package:fluffychat/tim/shared/matrix/tim_matrix.dart';
import 'package:fluffychat/tim/shared/tim_auth_repository.dart';
import 'package:fluffychat/tim/shared/tim_auth_state.dart';
import 'package:fluffychat/tim/shared/tim_services.dart';
import 'package:fluffychat/tim/test_driver/debug_widget.dart';
import 'package:fluffychat/tim/test_driver/draggable_widget.dart';
import 'package:fluffychat/tim/test_driver/test_driver_state_helper.dart';
import 'package:fluffychat/tim/tim_constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

import '../../feature/automated_invite_rejection/insurer_information_repository.dart';
import '../../feature/tim_version/tim_version_service.dart';

/// Provider for [TimServices].
class TimProvider extends StatefulWidget {
  /// Access the [TimServices]. You can call this anywhere below [TimProvider].
  static TimServices of(BuildContext context) => Provider.of<TimServices>(context, listen: false);

  final TimMatrix matrix;
  final Widget? child;

  const TimProvider({
    required this.matrix,
    this.child,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TimProviderState();
}

class TimProviderState extends State<TimProvider> implements TimServices {
  TestDriverStateHelper? _tdh;
  final _debugWidgetEnabled = const bool.fromEnvironment(enableDebugWidget);
  final _debugWidgetVisible = const bool.fromEnvironment(debugWidgetVisible);
  TimAuthState? _authState;
  late final _timVersionRepository = TimVersionRepository();

  @override
  late final timVersionService = TimVersionService(_timVersionRepository);

  InviteRejectionService? _inviteRejectionService;
  InviteRejectionPolicyRepository? _inviteRejectionPolicyRepository;
  late final InsurerInformationRepository _insurerInformationRepository =
      InsurerInformationRepository(
    widget.matrix.client(),
    _timAuthRepository(),
    _httpClient(),
  );

  @override
  TimMatrix matrix() => widget.matrix;

  @override
  ContactApprovalRepository contactsApprovalRepository() => ContactApprovalRepository(
        widget.matrix.client(),
        _timAuthRepository(),
        _httpClient(),
      );

  @override
  FhirSearchService fhirSearchService() => FhirSearchService(
        _fhirRepository(),
      );

  @override
  FhirAccountService fhirAccountService() => FhirAccountService(
        _timAuthRepository(),
        _fhirRepository(),
        timAuthState(),
      );

  @override
  String? tokenDispenserUrl;

  @override
  TestDriverStateHelper? testDriverStateHelper() =>
      !(_debugWidgetEnabled) ? null : _tdh ?? TestDriverStateHelper();

  @override
  TimAuthState timAuthState() {
    _authState ??= TimAuthState();
    return _authState!;
  }

  // Use for Production system with existing instance that has configured the authorisation concept in the client
  @override
  InviteRejectionPolicyRepository inviteRejectionPolicyRepository() {
    _initInviteRejectionPolicyRepository();
    return _inviteRejectionPolicyRepository!;
  }

  /* // Use for local testing purposes without an existing instance that has configured the authorisation concept in the client.
  @override
  InviteRejectionPolicyRepository inviteRejectionPolicyRepository() =>
      InviteRejectionPolicyRepositoryFakeImpl(widget.matrix.client());
*/
  @override
  InviteRejectionService inviteRejectionService() {
    _initInviteRejectionService();
    return _inviteRejectionService!;
  }

  @override
  void initState() {
    if (_debugWidgetEnabled) {
      _tdh = testDriverStateHelper();
      _tdh!.initTestDriverSubjects();
    }
    _initInviteRejectionPolicyRepository();
    _initInviteRejectionService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Provider<TimServices>(
        create: (_) => this,
        child: (_debugWidgetEnabled)
            ? Stack(fit: StackFit.expand, children: _getChildOrder())
            : widget.child,
      );

  @override
  void dispose() {
    _tdh?.disposeTestDriverSubjects();
    _inviteRejectionService?.dispose();
    super.dispose();
  }

  List<Widget> _getChildOrder() {
    final children = <Widget>[
      const DraggableWidget(
        child: DebugWidget(),
      ),
      Container(child: widget.child),
    ];

    return (_debugWidgetVisible) ? children.reversed.toList() : children;
  }

  FhirRepository _fhirRepository() =>
      FhirRepository(_httpClient(), _timAuthRepository(), _fhirConfig());

  HbaAuthentication _hbaAuthentication() {
    return HbaAuthenticationFactory().getHbaAuthentication();
  }

  TimAuthRepository _timAuthRepository() => TimAuthRepository(
        _httpClient(),
        widget.matrix.client(),
        _fhirConfig(),
        _hbaAuthentication(),
      );

  FhirConfig _fhirConfig() {
    final config = FhirConfig(
      host: 'https://fhir-directory-ref.vzd.ti-dienste.de',
      searchBase: '/search',
      authBase: '/tim-authenticate',
      ownerBase: '/owner',
    );

    Logs().i("Using FhirConfig: $config");
    return config;
  }

  // Stelle sicher, das der EventHandler von [InviteRejectionService] registriert ist
  void _initInviteRejectionService() {
    if (_inviteRejectionService == null) {
      _inviteRejectionService = InviteRejectionService(
        timVersionService: timVersionService,
        inviteRejectionPolicyRepository: inviteRejectionPolicyRepository(),
        client: widget.matrix.client(),
        timInformationRepository: insurerInformationRepository(),
      );
      _inviteRejectionService!.initInviteRejectOnEventStream();
    }
  }

  // Stelle sicher, das der EventHandler von [InviteRejectionService] registriert ist
  void _initInviteRejectionPolicyRepository() {
    if (_inviteRejectionPolicyRepository == null) {
      _inviteRejectionPolicyRepository =
          InviteRejectionPolicyRepositoryImpl(widget.matrix.client());
      _inviteRejectionPolicyRepository!.listenToNewRejectionPolicy();
    }
  }

  http.Client _httpClient() => RawDataDelegatingClient(
        FixedTimeoutHttpClient(http.Client(), const Duration(seconds: 180)),
        UserAgentBuilder(),
      );

  @override
  InsurerInformationRepository insurerInformationRepository() => _insurerInformationRepository;
}
