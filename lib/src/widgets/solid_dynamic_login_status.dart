/// Dynamic Login Status Widget.
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

import 'package:solidpod/solidpod.dart' show getWebId, isUserLoggedIn;

import 'package:solidui/src/handlers/solid_auth_handler.dart';
import 'package:solidui/src/widgets/solid_status_bar.dart';
import 'package:solidui/src/widgets/solid_status_bar_models.dart';

/// A dynamic login status widget that automatically checks and updates
/// the login status based on the actual Solid POD authentication state.

class SolidDynamicLoginStatus extends StatefulWidget {
  /// The base status bar configuration.

  final SolidStatusBarConfig baseConfig;

  /// Custom onTap handler for login/logout actions when logged in.

  final VoidCallback? onTap;

  /// Custom login handler for when user is not logged in.

  final VoidCallback? onLogin;

  /// Custom text for logged in state.

  final String? loggedInText;

  /// Custom text for logged out state.

  final String? loggedOutText;

  /// Tooltip message for logged in state.

  final String? loggedInTooltip;

  /// Tooltip message for logged out state.

  final String? loggedOutTooltip;

  const SolidDynamicLoginStatus({
    super.key,
    required this.baseConfig,
    this.onTap,
    this.onLogin,
    this.loggedInText,
    this.loggedOutText,
    this.loggedInTooltip,
    this.loggedOutTooltip,
  });

  @override
  State<SolidDynamicLoginStatus> createState() =>
      _SolidDynamicLoginStatusState();
}

class _SolidDynamicLoginStatusState extends State<SolidDynamicLoginStatus> {
  String? _currentWebId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// Checks the current login status by fetching the WebID and verifying
  /// the login state with the Solid POD.

  Future<void> _checkLoginStatus() async {
    try {
      // Get the current WebID.

      final webId = await getWebId();

      if (webId == null || webId.isEmpty) {
        setState(() {
          _currentWebId = null;
          _isLoading = false;
        });
        return;
      }

      // Verify if the user is actually logged in.

      final isLoggedIn = await isUserLoggedIn();

      setState(() {
        _currentWebId = isLoggedIn ? webId : null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error checking login status: $e');
      setState(() {
        _currentWebId = null;
        _isLoading = false;
      });
    }
  }

  /// Handles tap events and refreshes the login status.

  void _handleTap() {
    final isCurrentlyLoggedIn =
        _currentWebId != null && _currentWebId!.isNotEmpty;

    if (isCurrentlyLoggedIn) {
      if (widget.onTap != null) {
        widget.onTap!.call();
      } else {
        SolidAuthHandler.instance.handleLogout(context);
      }
    } else {
      if (widget.onLogin != null) {
        widget.onLogin!.call();
      } else {
        SolidAuthHandler.instance.handleLogin(context);
      }
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _checkLoginStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show a loading indicator while checking login status.

      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    // Create the dynamic login status configuration.

    final dynamicLoginStatus = SolidLoginStatus(
      webId: _currentWebId,
      onTap: _handleTap,
      loggedInText: widget.loggedInText,
      loggedOutText: widget.loggedOutText,
      loggedInTooltip: widget.loggedInTooltip,
      loggedOutTooltip: widget.loggedOutTooltip,
    );

    // Create dynamic server info from webId if available, otherwise use base
    // config.

    final dynamicServerInfo = _currentWebId != null && _currentWebId!.isNotEmpty
        ? SolidServerInfo.fromWebId(
            _currentWebId!,
            tooltip: widget.baseConfig.serverInfo?.tooltip,
            isClickable: widget.baseConfig.serverInfo?.isClickable ?? true,
          )
        : widget.baseConfig.serverInfo;

    // Create the updated status bar configuration with dynamic login status
    // and server info.

    final updatedConfig = SolidStatusBarConfig(
      serverInfo: dynamicServerInfo,
      loginStatus: dynamicLoginStatus,
      onLogin: widget.baseConfig.onLogin,
      securityKeyStatus: widget.baseConfig.securityKeyStatus,
      customItems: widget.baseConfig.customItems,
      showOnNarrowScreens: widget.baseConfig.showOnNarrowScreens,
      narrowScreenThreshold: widget.baseConfig.narrowScreenThreshold,
      backgroundColor: widget.baseConfig.backgroundColor,
      narrowLayoutHeight: widget.baseConfig.narrowLayoutHeight,
      mediumLayoutHeight: widget.baseConfig.mediumLayoutHeight,
      wideLayoutHeight: widget.baseConfig.wideLayoutHeight,
      padding: widget.baseConfig.padding,
      itemSpacing: widget.baseConfig.itemSpacing,
    );

    return SolidStatusBar(config: updatedConfig);
  }
}
