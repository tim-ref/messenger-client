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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';
import 'package:universal_html/html.dart' as html_dart;
import 'package:vrouter/vrouter.dart';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/widgets/matrix.dart';

class InAppSsoAuth extends StatefulWidget {
  const InAppSsoAuth({super.key});

  @override
  InAppSsoAuthState createState() => InAppSsoAuthState();
}

class InAppSsoAuthState extends State<InAppSsoAuth> {
  InAppWebViewController? webViewController;
  final blankPageHtml = """<html><body style="background-color:#ffffff;"></body></html>""";

  String get userId => VRouter.of(context).pathParameters['ssoProviderId']!;

  @override
  Widget build(BuildContext context) {
    final bool isDefaultPlatform =
        (PlatformInfos.isMobile || PlatformInfos.isWeb || PlatformInfos.isMacOS);
    final id = userId;
    final redirectUrl = kIsWeb
        ? '${html_dart.window.origin!}/auth.html'
        : isDefaultPlatform
            ? '${AppConfig.appOpenUrlScheme.toLowerCase()}://login'
            : 'http://localhost:3001//login';
    final url = '${Matrix.of(context).getLoginClient().homeserver?.toString()}'
        '/_matrix/client/v3/login/sso/redirect/${Uri.encodeComponent(id)}'
        '?redirectUrl=${Uri.encodeQueryComponent(redirectUrl)}';

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          Matrix.of(context).getLoginClient().homeserver?.host ?? '',
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.tryParse(url)),
        onLoadStop: (controller, url) {
          if (url.toString().startsWith("im.fluffychat://login")) {
            ssoLoginAction(url);
            webViewController?.loadData(data: blankPageHtml);
          }
        },
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
      ),
    );
  }

  void ssoLoginAction(Uri? redirectUrl) async {
    final token = redirectUrl?.queryParameters['loginToken'];
    if (token?.isEmpty ?? false) return;

    await showFutureLoadingDialog(
      context: context,
      future: () => Matrix.of(context).getLoginClient().login(
            LoginType.mLoginToken,
            token: token,
            initialDeviceDisplayName: PlatformInfos.clientName,
            refreshToken: true,
          ),
    );
  }
}
