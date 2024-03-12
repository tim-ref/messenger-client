/*
 * Modified by akquinet GmbH on 16.02.2024
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';

abstract class PlatformInfos {
  static bool get isWeb => kIsWeb;

  static bool get isLinux => !kIsWeb && Platform.isLinux;

  static bool get isWindows => !kIsWeb && Platform.isWindows;

  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  static bool get isIOS => !kIsWeb && Platform.isIOS;

  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  static bool get isCupertinoStyle => isIOS || isMacOS;

  static bool get isMobile => isAndroid || isIOS;

  /// For desktops which don't support ChachedNetworkImage yet
  static bool get isBetaDesktop => isWindows || isLinux;

  static bool get isDesktop => isLinux || isWindows || isMacOS;

  static bool get usesTouchscreen => !isMobile;

  static bool get platformCanRecord => (isMobile || isMacOS);

  static String get clientName =>
      '${AppConfig.applicationName} ${isWeb ? 'web' : Platform.operatingSystem}${kReleaseMode ? '' : 'Debug'}';

  static Future<String> getVersion() async {
    var version = kIsWeb ? 'Web' : 'Unknown';
    try {
      version = (await PackageInfo.fromPlatform()).version;
    } catch (_) {}
    return version;
  }

  static void showLicenseDialog(BuildContext context) async {
    const buttonHeight = 35.0;
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actionsPadding: const EdgeInsets.all(8),
        actions: [
          SizedBox(
            height: buttonHeight,
            child: TextButton(
              child: const Text("close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
        content: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TI-Messenger Referenzumgebung - Client',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Version ${packageInfo.version}\n',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    const TextSpan(
                      text:
                          "This Messenger Client of the TIM reference implementation (''Messenger Client'') is licensed under version 3 of the GNU Affero General Public License and other licenses. The implementation is based on",
                    ),
                    TextSpan(
                      text: ' FluffyChat ',
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          await launchUrl(
                            Uri.parse(
                              'https://github.com/krille-chan/fluffychat',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                    ),
                    const TextSpan(text: 'and on the'),
                    TextSpan(
                      text: ' Matrix DART SDK ',
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          await launchUrl(
                            Uri.parse(
                              'https://github.com/famedly/matrix-dart-sdk',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                    ),
                    const TextSpan(
                      text:
                          'by Famedly GmbH.\n\nYou may convey this Messenger Client under the terms of the version 3 of the GNU Affero General Public License, available from the URL',
                    ),
                    TextSpan(
                      text:
                          ' https://github.com/tim-ref/messenger-client/blob/main/LICENSE',
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          await launchUrl(
                            Uri.parse(
                              'https://github.com/tim-ref/messenger-client/blob/main/LICENSE',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                    ),
                    const TextSpan(
                      text:
                          '.\n\nThis Messenger Client is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.\n\nFurther third-party libraries and the underlying license information are available from the URL',
                    ),
                    TextSpan(
                      text:
                          ' https://github.com/tim-ref/messenger-client-dependencies',
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          await launchUrl(
                            Uri.parse(
                              'https://github.com/tim-ref/messenger-client-dependencies',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                    ),
                    const TextSpan(
                      text:
                      '.',
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: buttonHeight,
                child: TextButton(
                  onPressed: () async => await launchUrl(
                    Uri.parse(
                      'https://github.com/krille-chan/fluffychat/tree/9138e164f98002f4b7fcb25674d63b74d90713ec',
                    ),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('Original fork'),
                ),
              ),
              SizedBox(
                height: buttonHeight,
                child: TextButton(
                  onPressed: () async => await launchUrl(
                    Uri.parse(
                      'https://github.com/tim-ref/messenger-client/blob/main/LICENSE',
                    ),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('License'),
                ),
              ),
              SizedBox(
                height: buttonHeight,
                child: TextButton(
                  onPressed: () async => await launchUrl(
                    Uri.parse(
                      'https://github.com/tim-ref/messenger-client',
                    ),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('Source code repository'),
                ),
              ),
              SizedBox(
                height: buttonHeight,
                child: TextButton(
                  onPressed: () async => await launchUrl(
                    Uri.parse(
                      'https://github.com/tim-ref/messenger-client/tree/v1.18.0',
                    ),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('Source code'),
                ),
              ),
              SizedBox(
                height: buttonHeight,
                child: TextButton(
                  onPressed: () async => await launchUrl(
                    Uri.parse(
                      'https://github.com/tim-ref/messenger-client-dependencies/',
                    ),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('Third-party libraries repository'),
                ),
              ),
              SizedBox(
                height: buttonHeight,
                child: TextButton(
                  onPressed: () async => await launchUrl(
                    Uri.parse(
                      'https://github.com/tim-ref/messenger-client-dependencies/tree/v1.18.0',
                    ),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('Third-party libraries'),
                ),
              ),
              SizedBox(
                height: buttonHeight,
                child: TextButton(
                  onPressed: () async => await launchUrl(
                    Uri.parse(
                      'https://github.com/googlefonts/noto-emoji/',
                    ),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('Noto Emoji'),
                ),
              ),
              SizedBox(
                height: buttonHeight,
                child: TextButton(
                  onPressed: () async => await launchUrl(
                    Uri.parse(
                      'https://akquinet.com/impressum.html',
                    ),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('Imprint'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
