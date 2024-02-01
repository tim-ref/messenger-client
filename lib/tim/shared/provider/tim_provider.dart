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

import 'package:fluffychat/tim/feature/contact_approval/contact_approval_repository.dart';
import 'package:fluffychat/tim/feature/fhir/fhir_config.dart';
import 'package:fluffychat/tim/feature/fhir/fhir_repository.dart';
import 'package:fluffychat/tim/feature/fhir/search/fhir_search_service.dart';
import 'package:fluffychat/tim/feature/fhir/settings/fhir_account_service.dart';
import 'package:fluffychat/tim/feature/hba/authentication/hba_authentication.dart';
import 'package:fluffychat/tim/feature/hba/authentication/hba_authentication_factory.dart';
import 'package:fluffychat/tim/feature/raw_data/raw_data_delegating_client.dart';
import 'package:fluffychat/tim/feature/raw_data/user_agent_builder.dart';
import 'package:fluffychat/tim/shared/matrix/tim_matrix.dart';
import 'package:fluffychat/tim/shared/tim_auth_repository.dart';
import 'package:fluffychat/tim/shared/tim_auth_state.dart';
import 'package:fluffychat/tim/shared/tim_services.dart';
import 'package:fluffychat/tim/test_driver/debug_widget.dart';
import 'package:fluffychat/tim/test_driver/draggable_widget.dart';
import 'package:fluffychat/tim/test_driver/test_driver_state_helper.dart';
import 'package:fluffychat/tim/tim_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

/// Provider for [TimServices].
class TimProvider extends StatefulWidget {
  /// Access the [TimServices]. You can call this anywhere below [TimProvider].
  static TimServices of(BuildContext context) =>
      Provider.of<TimProviderState>(context, listen: false);

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

  @override
  TimMatrix matrix() => widget.matrix;

  @override
  ContactApprovalRepository contactsApprovalRepository() =>
      ContactApprovalRepository(
        _httpClient(),
        widget.matrix.client(),
        _timAuthRepository(),
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

  @override
  void initState() {
    if (_debugWidgetEnabled) {
      _tdh = testDriverStateHelper();
      _tdh!.initTestDriverSubjects();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Provider(
        create: (_) => this,
        child: (_debugWidgetEnabled)
            ? Stack(fit: StackFit.expand, children: _getChildOrder())
            : widget.child,
      );

  @override
  void dispose() {
    _tdh?.disposeTestDriverSubjects();
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
    final FhirConfig config;

    if (kIsWeb) {
      config = FhirConfig(
        host: "${Uri.base.scheme}://${Uri.base.host}:${Uri.base.port}",
        searchBase: '/vzd/search',
        authBase: '/vzd/tim-authenticate',
        ownerBase: '/vzd/owner',
      );
    } else {
      config = FhirConfig(
        host: 'https://fhir-directory-ref.vzd.ti-dienste.de',
        searchBase: '/search',
        authBase: '/tim-authenticate',
        ownerBase: '/owner',
      );
    }

    Logs().i("Using FhirConfig: $config");
    return config;
  }

  http.Client _httpClient() => RawDataDelegatingClient(
      FixedTimeoutHttpClient(http.Client(), const Duration(seconds: 180)),
      UserAgentBuilder());
}
