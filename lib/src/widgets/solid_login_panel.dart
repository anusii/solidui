/// Login panel builder for Solid login screen.
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
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
/// Authors: Graham Williams, Anushka Vidanage, Ashley Tang, Dawei Chen, Tony
/// Chen

library;

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:solidui/src/widgets/solid_login_helper.dart';

/// Builder class for creating the login panel UI.

class SolidLoginPanel {
  /// Builds the login panel content with logo, title, and buttons.

  static Widget buildPanelContent({
    required BuildContext context,
    required AssetImage logo,
    required String title,
    required String appVersion,
    required TextEditingController webIdController,
    required Widget loginButton,
    required Widget registerButton,
    required Widget continueButton,
    required Widget infoButton,
    required bool isRequired,
    required SolidLoginThemeMode currentTheme,
    FocusNode? serverInputFocusNode,
  }) {
    const boxTextHeight = 20.0;

    return Container(
      height: 650,
      padding: const EdgeInsets.all(30),
      color: currentTheme.backgroundColor,
      child: Column(
        children: [
          Image(image: logo, width: 200),
          const SizedBox(height: 0.0),
          Divider(height: 15, thickness: 2, color: currentTheme.dividerColor),
          const SizedBox(height: 50.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: currentTheme.titleColor,
            ),
          ),
          const SizedBox(height: 20.0),
          FocusTraversalOrder(
            order: const NumericFocusOrder(5),
            child: getSolidServerTooltip(
              webIdController,
              currentTheme,
              focusNode: serverInputFocusNode,
            ),
          ),
          const SizedBox(height: 20.0),

          // Column of buttons.
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: loginButton),
                  const SizedBox(width: 15.0),
                  Expanded(child: isRequired ? registerButton : continueButton),
                ],
              ),
              const SizedBox(height: 15.0),
              Row(
                children: [
                  if (!isRequired) Expanded(child: registerButton),
                  if (isRequired)
                    Expanded(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: infoButton,
                      ),
                    ),
                  const SizedBox(width: 15.0),
                  isRequired ? const Spacer() : Expanded(child: infoButton),
                ],
              ),
              const SizedBox(height: 15.0),
            ],
          ),

          const SizedBox(height: 20.0),

          // Expand to the bottom of the login panel.
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: boxTextHeight,
                child: Center(
                  child: SelectableText(
                    'Version $appVersion',
                    style: TextStyle(color: currentTheme.versionTextColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the login panel with theme toggle.

  static Widget buildPanelWithThemeToggle({
    required Widget panelContent,
    required ThemeMode currentThemeMode,
    required VoidCallback onThemeToggle,
  }) {
    return Stack(
      children: [
        panelContent,
        Positioned(
          top: 10,
          right: 10,
          child: getThemeToggleTooltip(
            currentThemeMode,
            onPressed: onThemeToggle,
          ),
        ),
      ],
    );
  }

  /// Builds the complete login panel with card decoration.

  static Widget buildCompletePanel({
    required BuildContext context,
    required Widget panelDecor,
    required SolidLoginThemeMode currentTheme,
  }) {
    final loginPanelInset =
        (isVeryNarrowScreen(context) || !isNarrowScreen(context)) ? 0.05 : 0.25;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: loginPanelInset * screenWidth(context),
      ),
      child: SingleChildScrollView(
        child: Card(
          elevation: 50,
          color: currentTheme.cardColor,
          shadowColor: currentTheme.shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: panelDecor,
        ),
      ),
    );
  }
}
