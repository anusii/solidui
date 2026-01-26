/// Default Solid Login Widget.
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

import 'package:solidui/src/constants/solid_config.dart';
import 'package:solidui/src/widgets/solid_login.dart';

/// A simplified wrapper around [SolidLogin] with sensible defaults.

class SolidDefaultLogin extends StatelessWidget {
  /// The application title displayed on the login panel.

  final String appTitle;

  /// The application directory for POD storage.

  final String appDirectory;

  /// The default server URL for authentication.

  final String defaultServerUrl;

  /// The application background image.
  ///
  /// If not provided, [SolidLogin] will use its default image with
  /// automatic fallback logic.

  final AssetImage? appImage;

  /// The application logo displayed at the top of the login panel.
  ///
  /// If not provided, [SolidLogin] will use its default logo with
  /// automatic fallback logic.

  final AssetImage? appLogo;

  /// The URL for the info button link.

  final String? appLink;

  /// Widget to navigate to after successful login.
  ///
  /// If not provided and [navigateToRootOnSuccess] is false, a default
  /// success screen will be shown.

  final Widget? loginSuccessWidget;

  /// Whether to navigate to the app's root route ('/') after successful login.

  final bool navigateToRootOnSuccess;

  const SolidDefaultLogin({
    super.key,
    required this.appTitle,
    required this.appDirectory,
    required this.defaultServerUrl,
    this.appImage,
    this.appLogo,
    this.appLink,
    this.loginSuccessWidget,
    this.navigateToRootOnSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the success widget based on configuration.

    Widget successWidget;
    if (loginSuccessWidget != null) {
      successWidget = loginSuccessWidget!;
    } else if (navigateToRootOnSuccess) {
      // Navigate to root route after login, returning to app's entry point.

      successWidget = _RootNavigator(appTitle: appTitle);
    } else {
      successWidget = _buildDefaultSuccessWidget(context);
    }

    return Theme(
      data: Theme.of(context).brightness == Brightness.dark
          ? ThemeData.dark()
          : ThemeData.light(),
      child: SolidLogin(
        required: false,
        title: appTitle,
        appDirectory: appDirectory,
        webID: defaultServerUrl,
        image: appImage ?? SolidConfig.defaultImage,
        logo: appLogo ?? SolidConfig.defaultLogo,
        link: appLink ?? '',
        child: successWidget,
      ),
    );
  }

  /// Builds the default success widget shown after login.

  Widget _buildDefaultSuccessWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Successfully logged in!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Welcome to $appTitle', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget that navigates to the app's root route when built.
/// Used as the login success destination to return to the app's entry point.

class _RootNavigator extends StatefulWidget {
  final String appTitle;

  const _RootNavigator({required this.appTitle});

  @override
  State<_RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<_RootNavigator> {
  @override
  void initState() {
    super.initState();
    // Navigate to root route after the widget is built.

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a brief loading indicator whilst navigating.

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Logging in to ${widget.appTitle}...',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
