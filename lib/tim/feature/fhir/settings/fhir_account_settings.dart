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

import 'package:fluffychat/tim/feature/fhir/fhir_endpoint_address_converter.dart';
import 'package:fluffychat/tim/feature/fhir/settings/fhir_account_service.dart';
import 'package:fluffychat/tim/feature/fhir/settings/fhir_visibility_form.dart';
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

  late Future<TimAuthToken> _hbaAccess;
  late TimAuthToken? _authToken;
  bool tokenDispenserUrlUpdated = false;

  Future<bool> _fhirVisible = Future.value(false);

  @override
  void initState() {
    final client = TimProvider.of(context).matrix().client();
    final mxid = convertSigilToUri(client.userID);
    _fhirAccountService = TimProvider.of(context).fhirAccountService();
    _mxidController.value = TextEditingValue(
      text: mxid,
    );
    _hbaAccess = _fhirAccountService.hbaAccess();
    _hbaAccess.then((value) {
      _authToken = value;
      _fhirVisible = _fhirAccountService.getFhirVisibility(value, mxid);
    });
    _urlCtrl.value =
        TextEditingValue(text: TimProvider.of(context).tokenDispenserUrl ?? "");
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
            setState(() {
              _fhirVisible = _fhirAccountService.getFhirVisibility(
                _authToken!,
                _mxidController.text,
              );
            });
            return _fhirVisible;
          },
          child: Column(
            children: [
              if (const bool.fromEnvironment(enableDebugWidget))
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: tokenDispenserUrlUpdated
                      ? const Text(
                          key: ValueKey("tokenDispenserUrlUpdated"),
                          "Token updated.")
                      : Semantics(
                          label: "tokenDispenserUrl",
                          container: true,
                          textField: true,
                          child: TextField(
                            controller: _urlCtrl,
                            autocorrect: false,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: _updateToken,
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.black,
                                  key:
                                      ValueKey("updateTokenDispenserUrlButton"),
                                ),
                              ),
                              hintText: "Token dispenser URL",
                            ),
                          ),
                        ),
                ),
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMatrixIdLabel(),
                      FutureBuilder(
                        future: _hbaAccess,
                        builder: (context, hbaAccessSnapshot) {
                          switch (hbaAccessSnapshot.connectionState) {
                            case ConnectionState.waiting:
                              return _buildFhirVisibilityLoadingIndicator();
                            default:
                              if (hbaAccessSnapshot.hasError) {
                                return _buildFhirVisibilityError(
                                    hbaAccessSnapshot.error);
                              } else {
                                return _buildFhirVisibilityForm(
                                    hbaAccessSnapshot.hasData);
                              }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

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

  Widget _buildFhirVisibilityForm(bool hbaAccess) => FhirVisibilityForm(
        hbaAccess: hbaAccess,
        fhirVisible: _fhirVisible,
        onVisibilityChanged: _onVisibilityChanged,
      );

  _onVisibilityChanged(BuildContext context, bool visible) async {
    final client = TimProvider.of(context).matrix().client();
    final mxIdUri = _mxidController.text;
    final mxId = convertUriToSigil(mxIdUri);
    final displayName = await client.getDisplayName(mxId);
    setState(() {
      _fhirVisible = _fhirAccountService.setFhirVisibility(
        visible,
        mxIdUri,
        displayName ?? mxId,
        _authToken!,
      );
    });
  }

  _updateToken() async {
    await _fhirAccountService.updateHbaAccessToken(_urlCtrl.text);
    TimProvider.of(context).tokenDispenserUrl = _urlCtrl.text;
    _hbaAccess = _fhirAccountService.hbaAccess();
    _hbaAccess.then((token) {
      setState(() {
        tokenDispenserUrlUpdated = true;
        _fhirVisible = _fhirAccountService.getFhirVisibility(
          token,
          _mxidController.text,
        );
        _authToken = token;
      });
    });
  }
}
