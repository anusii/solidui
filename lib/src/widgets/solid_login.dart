/// Widget for logging in a POD.
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

import 'package:solidpod/solidpod.dart'
    show
        getAppNameVersion,
        generateDefaultFolders,
        generateDefaultFiles,
        setAppDirName;
import 'package:url_launcher/url_launcher.dart';

import 'package:solidui/src/constants/solid_config.dart';
import 'package:solidui/src/models/snackbar_config.dart';
import 'package:solidui/src/widgets/solid_login_auth_handler.dart';
import 'package:solidui/src/widgets/solid_login_buttons.dart';
import 'package:solidui/src/widgets/solid_login_helper.dart';
import 'package:solidui/src/widgets/solid_login_panel.dart';

/// A widget to login to a Solid server for a user's token to access their POD.
///
/// The login screen will be the initial screen of the app when access to the
/// user's POD is required when the app requires access to the user's POD for
/// any of its functionality.

class SolidLogin extends StatefulWidget {
  /// Parameters for authenticating to the Solid server.

  const SolidLogin({
    // Include the literals here so that they are exposed through the docs.
    required this.child,
    this.required = false,
    this.appDirectory = '',
    this.image = const AssetImage(
      'assets/images/default_image.jpg',
      package: 'solidpod',
    ),
    this.logo = const AssetImage(
      'assets/images/default_logo.png',
      package: 'solidpod',
    ),
    this.title = 'Log in to your Solid Pod',
    this.webID = SolidConfig.defaultServerUrl,
    this.link = 'https://solidproject.org',
    this.continueButtonStyle = const ContinueButtonStyle(),
    this.infoButtonStyle = const InfoButtonStyle(),
    this.loginButtonStyle = const LoginButtonStyle(),
    this.registerButtonStyle = const RegisterButtonStyle(),
    this.changeKeyButtonStyle = const ChangeKeyButtonStyle(),
    this.themeConfig = const SolidLoginTheme(),
    this.snackbarConfig = const SnackbarConfig(),
    super.key,
  });

  /// The app's welcome image used as the left panel or the background.
  ///
  /// For a desktop dimensions the image is displayed as the left panel on the
  /// login screen.  For mobile dimensions (narrow screen) the image forms the
  /// background behind the Login panel.

  final AssetImage image;

  /// The style of the REGISTER button.

  final RegisterButtonStyle registerButtonStyle;

  /// The style of the LOGIN button.

  final LoginButtonStyle loginButtonStyle;

  /// The style of the INFO button.

  final InfoButtonStyle infoButtonStyle;

  /// The style of the CONTINUE button.

  final ContinueButtonStyle continueButtonStyle;

  /// The style of the CHANGE KEY button.

  final ChangeKeyButtonStyle changeKeyButtonStyle;

  /// The app's logo as displayed at the top of the login panel.

  final AssetImage logo;

  /// The login text indicating what we are loging in to.

  final String title;

  /// The URI of the user's webID used to identify the Solid server to
  /// authenticate against.

  final String webID;

  /// The URL used as the value of the Visit link. Visit the link by clicking
  /// info button.

  final String link;

  /// The child widget after logging in.

  final Widget child;

  /// The default is to require a Solid Pod authentication.
  ///
  /// If the app provides functionality that does not or does not immediately
  /// require access to Pod data then set this to false and a CONTINUE button
  /// is available on the Login page.

  final bool required;

  /// Directory name to consider when storing app data.

  final String appDirectory;

  /// Theme configuration for the login panel.

  final SolidLoginTheme themeConfig;

  /// Snackbar configuration for login notifications.

  final SnackbarConfig snackbarConfig;

  @override
  State<SolidLogin> createState() => _SolidLoginState();
}

class _SolidLoginState extends State<SolidLogin> {
  // This strings will hold the application version number and app name.
  // Initially, it's an empty string because the actual version number
  // will be obtained asynchronously from the app's package information.

  String appVersion = '';
  String appName = '';

  // Check whether the dialog was dismissed by the user.

  bool isDialogCanceled = false;

  /// Default folders will be generated after user logged in.

  List<String> defaultFolders = [];

  /// Default files will be generated after user logged in.

  Map<dynamic, dynamic> defaultFiles = {};

  // Track the current theme mode.
  // Always start with light mode regardless of system preference.

  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();

    // dc 20251022: please explain why calling an async without await.
    _initPackageInfo();
  }

  // Fetch the package information.

  Future<void> _initPackageInfo() async {
    // Check if widget is still mounted before starting any async operations.
    // This prevents unnecessary work if the widget has been disposed.

    if (!mounted) return;

    await setAppDirName(widget.appDirectory);
    final folders = await generateDefaultFolders();
    final files = await generateDefaultFiles();

    // Check if widget is still mounted after async operations and before setState.
    // This prevents "setState() called after dispose()" errors that can occur
    // if the widget was disposed while async operations were running.

    if (!mounted) return;

    setState(() {
      defaultFolders = folders;
      defaultFiles = files;
    });

    // Fetch the app information.

    final appInfo = await getAppNameVersion();

    // Check if widget is still mounted after final async operation and before setState.
    // This ensures we don't call setState on a disposed widget, which would throw
    // a FlutterError and potentially crash the app.

    if (!mounted) return;

    setState(() {
      appName = appInfo.name;
      appVersion = appInfo.version;
    });
  }

  // Function to update [_isDialogCanceled].

  void updateState() {
    if (mounted) {
      setState(() {
        isDialogCanceled = true;
      });
    }
  }

  // Helper method to create and show a snackbar with consistent theming.

  void _showSnackbar(
    String message, {
    Duration? duration,
    bool showAction = true,
  }) {
    final currentTheme = isDarkMode
        ? widget.themeConfig.darkTheme
        : widget.themeConfig.lightTheme;

    final backgroundColor = widget.snackbarConfig.backgroundColor ??
        (isDarkMode
            ? currentTheme.backgroundColor.withValues(alpha: 0.9)
            : currentTheme.backgroundColor.withValues(alpha: 0.7));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: widget.snackbarConfig.textColor != Colors.black
                ? widget.snackbarConfig.textColor
                : currentTheme.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        duration: duration ?? widget.snackbarConfig.duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            widget.snackbarConfig.borderRadius,
          ),
          side: BorderSide(color: currentTheme.dividerColor, width: 0.5),
        ),
        action: showAction
            ? SnackBarAction(
                label: 'OK',
                textColor: widget.snackbarConfig.actionTextColor != Colors.black
                    ? widget.snackbarConfig.actionTextColor
                    : currentTheme.titleColor,
                onPressed: () {},
              )
            : null,
      ),
    );
  }

  // Toggle between light and dark mode.

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use the internal state for theme instead of system brightness.

    final currentTheme = isDarkMode
        ? widget.themeConfig.darkTheme
        : widget.themeConfig.lightTheme;

    // The login box's default image Widget for the left/background panel
    // depending on screen width.

    final loginBoxDecor = BoxDecoration(
      image: DecorationImage(image: widget.image, fit: BoxFit.cover),
    );

    // Text controller for the URI of the solid server to which an authenticate
    // request is sent.

    final webIdController = TextEditingController()..text = widget.webID;

    // Build all buttons using the button builder.
    // User input from text field will override the default server URL.

    final registerButton = SolidLoginButtons.buildRegisterButton(
      style: widget.registerButtonStyle,
      onPressed: () {
        final webId = webIdController.text.trim().isNotEmpty
            ? webIdController.text.trim()
            : SolidConfig.defaultServerUrl;
        launchUrl(Uri.parse('$webId/.account/login/password/register/'));
      },
    );

    final loginButton = SolidLoginButtons.buildLoginButton(
      style: widget.loginButtonStyle,
      onPressed: () async {
        final podServer = webIdController.text.trim().isNotEmpty
            ? webIdController.text.trim()
            : SolidConfig.defaultServerUrl;

        isDialogCanceled = false;
        await SolidLoginAuthHandler.handleLogin(
          context: context,
          podServer: podServer,
          defaultFolders: defaultFolders,
          defaultFiles: defaultFiles,
          originalLoginWidget: widget,
          childWidget: widget.child,
          isDialogCanceled: isDialogCanceled,
          updateDialogCanceledState: updateState,
          showSnackbar: _showSnackbar,
        );
      },
    );

    final continueButton = SolidLoginButtons.buildContinueButton(
      style: widget.continueButtonStyle,
      onPressed: () async => await pushReplacement(context, widget.child),
    );

    final infoButton = SolidLoginButtons.buildInfoButton(
      style: widget.infoButtonStyle,
      link: widget.link,
    );

    // Build the login panel content.

    final loginPanelContent = SolidLoginPanel.buildPanelContent(
      context: context,
      logo: widget.logo,
      title: widget.title,
      appVersion: appVersion,
      webIdController: webIdController,
      loginButton: loginButton,
      registerButton: registerButton,
      continueButton: continueButton,
      infoButton: infoButton,
      isRequired: widget.required,
      currentTheme: currentTheme,
    );

    // Add theme toggle to the panel.

    final loginPanelDecor = SolidLoginPanel.buildPanelWithThemeToggle(
      panelContent: loginPanelContent,
      isDarkMode: isDarkMode,
      onThemeToggle: _toggleTheme,
    );

    // Build the complete login panel.

    final loginPanel = SolidLoginPanel.buildCompletePanel(
      context: context,
      panelDecor: loginPanelDecor,
      currentTheme: currentTheme,
    );

    // Build and return the final Scaffold.

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        behavior: HitTestBehavior.deferToChild,

        // TODO 20231228 gjw SOMEONE PLEASE EXPLAIN WHY USING A SafeArea
        // HERE. WHAT MOTIVATED ITS USE?

        child: SafeArea(
          child: DecoratedBox(
            decoration:
                isNarrowScreen(context) ? loginBoxDecor : const BoxDecoration(),
            child: Row(
              children: [
                isNarrowScreen(context)
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
    );
  }
}
