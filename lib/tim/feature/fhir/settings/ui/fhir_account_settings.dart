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

import 'package:fluffychat/tim/feature/fhir/fhir_endpoint_address_converter.dart';
import 'package:fluffychat/tim/feature/fhir/settings/fhir_account_service.dart';
import 'package:fluffychat/tim/feature/fhir/settings/fhir_practitioner_visibility.dart';
import 'package:fluffychat/tim/feature/fhir/settings/ui/fhir_visibility_form.dart';
import 'package:fluffychat/tim/feature/fhir/settings/ui/negated_visibility_setting_list_tile.dart';
import 'package:fluffychat/tim/shared/provider/tim_provider.dart';
import 'package:fluffychat/tim/shared/tim_auth_token.dart';
import 'package:fluffychat/tim/tim_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class FhirAccountSettings extends StatefulWidget {
  const FhirAccountSettings({Key? key}) : super(key: key);

  @override
  State<FhirAccountSettings> createState() => _FhirAccountSettingsState();
}

class _FhirAccountSettingsState extends State<FhirAccountSettings> {
  final TextEditingController _mxidController = TextEditingController();
  final TextEditingController _urlCtrl = TextEditingController();
  late final FhirAccountService _fhirAccountService;

  late TimAuthToken? _authToken;
  bool tokenDispenserUrlUpdated = false;

  Future<PractitionerVisibility> _practitionerVisibility =
      Future.value(PractitionerVisibility.none());

  @override
  void initState() {
    final client = TimProvider.of(context).matrix().client();
    final mxid = convertSigilToUri(client.userID);
    _fhirAccountService = TimProvider.of(context).fhirAccountService();
    _mxidController.value = TextEditingValue(
      text: mxid,
    );
    _practitionerVisibility = _fhirAccountService.hbaAccessToken().then((token) {
      _authToken = token;
      return _fhirAccountService.fetchPractitionerVisibility(token, mxid);
    });
    _urlCtrl.value = TextEditingValue(text: TimProvider.of(context).tokenDispenserUrl ?? "");
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _mxidController.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          onRefresh: () {
            _refreshPractitionerVisibility();
            return _practitionerVisibility;
          },
          child: Column(
            children: [
              if (const bool.fromEnvironment(enableDebugWidget))
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: tokenDispenserUrlUpdated
                      ? const Text(
                          key: ValueKey("tokenDispenserUrlUpdated"),
                          "Token updated.",
                        )
                      : _tokenDispenserUrlForm(),
                ),
              SingleChildScrollView(
                padding: const EdgeInsets.only(left: 16, right: 16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMatrixIdLabel(),
                    FutureBuilder(
                      future: _practitionerVisibility,
                      builder: (context, visibilitySnapshot) =>
                          switch (visibilitySnapshot.connectionState) {
                        ConnectionState.waiting => _buildFhirVisibilityLoadingIndicator(),
                        _ => visibilitySnapshot.hasError
                            ? _buildFhirVisibilityError(visibilitySnapshot.error)
                            : Column(
                                children: [
                                  FhirVisibilityForm(
                                    visible: visibilitySnapshot.data?.isGenerallyVisible,
                                    onChanged:
                                        visibilitySnapshot.hasData ? _onVisibilityChanged : null,
                                  ),
                                  /// [AF_10376 - Practitioner - FHIR-VZD Sichtbarkeit für Versicherte setzen](https://gemspec.gematik.de/docs/gemSpec/gemSpec_TI-M_Pro/gemSpec_TI-M_Pro_V1.0.1/#AF_10376)
                                  NegatedVisibilitySettingListTile(
                                    visibilityOff:
                                        visibilitySnapshot.data?.isVisibleExceptFromInsurees ??
                                            false,
                                    onChanged: visibilitySnapshot.data?.isGenerallyVisible == true
                                        ? (isHiddenFromInsurees) => _onVisibilityToInsureesChanged(
                                              context,
                                              isHiddenFromInsurees: isHiddenFromInsurees,
                                            )
                                        : null,
                                  ),
                                ],
                              ),
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Semantics _tokenDispenserUrlForm() {
    return Semantics(
      label: "tokenDispenserUrl",
      container: true,
      textField: true,
      child: TextField(
        controller: _urlCtrl,
        autocorrect: false,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: _onTokenDispenserUrlInputSubmitted,
            icon: const Icon(
              Icons.refresh,
              color: Colors.black,
              key: ValueKey("updateTokenDispenserUrlButton"),
            ),
          ),
          hintText: "Token dispenser URL",
        ),
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
        title: Text(L10n.of(context)!.timFhirAccount),
      );

  Widget _buildMatrixIdLabel() => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: TextField(
          readOnly: true,
          controller: _mxidController,
        ),
      );

  Widget _buildFhirVisibilityLoadingIndicator() => const Center(
        child: CircularProgressIndicator(),
      );

  Widget _buildFhirVisibilityError(Object? error) => Center(
        child: Text(
          error.toString(),
          key: const ValueKey("tokenDispenserErrorText"),
        ),
      );

  Future<void> _onVisibilityChanged(BuildContext context, bool visible) async {
    final client = TimProvider.of(context).matrix().client();
    final mxIdUri = _mxidController.text;
    final mxId = convertUriToSigil(mxIdUri);
    final displayName = await client.getDisplayName(mxId);
    await _fhirAccountService.setUsersVisibility(
      isVisible: visible,
      owningPractitionersMxid: mxIdUri,
      endpointName: displayName ?? mxId,
      token: _authToken!,
    );
    _refreshPractitionerVisibility();
  }

  Future<void> _onVisibilityToInsureesChanged(BuildContext context,
      {required bool isHiddenFromInsurees}) async {
    final client = TimProvider.of(context).matrix().client();
    final mxIdUri = _mxidController.text;
    final mxId = convertUriToSigil(mxIdUri);
    final displayName = await client.getDisplayName(mxId);
    await _fhirAccountService.setUsersVisibilityTowardsInsurees(
      shouldBeVisible: !isHiddenFromInsurees,
      owningPractitionersMxid: mxIdUri,
      endpointName: displayName ?? mxId,
      token: _authToken!,
    );
    _refreshPractitionerVisibility();
  }

  void _refreshPractitionerVisibility() {
    setState(() {
      _practitionerVisibility = _fhirAccountService.fetchPractitionerVisibility(
        _authToken!,
        _mxidController.text,
      );
    });
  }

  Future<void> _onTokenDispenserUrlInputSubmitted() async {
    await _fhirAccountService.updateHbaAccessToken(_urlCtrl.text);
    TimProvider.of(context).tokenDispenserUrl = _urlCtrl.text;
    final token = await _fhirAccountService.hbaAccessToken();
    setState(() {
      tokenDispenserUrlUpdated = true;
      _practitionerVisibility = _fhirAccountService.fetchPractitionerVisibility(
        token,
        _mxidController.text,
      );
      _authToken = token;
    });
  }
}
