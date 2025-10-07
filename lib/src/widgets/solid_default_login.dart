/// Default Solid Login Widget.
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

import 'package:solidpod/solidpod.dart';

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

    return const AssetImage('assets/images/app_image.png');
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
