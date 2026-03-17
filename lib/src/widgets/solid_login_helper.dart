/// Helper utilities for SolidLogin widget.
///
/// Copyright (C) 2024-2025, Software Innovation Institute, ANU.
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

import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';

// Screen size support functions to identify narrow and very narrow screens. The
// width dictates whether the Login panel is laid out on the right with the app
// image on the left, or is on top of the app image.

const int narrowScreenLimit = 1175;
const int veryNarrowScreenLimit = 750;

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

bool isNarrowScreen(BuildContext context) =>
    screenWidth(context) < narrowScreenLimit;

bool isVeryNarrowScreen(BuildContext context) =>
    screenWidth(context) < veryNarrowScreenLimit;

/// Button styles used in the Solid Login widget.

// Colours for highlighted buttons.
//
// Do these need to be highligheted. By default the package should not highlight
// them but if an app developer wants to then we should support that. (gjw
// 20250422)
//
// The original alternatives were Color(0xFF00BCD4) and Colors.white for
// register and Color(0xFF4CAF50) abd Colors.white for login. I find the colours
// a bit distracting as a user. (gjw 20250422)

const Color defaultButtonBackground = Colors.white;
const Color defaultButtonForeground = Colors.black;

const Color registerButtonBackground = defaultButtonBackground;
const Color registerButtonForeground = defaultButtonForeground;
const Color loginButtonBackground = Colors.lightGreenAccent;
const Color loginButtonForeground = defaultButtonForeground;

const String defaultLoginButtonText = 'Login';
const String defaultRegisterButtonText = 'Register';
const String defaultInfoButtonText = 'Info';
const String defaultContinueButtonText = 'Continue';
const String defaultChangeKeyButtonText = 'Change Key';

const String defaultServerTooltip = '''

**Solid Server:** This text field contains the Solid server you will connect to
where your data is hosted. It is also used as the base of the URI (Uniform
Resource Identifier) that will be used for your WebID. A WebID is a
decentralised identity that allows you to have a globally unique identifier for
your data store.

''';

const String defaultLoginTooltip = '''

**Login:** Tap here to log in to a Solid server of your choice to access your
private data. Through a browser popup you will be connected to the specified
Solid server and you can then log in with your username and password. This app
does not need to know your username/password. The app will use a token from the
server to establish your secure conenction.

''';
const String defaultRegisterTooltip = '''

**Register:** Tap here to connect to your Solid server of choice to register for
an account. Once you have an account on any Solid server of choice you will be
able to save data onto your Data Vault on that server. Many Solid servers are
available, or you can host your own free community supported server. There are
freely available servers, commercial servers, and government run servers
available. See https://solidproject.org/get_a_pod for some available Solid
servers.

''';

const String defaultInfoTooltip = '''

**Support:** Tap here to be taken to the app help and support documentation. The
actual help page navigated to on your browser depends on the particular app.

''';

const String defaultContinueTooltip = '''

**Continue:** Tap here to continue to the app using your previously cached
login session. This button is only available when a cached session exists. If
you need to log in with a different WebID, use the Login button instead.

''';

class PodButton extends StatelessWidget {
  const PodButton({
    required this.text,
    required this.background,
    required this.foreground,
    required this.tooltip,
    required this.onPressed,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });
  final String text;
  final Color background;
  final Color foreground;
  final String tooltip;
  final VoidCallback? onPressed;

  /// Optional focus node for controlling keyboard focus.

  final FocusNode? focusNode;

  /// Whether this button should be focused automatically when the widget is
  /// first displayed. Defaults to false.

  final bool autofocus;

  // Define a common style for the text of the two buttons, GET POD and LOGIN.

  final buttonTextStyle = const TextStyle(
    fontSize: 16.0,
    letterSpacing: 2.0,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return MarkdownTooltip(
      message: tooltip,
      child: ElevatedButton(
        focusNode: focusNode,
        autofocus: autofocus,
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,

          // Add a solid border to make buttons more visible.
          side: BorderSide(color: Colors.grey.shade400),

          // Apply rounded corners consistent with card style.
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),

          // Increase vertical padding.
          padding: const EdgeInsets.symmetric(vertical: 12),

          // Ensure a minimum size of 48px in height as per guidelines.
          minimumSize: const Size(88, 48),
        ),
        child: Text(text, style: buttonTextStyle),
      ),
    );
  }
}

class ContinueButtonStyle {
  const ContinueButtonStyle({
    this.text = defaultContinueButtonText,
    this.background = defaultButtonBackground,
    this.foreground = defaultButtonForeground,
    this.tooltip = defaultContinueTooltip,
  });
  final String text;
  final Color background;
  final Color foreground;
  final String tooltip;
}

class ChangeKeyButtonStyle {
  const ChangeKeyButtonStyle({
    this.text = defaultChangeKeyButtonText,
    this.background = defaultButtonBackground,
    this.foreground = defaultButtonForeground,
  });
  final String text;
  final Color background;
  final Color foreground;
}

class LoginButtonStyle {
  const LoginButtonStyle({
    this.text = defaultLoginButtonText,
    this.background = loginButtonBackground,
    this.foreground = loginButtonForeground,
    this.tooltip = defaultLoginTooltip,
  });
  final String text;
  final Color background;
  final Color foreground;
  final String tooltip;
}

class RegisterButtonStyle {
  const RegisterButtonStyle({
    this.text = defaultRegisterButtonText,
    this.background = registerButtonBackground,
    this.foreground = registerButtonForeground,
    this.tooltip = defaultRegisterTooltip,
  });
  final String text;
  final Color background;
  final Color foreground;
  final String tooltip;
}

class InfoButtonStyle {
  const InfoButtonStyle({
    this.text = defaultInfoButtonText,
    this.background = defaultButtonBackground,
    this.foreground = defaultButtonForeground,
    this.tooltip = defaultInfoTooltip,
  });
  final String text;
  final Color background;
  final Color foreground;
  final String tooltip;
}

/// Theme configuration for a single mode (light or dark).

class SolidLoginThemeMode {
  const SolidLoginThemeMode({
    this.backgroundColor = Colors.white,
    this.cardColor = Colors.white,
    this.shadowColor = Colors.black45,
    this.titleColor = Colors.black,
    this.textColor = Colors.black,
    this.hintColor = Colors.grey,
    this.dividerColor = Colors.grey,
    this.inputBorderColor = Colors.grey,
    this.versionTextColor = Colors.grey,
  });

  /// Background color of the login panel.

  final Color backgroundColor;

  /// Card color for the login panel.

  final Color cardColor;

  /// Shadow color for the login panel card.

  final Color shadowColor;

  /// Color for the title text.

  final Color titleColor;

  /// Color for regular text.

  final Color textColor;

  /// Color for hint text in input fields.

  final Color hintColor;

  /// Color for dividers
  final Color dividerColor;

  /// Color for input field borders.

  final Color inputBorderColor;

  /// Color for the version text.

  final Color versionTextColor;
}

/// Theme configuration for the SolidLogin widget.

class SolidLoginTheme {
  const SolidLoginTheme({
    this.lightTheme = const SolidLoginThemeMode(),
    this.darkTheme = const SolidLoginThemeMode(
      backgroundColor: Color(0xFF121212),
      cardColor: Color(0xFF1E1E1E),
      shadowColor: Colors.black87,
      titleColor: Colors.white,
      textColor: Colors.white,
      hintColor: Color(0xFF9E9E9E),
      dividerColor: Color(0xFF616161),
      inputBorderColor: Color(0xFF757575),
      versionTextColor: Color(0xFF9E9E9E),
    ),
  });

  /// Theme configuration for light mode.

  final SolidLoginThemeMode lightTheme;

  /// Theme configuration for dark mode.

  final SolidLoginThemeMode darkTheme;
}

/// Return a [MarkdownTooltip] for Solid server text input

MarkdownTooltip getSolidServerTooltip(
  TextEditingController webIdController,
  SolidLoginThemeMode themeMode, {
  FocusNode? focusNode,
  ValueChanged<String>? onFieldSubmitted,
}) =>
    MarkdownTooltip(
      message: defaultServerTooltip,
      child: TextFormField(
        controller: webIdController,
        focusNode: focusNode,
        textInputAction: TextInputAction.go,
        onFieldSubmitted: onFieldSubmitted,
        style: TextStyle(color: themeMode.textColor, fontSize: 16),
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: 'Solid Server',
          labelStyle: TextStyle(color: themeMode.hintColor, fontSize: 16),
          floatingLabelStyle: TextStyle(color: themeMode.textColor),
          hintText: 'Solid server URL (or WebID)',
          hintStyle: TextStyle(color: themeMode.hintColor, fontSize: 16),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: themeMode.inputBorderColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: themeMode.inputBorderColor, width: 2),
          ),
        ),
      ),
    );

/// Return a [Widget] for the theme toggle button with adaptive toggle logic.
/// Uses MediaQuery for real-time system brightness detection.

Widget getThemeToggleTooltip(
  ThemeMode currentThemeMode, {
  required void Function() onPressed,
}) {
  return Builder(
    builder: (context) {
      // Get the next mode based on current mode and system brightness.

      final ThemeMode nextMode;
      switch (currentThemeMode) {
        case ThemeMode.system:
          // Use MediaQuery for real-time system brightness detection.

          final systemBrightness = MediaQuery.platformBrightnessOf(context);
          nextMode = systemBrightness == Brightness.light
              ? ThemeMode.dark
              : ThemeMode.light;
          break;
        case ThemeMode.light:
        case ThemeMode.dark:
          // Return to System mode.

          nextMode = ThemeMode.system;
          break;
      }

      // Get the icon for the next mode.

      final IconData icon;
      final Color iconColor;
      final String tooltipMessage;

      switch (nextMode) {
        case ThemeMode.light:
          icon = Icons.wb_sunny_outlined;
          iconColor = Colors.amber;
          tooltipMessage = 'Switch to Light Mode';
          break;
        case ThemeMode.dark:
          icon = Icons.dark_mode;
          iconColor = Colors.blueGrey;
          tooltipMessage = 'Switch to Dark Mode';
          break;
        case ThemeMode.system:
          // Show icon based on current system theme.

          final systemBrightness = MediaQuery.platformBrightnessOf(context);
          if (systemBrightness == Brightness.light) {
            icon = Icons.wb_sunny_outlined;
            iconColor = Colors.amber;
          } else {
            icon = Icons.dark_mode;
            iconColor = Colors.blueGrey;
          }
          tooltipMessage = 'Switch to System Mode';
          break;
      }

      return MarkdownTooltip(
        message: tooltipMessage,
        child: IconButton(
          icon: Icon(icon, color: iconColor),
          onPressed: onPressed,
        ),
      );
    },
  );
}

/// Utility function for navigation

Future<void> pushReplacement(
  BuildContext context,
  Widget destinationWidget,
) async {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => destinationWidget),
    (Route<dynamic> route) =>
        false, // This predicate ensures all previous routes are removed
  );
}
