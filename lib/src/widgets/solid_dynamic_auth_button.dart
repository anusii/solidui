/// Dynamic Authentication Button Widget.
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
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:solidpod/solidpod.dart' show getWebId, isUserLoggedIn;

import 'package:solidui/src/handlers/solid_auth_handler.dart';

/// A dynamic authentication button that shows login or logout icon
/// based on the current authentication state.
///
/// When user is logged out: shows login icon, navigates to login page on tap.
/// When user is logged in: shows logout icon, triggers logout on tap.

class SolidDynamicAuthButton extends StatefulWidget {
  /// Whether to show the logout button when user is logged in.

  final bool showLogout;

  /// Whether to show the login button when user is logged out.
  /// Set to false to hide the login button entirely (e.g. when the app
  /// uses a dedicated login screen via SolidLogin).

  final bool showLogin;

  /// Callback function triggered when user taps logout (when logged in).
  /// If null, uses SolidAuthHandler.instance.handleLogout().

  final void Function(BuildContext)? onLogout;

  /// Callback function triggered when user taps login (when logged out).
  /// If null, uses SolidAuthHandler.instance.handleLogin().

  final void Function(BuildContext)? onLogin;

  /// Tooltip message for the login button.

  final String loginTooltip;

  /// Tooltip message for the logout button.

  final String logoutTooltip;

  const SolidDynamicAuthButton({
    super.key,
    this.showLogout = true,
    this.showLogin = true,
    this.onLogout,
    this.onLogin,
    this.loginTooltip = 'Log in to your Solid POD',
    this.logoutTooltip = 'Log out of the current session',
  });

  @override
  State<SolidDynamicAuthButton> createState() => _SolidDynamicAuthButtonState();
}

class _SolidDynamicAuthButtonState extends State<SolidDynamicAuthButton> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// Checks the current login status by verifying the WebID and session state.

  Future<void> _checkLoginStatus() async {
    try {
      final webId = await getWebId();

      if (webId == null || webId.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoggedIn = false;
            _isLoading = false;
          });
        }
        return;
      }

      // Verify if the user is actually logged in with a valid session.

      final isLoggedIn = await isUserLoggedIn();

      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  /// Handles button tap based on current authentication state.

  Future<void> _handleTap() async {
    if (_isLoggedIn) {
      // User is logged in, perform logout.

      if (widget.onLogout != null) {
        widget.onLogout!(context);
      } else {
        await SolidAuthHandler.instance.handleLogout(context);
      }
    } else {
      // User is not logged in, navigate to login page.

      if (widget.onLogin != null) {
        widget.onLogin!(context);
      } else {
        await SolidAuthHandler.instance.handleLogin(context);
      }
    }

    // Refresh the login status after a brief delay.

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _checkLoginStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show a subtle loading indicator whilst checking status.

      return const SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // Hide logout button when logged in and showLogout is false.
    if (!widget.showLogout && _isLoggedIn) {
      return const SizedBox.shrink();
    }

    // Hide login button when logged out and showLogin is false.
    if (!widget.showLogin && !_isLoggedIn) {
      return const SizedBox.shrink();
    }

    final icon = _isLoggedIn ? Icons.logout : Icons.login;
    final tooltip = _isLoggedIn ? widget.logoutTooltip : widget.loginTooltip;

    return MarkdownTooltip(
      message: tooltip,
      child: IconButton(icon: Icon(icon), onPressed: _handleTap),
    );
  }
}
