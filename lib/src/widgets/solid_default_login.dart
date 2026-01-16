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

import 'package:solidui/src/widgets/solid_login.dart';

/// Default login widget for Solid POD authentication.

class SolidDefaultLogin extends StatelessWidget {
  /// The application title.

  final String appTitle;

  /// The application directory for POD storage.

  final String appDirectory;

  /// The default server URL for authentication.

  final String defaultServerUrl;

  /// The application image.

  final AssetImage? appImage;

  /// The application logo.

  final AssetImage? appLogo;

  /// The application link.

  final String? appLink;

  /// Widget to navigate to after successful login.

  final Widget? loginSuccessWidget;

  const SolidDefaultLogin({
    super.key,
    required this.appTitle,
    required this.appDirectory,
    required this.defaultServerUrl,
    this.appImage,
    this.appLogo,
    this.appLink,
    this.loginSuccessWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).brightness == Brightness.dark
          ? ThemeData.dark()
          : ThemeData.light(),
      child: SolidLogin(
        required: false,
        title: appTitle,
        appDirectory: appDirectory,
        webID: defaultServerUrl,
        image: appImage ?? _getDefaultImage(),
        logo: appLogo ?? _getDefaultLogo(),
        link: appLink ?? '',
        child: loginSuccessWidget ?? _getDefaultSuccessWidget(context),
      ),
    );
  }

  /// Get default application image if none provided.

  AssetImage _getDefaultImage() {
    // Try to use a common default image path, fallback to transparent pixel.

    return const AssetImage('assets/images/app_image.jpg');
  }

  /// Get default application logo if none provided.

  AssetImage _getDefaultLogo() {
    // Try to use a common default logo path, fallback to transparent pixel.

    return const AssetImage('assets/images/app_icon.png');
  }

  /// Get default success widget if none provided.

  Widget _getDefaultSuccessWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'Successfully logged in!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome to $appTitle',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate back or to main app.

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
