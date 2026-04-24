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
        generateCustomFolders,
        setAppDirName;

import 'package:solidui/src/constants/solid_config.dart';
import 'package:solidui/src/handlers/solid_auth_handler.dart';
import 'package:solidui/src/models/snackbar_config.dart';
import 'package:solidui/src/widgets/solid_login_asset_helper.dart';
import 'package:solidui/src/widgets/solid_login_build_helper.dart';
import 'package:solidui/src/widgets/solid_login_helper.dart';
import 'package:solidui/src/widgets/solid_login_panel.dart';
import 'package:solidui/src/widgets/solid_login_snackbar_helper.dart';
import 'package:solidui/src/widgets/solid_login_theme_helper.dart';
import 'package:solidui/src/widgets/solid_theme_notifier.dart';

/// A widget to login to a Solid server for a user's token to access their POD.

class SolidLogin extends StatefulWidget {
  const SolidLogin({
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
    this.customFolderPathList = const [],
    super.key,
  });

  /// The app's welcome image used as the left panel or the background, and
  /// the app's logo as displayed at the top of the login panel.

  final AssetImage image, logo;

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

  /// The login text indicating what we are loging in to, the URI of the
  /// user's webID used to identify the Solid server to authenticate against,
  /// and the URL used as the value of the Visit link. Visit the link by
  /// clicking info button.

  final String title, webID, link;

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

  /// Custom list of folders to be created inside the data folder.

  final List customFolderPathList;

  @override
  State<SolidLogin> createState() => _SolidLoginState();
}

class _SolidLoginState extends State<SolidLogin> with WidgetsBindingObserver {
  /// The app version and the app name.

  String appVersion = '', appName = '';

  /// Check whether the dialog was dismissed by the user.

  bool isDialogCanceled = false;

  /// Default folders will be generated after user logged in.

  List<String> defaultFolders = [];

  /// Default files will be generated after user logged in.

  Map<dynamic, dynamic> defaultFiles = {};

  // Focus nodes for keyboard navigation.

  late final FocusNode _loginFocusNode, _continueFocusNode;
  late final FocusNode _registerFocusNode,
      _infoFocusNode,
      _serverInputFocusNode;

  /// The resolved background image after checking available assets.

  AssetImage? _resolvedImage;

  /// The resolved logo image after checking available assets.

  AssetImage? _resolvedLogo;

  /// Whether asset resolution has completed.

  bool _assetsResolved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    solidThemeNotifier.addListener(_onThemeChanged);

    // Initialise focus nodes for keyboard navigation.

    _loginFocusNode = FocusNode(debugLabel: 'loginButton');
    _continueFocusNode = FocusNode(debugLabel: 'continueButton');
    _registerFocusNode = FocusNode(debugLabel: 'registerButton');
    _infoFocusNode = FocusNode(debugLabel: 'infoButton');
    _serverInputFocusNode = FocusNode(debugLabel: 'serverInput');

    // Resolve image assets with fallback logic.
    _resolveImageAssets();

    // dc 20251022: please explain why calling an async without await.

    _initPackageInfo();

    // Auto-configure SolidAuthHandler with this login's settings.
    // This ensures re-login from within the app uses the same configuration.

    SolidAuthHandler.instance.autoConfigureFromLogin(
      title: widget.title,
      appDirectory: widget.appDirectory,
      webId: widget.webID,
      image: widget.image,
      logo: widget.logo,
      link: widget.link,
      child: widget.child,
    );
  }

  /// Resolves the image and logo assets with fallback logic.
  ///
  /// For each asset (image and logo), the resolution order is:
  /// 1. Try the user-specified path from widget.image/widget.logo
  /// 2. If not found, try the alternate extension (png->jpg or jpg->png)
  /// 3. If none exist, fall back to solidui package defaults

  Future<void> _resolveImageAssets() async {
    _resolvedImage = await SolidLoginAssetHelper.resolveAssetWithFallback(
      widget.image,
      'app_image',
    );
    _resolvedLogo = await SolidLoginAssetHelper.resolveAssetWithFallback(
      widget.logo,
      'app_icon',
    );
    if (mounted) setState(() => _assetsResolved = true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    solidThemeNotifier.removeListener(_onThemeChanged);

    // Dispose focus nodes to avoid memory leaks.

    _loginFocusNode.dispose();
    _continueFocusNode.dispose();
    _registerFocusNode.dispose();
    _infoFocusNode.dispose();
    _serverInputFocusNode.dispose();

    super.dispose();
  }

  /// Called when the platform brightness changes.
  /// Triggers a rebuild to update the theme when in system mode.

  @override
  void didChangePlatformBrightness() {
    if (mounted && solidThemeNotifier.themeMode == ThemeMode.system) {
      setState(() {});
    }
  }

  /// Callback when theme notifier changes.

  void _onThemeChanged() => mounted ? setState(() {}) : null;
  bool get isDarkMode => SolidLoginThemeHelper.isDarkMode(context);

  Future<void> _initPackageInfo() async {
    if (!mounted) return;

    // Start fetching app info immediately — it is independent of appDirName.
    final appInfoFuture = getAppNameVersion();

    // Directory name setting must precede folder/file generation.
    await setAppDirName(widget.appDirectory);

    // Parallelize folders and files generation along with the app info future.
    final foldersFuture = generateDefaultFolders();
    final filesFuture = generateDefaultFiles();

    // Await all futures in parallel. Using Future.wait<void> allows us to
    // access the typed results directly from the futures afterwards,
    // avoiding the need for brittle positional index casting.
    await Future.wait<void>([foldersFuture, filesFuture, appInfoFuture]);

    final folders = await foldersFuture;
    final files = await filesFuture;
    final appInfo = await appInfoFuture;

    final customFolders = generateCustomFolders(widget.customFolderPathList);

    if (!mounted) return;

    // Single setState: consolidates all derived data updates and avoids
    // multiple widget rebuilds.
    setState(() {
      defaultFolders = folders + customFolders;
      defaultFiles = files;
      appName = appInfo.name;
      appVersion = appInfo.version;
    });
  }

  // Function to update [_isDialogCanceled].

  void updateState() {
    if (mounted) setState(() => isDialogCanceled = true);
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
    SolidLoginSnackbarHelper.showSnackbar(
      context,
      message: message,
      isDarkMode: isDarkMode,
      currentTheme: currentTheme,
      snackbarConfig: widget.snackbarConfig,
      duration: duration,
      showAction: showAction,
    );
  }

  void _toggleTheme() => solidThemeNotifier.toggleTheme();

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator whilst assets are being resolved.

    if (!_assetsResolved) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Use the internal state for theme instead of system brightness.

    final currentTheme = isDarkMode
        ? widget.themeConfig.darkTheme
        : widget.themeConfig.lightTheme;

    // Use resolved image with fallback support.

    final effectiveImage = _resolvedImage ?? SolidConfig.soliduiDefaultImage;

    // The login box's default image Widget for the left/background panel
    // depending on screen width.

    final loginBoxDecor = BoxDecoration(
      image: DecorationImage(image: effectiveImage, fit: BoxFit.cover),
    );
    final webIdController = TextEditingController()..text = widget.webID;

    final registerButton = SolidLoginBuildHelper.buildRegisterButton(
      style: widget.registerButtonStyle,
      webIdController: webIdController,
      focusNode: _registerFocusNode,
    );

    final loginButton = SolidLoginBuildHelper.buildLoginButton(
      context: context,
      style: widget.loginButtonStyle,
      webIdController: webIdController,
      defaultFolders: defaultFolders,
      defaultFiles: defaultFiles,
      originalWidget: widget,
      childWidget: widget.child,
      getIsDialogCanceled: () => isDialogCanceled,
      updateDialogCanceledState: updateState,
      showSnackbar: _showSnackbar,
      focusNode: _loginFocusNode,
    );

    final continueButton = SolidLoginBuildHelper.buildContinueButton(
      context: context,
      style: widget.continueButtonStyle,
      childWidget: widget.child,
      focusNode: _continueFocusNode,
    );

    final infoButton = SolidLoginBuildHelper.buildInfoButton(
      style: widget.infoButtonStyle,
      link: widget.link,
      focusNode: _infoFocusNode,
    );

    // Use resolved logo with fallback support.

    final effectiveLogo = _resolvedLogo ?? SolidConfig.soliduiDefaultLogo;

    // Build the login panel content.

    final loginPanelContent = SolidLoginPanel.buildPanelContent(
      context: context,
      logo: effectiveLogo,
      title: widget.title,
      appVersion: appVersion,
      webIdController: webIdController,
      loginButton: loginButton,
      registerButton: registerButton,
      continueButton: continueButton,
      infoButton: infoButton,
      isRequired: widget.required,
      currentTheme: currentTheme,
      serverInputFocusNode: _serverInputFocusNode,
    );

    final loginPanelDecor = SolidLoginPanel.buildPanelWithThemeToggle(
      panelContent: loginPanelContent,
      currentThemeMode: solidThemeNotifier.themeMode,
      onThemeToggle: _toggleTheme,
    );

    final loginPanel = SolidLoginPanel.buildCompletePanel(
      context: context,
      panelDecor: loginPanelDecor,
      currentTheme: currentTheme,
    );

    return SolidLoginBuildHelper.buildScaffold(
      context: context,
      loginBoxDecor: loginBoxDecor,
      loginPanel: loginPanel,
    );
  }
}
