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

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';

import 'package:solidui/src/constants/solid_config.dart';
import 'package:solidui/src/widgets/create_account_dialog.dart';
import 'package:solidui/src/widgets/solid_login_buttons.dart';
import 'package:solidui/src/widgets/solid_login_helper.dart';

/// Helper class for building SolidLogin UI components.

class SolidLoginBuildHelper {
  /// Builds the register button.

  static Widget buildRegisterButton({
    required BuildContext context,
    required RegisterButtonStyle style,
    required TextEditingController webIdController,
    required FocusNode focusNode,
    required Widget child,
  }) {
    if (!style.visible) return const SizedBox.shrink();
    return FocusTraversalOrder(
      order: const NumericFocusOrder(3),
      child: SolidLoginButtons.buildRegisterButton(
        style: style,
        onPressed: () {
          final serverUrl = webIdController.text.trim().isNotEmpty
              ? webIdController.text.trim()
              : SolidConfig.defaultServerUrl;
          unawaited(createAccountPopup(context, child, serverUrl: serverUrl));
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
    if (!style.visible) return const SizedBox.shrink();
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
    if (!style.visible) return const SizedBox.shrink();
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

  /// Builds the "Stay signed in" checkbox row.
  ///
  /// [onChanged] receives the new value when either the checkbox or its label
  /// is tapped, leaving persistence and state updates to the caller.

  static Widget buildStaySignedInCheckbox({
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        MarkdownTooltip(
          message:
              '**Stay signed in**\n\nWhen ticked, your login session will be '
              'cached so you can skip the browser login next time. '
              'Untick to require a fresh login on every launch.',
          child: SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? true),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Text(
            'Stay signed in',
            style: TextStyle(color: textColor, fontSize: 14),
          ),
        ),
      ],
    );
  }

  /// Builds the "Try another WebID" text button.

  static Widget buildTryAnotherAccountButton({
    required VoidCallback onPressed,
    required Color textColor,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        'Try another WebID',
        style: TextStyle(
          color: textColor.withValues(alpha: 0.7),
          fontSize: 14,
          decoration: TextDecoration.underline,
        ),
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
