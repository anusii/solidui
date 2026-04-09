/// Build helper for SolidLogin widget.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
///
/// Licensed under the MIT License (the "License").
///
/// License: https://choosealicense.com/licenses/mit/.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
///
/// Authors: Graham Williams, Anushka Vidanage, Ashley Tang, Dawei Chen, Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:solidui/src/constants/solid_config.dart';
import 'package:solidui/src/widgets/solid_login_buttons.dart';
import 'package:solidui/src/widgets/solid_login_helper.dart';

/// Helper class for building SolidLogin UI components.

class SolidLoginBuildHelper {
  /// Builds the register button.

  static Widget buildRegisterButton({
    required RegisterButtonStyle style,
    required TextEditingController webIdController,
    required FocusNode focusNode,
  }) {
    if (!style.visible) return const SizedBox.shrink();
    return FocusTraversalOrder(
      order: const NumericFocusOrder(3),
      child: SolidLoginButtons.buildRegisterButton(
        style: style,
        onPressed: () {
          final webId = webIdController.text.trim().isNotEmpty
              ? webIdController.text.trim()
              : SolidConfig.defaultServerUrl;
          launchUrl(Uri.parse('$webId/.account/login/password/register/'));
        },
        focusNode: focusNode,
      ),
    );
  }

  /// Builds the login button.

  static Widget buildLoginButton({
    required BuildContext context,
    required LoginButtonStyle style,
    required Future<void> Function() performLogin,
    required FocusNode focusNode,
  }) {
    return FocusTraversalOrder(
      order: const NumericFocusOrder(1),
      child: SolidLoginButtons.buildLoginButton(
        style: style,
        onPressed: performLogin,
        focusNode: focusNode,
        autofocus: true,
      ),
    );
  }

  /// Builds the continue button.

  static Widget buildContinueButton({
    required BuildContext context,
    required ContinueButtonStyle style,
    required Future<void> Function() performContinue,
    required FocusNode focusNode,
  }) {
    return FocusTraversalOrder(
      order: const NumericFocusOrder(2),
      child: SolidLoginButtons.buildContinueButton(
        style: style,
        onPressed: performContinue,
        focusNode: focusNode,
      ),
    );
  }

  /// Builds the info button.

  static Widget buildInfoButton({
    required InfoButtonStyle style,
    required String link,
    required FocusNode focusNode,
  }) {
    if (!style.visible) return const SizedBox.shrink();
    return FocusTraversalOrder(
      order: const NumericFocusOrder(4),
      child: SolidLoginButtons.buildInfoButton(
        style: style,
        link: link,
        focusNode: focusNode,
      ),
    );
  }

  /// Builds the login body scaffold.

  static Widget buildScaffold({
    required BuildContext context,
    required BoxDecoration loginBoxDecor,
    required Widget loginPanel,
  }) {
    return Scaffold(
      body: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          behavior: HitTestBehavior.deferToChild,
          child: SafeArea(
            child: DecoratedBox(
              decoration: isNarrowLoginScreen(context)
                  ? loginBoxDecor
                  : const BoxDecoration(),
              child: Row(
                children: [
                  isNarrowLoginScreen(context)
                      ? Container()
                      : Expanded(
                          flex: 7,
                          child: Container(decoration: loginBoxDecor),
                        ),
                  Expanded(flex: 5, child: loginPanel),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
