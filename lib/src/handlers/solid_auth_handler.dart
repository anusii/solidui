/// Solid Authentication Handler.
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
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart' show getWebId;

import 'package:solidui/src/constants/solid_config.dart';
import 'package:solidui/src/models/snackbar_config.dart';
import 'package:solidui/src/services/solid_security_key_notifier.dart';
import 'package:solidui/src/widgets/solid_default_login.dart';
import 'package:solidui/src/widgets/solid_login_helper.dart';
import 'package:solidui/src/widgets/solid_logout_dialog.dart' show logoutPopup;

/// Configuration for Solid authentication handling.

class SolidAuthConfig {
  /// The widget to return to after successful logout.

  final Widget? returnTo;

  /// Custom login page builder function.
  /// If null, uses the default login page.

  final Widget Function(BuildContext context)? loginPageBuilder;

  /// Default server URL for login.

  final String? defaultServerUrl;

  /// App title for the default login page.

  final String? appTitle;

  /// App directory for the default login page.

  final String? appDirectory;

  /// App image for the default login page.
  final AssetImage? appImage;

  /// App logo for the default login page.

  final AssetImage? appLogo;

  /// App link for the default login page.

  final String? appLink;

  /// Widget to navigate to after successful login.

  final Widget? loginSuccessWidget;

  /// Security key manager reset function to call during logout.

  final VoidCallback? onSecurityKeyReset;

  /// Generic callback invoked after a successful logout.

  final VoidCallback? onLogout;

  /// URL of the app's client profile JSON-LD document. Required parameter.

  final String? clientId;

  /// One redirect URI per platform — [pickRedirectUri] (from `solidpod`)
  /// selects the correct entry at runtime. macOS shares the custom-scheme
  /// entry with iOS/Android because `oidc_macos` uses
  /// `ASWebAuthenticationSession` and does not listen on
  /// `http://localhost`.

  final List<String> redirectUris;

  /// One post-logout redirect URI per platform. Preferred over
  /// [postLogoutRedirectUri].

  final List<String> postLogoutRedirectUris;

  const SolidAuthConfig({
    this.returnTo,
    this.loginPageBuilder,
    this.defaultServerUrl,
    this.appTitle,
    this.appDirectory,
    this.appImage,
    this.appLogo,
    this.appLink,
    this.loginSuccessWidget,
    this.onSecurityKeyReset,
    this.onLogout,
    this.clientId,
    this.redirectUris = const [],
    this.postLogoutRedirectUris = const [],
  });
}

/// Centralised Solid authentication handler.

class SolidAuthHandler {
  static SolidAuthHandler? _instance;
  SolidAuthConfig? _config;

  // Cached login configuration from the app's original SolidLogin widget.

  String? _cachedTitle;
  String? _cachedAppDirectory;
  String? _cachedWebId;
  AssetImage? _cachedImage;
  AssetImage? _cachedLogo;
  String? _cachedLink;
  Widget? _cachedChild;
  String? _cachedClientId;
  List<String>? _cachedRedirectUris;
  List<String> _cachedPostLogoutRedirectUris = const [];
  bool _isAutoConfigured = false;

  // Cached button styles and theme from the app's original SolidLogin widget.

  LoginButtonStyle? _cachedLoginButtonStyle;
  ContinueButtonStyle? _cachedContinueButtonStyle;
  RegisterButtonStyle? _cachedRegisterButtonStyle;
  InfoButtonStyle? _cachedInfoButtonStyle;
  ChangeKeyButtonStyle? _cachedChangeKeyButtonStyle;
  SolidLoginTheme? _cachedThemeConfig;
  SnackbarConfig? _cachedSnackbarConfig;
  bool _cachedRequired = false;

  SolidAuthHandler._internal();

  /// Singleton instance of the authentication handler.

  static SolidAuthHandler get instance {
    _instance ??= SolidAuthHandler._internal();
    return _instance!;
  }

  /// Configure the authentication handler with app-specific settings.

  void configure(SolidAuthConfig config) {
    _config = config;
  }

  /// Auto-configure from SolidLogin widget parameters.
  /// Called automatically when SolidLogin initialises.

  void autoConfigureFromLogin({
    required String title,
    required String appDirectory,
    required String webId,
    required AssetImage image,
    required AssetImage logo,
    required String link,
    required Widget child,
    required String clientId,
    required List<String> redirectUris,
    List<String> postLogoutRedirectUris = const [],
    LoginButtonStyle? loginButtonStyle,
    ContinueButtonStyle? continueButtonStyle,
    RegisterButtonStyle? registerButtonStyle,
    InfoButtonStyle? infoButtonStyle,
    ChangeKeyButtonStyle? changeKeyButtonStyle,
    SolidLoginTheme? themeConfig,
    SnackbarConfig? snackbarConfig,
    bool required = false,
  }) {
    _cachedTitle = title;
    _cachedAppDirectory = appDirectory;
    _cachedWebId = webId;
    _cachedImage = image;
    _cachedLogo = logo;
    _cachedLink = link;
    _cachedChild = child;
    _cachedClientId = clientId;
    _cachedRedirectUris = redirectUris;
    _cachedPostLogoutRedirectUris = postLogoutRedirectUris;
    _cachedLoginButtonStyle = loginButtonStyle;
    _cachedContinueButtonStyle = continueButtonStyle;
    _cachedRegisterButtonStyle = registerButtonStyle;
    _cachedInfoButtonStyle = infoButtonStyle;
    _cachedChangeKeyButtonStyle = changeKeyButtonStyle;
    _cachedThemeConfig = themeConfig;
    _cachedSnackbarConfig = snackbarConfig;
    _cachedRequired = required;
    _isAutoConfigured = true;
  }

  /// Check if auto-configuration is available.

  bool get hasAutoConfig => _isAutoConfigured;

  /// Handle logout functionality with confirmation popup.

  Future<void> handleLogout(BuildContext context) async {
    // Use login page as the return destination to avoid going back to main app.

    final returnWidget = _buildLoginPage(context);

    // Pass a combined callback that resets solidui global state AND invokes
    // the app's onSecurityKeyReset callback after logoutPod succeeds.

    await logoutPopup(
      context,
      returnWidget,
      onLogoutSuccess: () {
        _resetOnLogout();
        _config?.onSecurityKeyReset?.call();
        _config?.onLogout?.call();
      },
    );

    // After logout popup, the user should already be on the login page.
    // No additional navigation needed.
  }

  /// Resets solidui global notifiers and in-memory state that must not
  /// survive across different user sessions.

  void _resetOnLogout() {
    securityKeyNotifier.reset();
  }

  /// Handle login functionality by navigating to login page.
  /// After successful login, navigates back to the app's root route.

  Future<void> handleLogin(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _buildLoginPage(context)),
    );
  }

  /// Build the login page widget.

  Widget _buildLoginPage(BuildContext context) {
    if (_config?.loginPageBuilder != null) {
      return _config!.loginPageBuilder!(context);
    }

    // Use auto-configured values from the app's original SolidLogin if
    // available. Styles are preserved so the re-login page matches the
    // app's original appearance.

    if (_isAutoConfigured && _cachedChild != null) {
      return SolidDefaultLogin(
        appTitle: _cachedTitle ?? _config?.appTitle ?? 'Solid App',
        appDirectory:
            _cachedAppDirectory ?? _config?.appDirectory ?? 'solid_app',
        defaultServerUrl:
            _cachedWebId ??
            _config?.defaultServerUrl ??
            SolidConfig.defaultServerUrl,
        appImage: _cachedImage ?? _config?.appImage,
        appLogo: _cachedLogo ?? _config?.appLogo,
        appLink: _cachedLink ?? _config?.appLink,
        loginSuccessWidget: _config?.loginSuccessWidget ?? _cachedChild,
        loginButtonStyle: _cachedLoginButtonStyle,
        continueButtonStyle: _cachedContinueButtonStyle,
        registerButtonStyle: _cachedRegisterButtonStyle,
        infoButtonStyle: _cachedInfoButtonStyle,
        changeKeyButtonStyle: _cachedChangeKeyButtonStyle,
        themeConfig: _cachedThemeConfig,
        snackbarConfig: _cachedSnackbarConfig,
        required: _cachedRequired,
        clientId: _cachedClientId ?? _config?.clientId ?? '',
        redirectUris: _cachedRedirectUris ?? _config?.redirectUris ?? [],
        postLogoutRedirectUris: _cachedPostLogoutRedirectUris,
      );
    }

    // Fall back to manual configuration or defaults.

    return SolidDefaultLogin(
      appTitle: _config?.appTitle ?? 'Solid App',
      appDirectory: _config?.appDirectory ?? 'solid_app',
      defaultServerUrl:
          _config?.defaultServerUrl ?? SolidConfig.defaultServerUrl,
      appImage: _config?.appImage,
      appLogo: _config?.appLogo,
      appLink: _config?.appLink,
      loginSuccessWidget: _config?.loginSuccessWidget,
      navigateToRootOnSuccess: _config?.loginSuccessWidget == null,
      clientId: _cachedClientId ?? _config?.clientId ?? '',
      redirectUris: _cachedRedirectUris ?? _config?.redirectUris ?? [],
      postLogoutRedirectUris: _cachedPostLogoutRedirectUris,
    );
  }

  /// Handle authentication action based on current login status.

  Future<void> handleAuthAction(BuildContext context) async {
    try {
      final webId = await getWebId();
      if (!context.mounted) return;

      if (webId != null && webId.isNotEmpty) {
        await handleLogout(context);
      } else {
        await handleLogin(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Authentication error: $e')));
      }
    }
  }
}
