/// Create Solid Login Widget for SolidUI Examples.
//
// Time-stamp: <Monday 2025-09-01 14:25:43 +1000 Graham Williams>
//
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

import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidpod/solidpod.dart';

import '../main.dart';

/// Creates a Solid login widget for authentication.
///
/// Parameters:
///   context: BuildContext for widget creation
///   prefs: SharedPreferences for accessing user preferences
///
/// Returns:
///   A Widget configured for Solid authentication.

Widget createSolidLogin(BuildContext context, SharedPreferences prefs) {
  debugPrint('🔍 Setting up Solid login widget for SolidUI Example');

  return _buildSolidUILogin(prefs);
}

/// Build the SolidUI example login widget.

Widget _buildSolidUILogin(SharedPreferences prefs) {
  return Builder(
    builder: (context) {
      // Create SolidLogin widget for SolidUI example.

      return Column(
        children: [
          Expanded(
            child: Theme(
              data: Theme.of(context).brightness == Brightness.dark
                  ? ThemeData.dark()
                  : ThemeData.light(),
              child: SolidLogin(
                required: false,
                title: 'SolidUI Example',
                appDirectory: 'solidui_example',
                webID: 'https://pods.dev.solidcommunity.au',
                image: const AssetImage('assets/images/app_image.jpg'),
                logo: const AssetImage('assets/images/app_icon.png'),
                link: 'https://github.com/anusii/solidui',

                // Directly navigate to the main application after login.
                child: SimpleExampleApp(prefs: prefs),
              ),
            ),
          ),
        ],
      );
    },
  );
}
