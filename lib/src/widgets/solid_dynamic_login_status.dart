/// Dynamic Login Status Widget.
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

import 'package:solidpod/solidpod.dart' show getWebId, checkLoggedIn;

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

      final isLoggedIn = await checkLoggedIn();

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
      }
    } else {
      if (widget.onLogin != null) {
        widget.onLogin!.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot log in: No login interface available'),
            duration: Duration(seconds: 3),
          ),
        );
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

    // Create the updated status bar configuration with dynamic login status.

    final updatedConfig = SolidStatusBarConfig(
      serverInfo: widget.baseConfig.serverInfo,
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
