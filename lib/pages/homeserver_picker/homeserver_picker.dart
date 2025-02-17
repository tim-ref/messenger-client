/*
 * Modified by akquinet GmbH on 2025-02-04
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pages/homeserver_picker/homeserver_picker_view.dart';
import 'package:fluffychat/utils/localized_exception_extension.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

class HomeserverPicker extends StatefulWidget {
  final bool enableBackButton;

  const HomeserverPicker({Key? key, this.enableBackButton = false}) : super(key: key);

  @override
  HomeserverPickerController createState() => HomeserverPickerController();
}

class HomeserverPickerController extends State<HomeserverPicker> {
  final TextEditingController homeserverController = TextEditingController(
    text: AppConfig.defaultHomeserver,
  );
  final FocusNode homeserverFocusNode = FocusNode();
  String? error;
  bool isLoading = false;
  String searchTerm = '';

  void onChanged(String text) => setState(() {
        searchTerm = text;
      });

  void setServer(String server) => setState(() {
        homeserverController.text = server;
        searchTerm = '';
        homeserverFocusNode.unfocus();
      });

  /// Starts an analysis of the given homeserver. It uses the current domain and
  /// makes sure that it is prefixed with https. Then it searches for the
  /// well-known information and forwards to the login page depending on the
  /// login type.
  Future<void> checkHomeserverAction() async {
    setState(() {
      homeserverFocusNode.unfocus();
      error = null;
      isLoading = true;
      searchTerm = '';
    });

    try {
      homeserverController.text =
          homeserverController.text.trim().toLowerCase().replaceAll(' ', '-');
      var homeserver = Uri.parse(homeserverController.text);
      if (homeserver.scheme.isEmpty) {
        homeserver = Uri.https(homeserverController.text, '');
      }
      final matrix = Matrix.of(context);
      final loginClient = matrix.getLoginClient();
      final (_, _, loginFlows) = await loginClient.checkHomeserver(homeserver);
      matrix.loginFlows = loginFlows;
      final ssoSupported = matrix.loginFlows?.any((flow) => flow.type == 'm.login.sso') ?? false;

      try {
        await loginClient.register(refreshToken: true);
        matrix.loginRegistrationSupported = true;
      } on MatrixException catch (e) {
        matrix.loginRegistrationSupported = e.requireAdditionalAuthentication;
      }

      if (!ssoSupported && matrix.loginRegistrationSupported == false) {
        // Server does not support SSO or registration. We can skip to login page:
        VRouter.of(context).to('login');
      } else {
        VRouter.of(context).to('connect');
      }
    } catch (e) {
      setState(() => error = (e).toLocalizedString(context));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Matrix.of(context).navigatorContext = context;
    return HomeserverPickerView(this);
  }

  Future<void> restoreBackup() async {
    final picked = await FilePicker.platform.pickFiles(withData: true);
    final file = picked?.files.firstOrNull;
    if (file == null) return;
    await showFutureLoadingDialog(
      context: context,
      future: () async {
        try {
          final client = Matrix.of(context).getLoginClient();
          await client.importDump(String.fromCharCodes(file.bytes!));
          Matrix.of(context).initMatrix();
        } catch (e, s) {
          Logs().e('Future error:', e, s);
        }
      },
    );
  }
}
