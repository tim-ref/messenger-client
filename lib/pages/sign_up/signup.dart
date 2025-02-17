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

import 'package:fluffychat/pages/sign_up/signup_view.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:vrouter/vrouter.dart';

import '../../utils/localized_exception_extension.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  SignupPageController createState() => SignupPageController();
}

class SignupPageController extends State<SignupPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String? error;
  bool loading = false;
  bool showPassword = false;
  bool noEmailWarningConfirmed = false;
  bool displaySecondPasswordField = false;

  static const int minPassLength = 8;

  void toggleShowPassword() => setState(() => showPassword = !showPassword);

  String? get domain => VRouter.of(context).queryParameters['domain'];

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void onPasswordType(String text) {
    if (text.length >= minPassLength && !displaySecondPasswordField) {
      setState(() {
        displaySecondPasswordField = true;
      });
    }
  }

  String? password1TextFieldValidator(String? value) {
    if (value!.isEmpty) {
      return L10n.of(context)!.chooseAStrongPassword;
    }
    if (value.length < minPassLength) {
      return L10n.of(context)!.pleaseChooseAtLeastChars(minPassLength.toString());
    }
    return null;
  }

  String? password2TextFieldValidator(String? value) {
    if (value!.isEmpty) {
      return L10n.of(context)!.repeatPassword;
    }
    if (value != passwordController.text) {
      return L10n.of(context)!.passwordsDoNotMatch;
    }
    return null;
  }

  String? emailTextFieldValidator(String? value) {
    if (value!.isEmpty && !noEmailWarningConfirmed) {
      noEmailWarningConfirmed = true;
      return L10n.of(context)!.noEmailWarning;
    }
    if (value.isNotEmpty && !value.contains('@')) {
      return L10n.of(context)!.pleaseEnterValidEmail;
    }
    return null;
  }

  void signup([_]) async {
    setState(() {
      error = null;
    });
    if (!formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      final matrix = Matrix.of(context);
      final client = matrix.getLoginClient();
      final email = emailController.text;
      if (email.isNotEmpty) {
        matrix.currentClientSecret = DateTime.now().millisecondsSinceEpoch.toString();
        matrix.currentThreepidCreds = await client.requestTokenToRegisterEmail(
          matrix.currentClientSecret,
          email,
          0,
        );
      }

      final displayname = matrix.loginUsername!;
      final localPart = displayname.toLowerCase().replaceAll(' ', '_');

      await client.uiaRequestBackground(
        (auth) => client.register(
          username: localPart,
          password: passwordController.text,
          initialDeviceDisplayName: PlatformInfos.clientName,
          refreshToken: true,
          auth: auth,
        ),
      );
      // Set displayname
      if (displayname != localPart) {
        await client.setDisplayName(
          client.userID!,
          displayname,
        );
      }
    } catch (e) {
      error = (e).toLocalizedString(context);
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => SignupPageView(this);
}
