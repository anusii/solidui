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
import 'package:solidui/src/widgets/solid_login.dart';
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
  });
}

/// Centralised Solid authentication handler.

class SolidAuthHandler {
  static SolidAuthHandler? _instance;
  SolidAuthConfig? _config;

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

  /// Configure default values without overwriting existing configuration.
  /// This is used by SolidLogin to provide fallback values while preserving
  /// app-specific settings like onSecurityKeyReset.

  void configureDefaults(SolidAuthConfig defaults) {
    if (_config == null) {
      // No existing config, use defaults
      _config = defaults;
    } else {
      // Merge: keep existing non-null values, fill in missing ones from defaults
      _config = SolidAuthConfig(
        returnTo: _config!.returnTo ?? defaults.returnTo,
        loginPageBuilder:
            _config!.loginPageBuilder ?? defaults.loginPageBuilder,
        defaultServerUrl:
            _config!.defaultServerUrl ?? defaults.defaultServerUrl,
        appTitle: _config!.appTitle ?? defaults.appTitle,
        appDirectory: _config!.appDirectory ?? defaults.appDirectory,
        appImage: _config!.appImage ?? defaults.appImage,
        appLogo: _config!.appLogo ?? defaults.appLogo,
        appLink: _config!.appLink ?? defaults.appLink,
        loginSuccessWidget:
            _config!.loginSuccessWidget ?? defaults.loginSuccessWidget,
        // IMPORTANT: Preserve app's security key reset callback
        onSecurityKeyReset:
            _config!.onSecurityKeyReset ?? defaults.onSecurityKeyReset,
      );
    }
  }

  /// Handle logout functionality with confirmation popup.

  Future<void> handleLogout(BuildContext context) async {
    if (_config?.onSecurityKeyReset != null) {
      _config!.onSecurityKeyReset!();
    }

    // Use login page as the return destination to avoid going back to main app.

    final returnWidget = _buildLoginPage(context);
    await logoutPopup(context, returnWidget);

    // After logout popup, the user should already be on the login page
    // No additional navigation needed.
  }

  /// Handle login functionality - navigates to login page.
  /// Works consistently across all platforms (web, mobile, desktop).

  Future<void> handleLogin(BuildContext context) async {
    // Navigate to login page using standard Flutter navigation
    // This works across all platforms and maintains proper widget lifecycle
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => _buildLoginPage(context),
      ),
    );
  }

  /// Build the login page widget.
  ///
  /// Returns the actual login input page (SolidLogin), not the success page.
  /// This is used when guest users want to authenticate, or after logout.

  Widget _buildLoginPage(BuildContext context) {
    if (_config?.loginPageBuilder != null) {
      return _config!.loginPageBuilder!(context);
    }

    // Use the login input page, not the success page
    // The loginSuccessWidget (child) will be shown after successful authentication
    final mainAppWidget = _config?.loginSuccessWidget ??
        const Center(child: Text('Authentication required'));

    // Use ValueKey to identify this as a fresh login page instance
    // This works with didUpdateWidget() to reset state when needed
    return SolidLogin(
      key: const ValueKey('login_page'),
      appDirectory: _config?.appDirectory ?? 'solid_app',
      webID: _config?.defaultServerUrl ?? SolidConfig.defaultServerUrl,
      // Use provided images or fallback to SolidLogin's defaults from solidpod package
      image: _config?.appImage ??
          const AssetImage(
            'assets/images/default_image.jpg',
            package: 'solidpod',
          ),
      logo: _config?.appLogo ??
          const AssetImage(
            'assets/images/default_logo.png',
            package: 'solidpod',
          ),
      child: mainAppWidget,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication error: $e'),
          ),
        );
      }
    }
  }
}
