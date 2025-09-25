/// Solid Authentication Handler.
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart' show logoutPopup, getWebId;

import '../widgets/solid_default_login.dart';

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

  /// Handle login functionality by navigating to login page.

  Future<void> handleLogin(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => _buildLoginPage(context),
      ),
    );
  }

  /// Build the login page widget.

  Widget _buildLoginPage(BuildContext context) {
    if (_config?.loginPageBuilder != null) {
      return _config!.loginPageBuilder!(context);
    }

    // Use default login page.

    return SolidDefaultLogin(
      appTitle: _config?.appTitle ?? 'Solid App',
      appDirectory: _config?.appDirectory ?? 'solid_app',
      defaultServerUrl:
          _config?.defaultServerUrl ?? 'https://pods.dev.solidcommunity.au',
      appImage: _config?.appImage,
      appLogo: _config?.appLogo,
      appLink: _config?.appLink,
      loginSuccessWidget: _config?.loginSuccessWidget,
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
