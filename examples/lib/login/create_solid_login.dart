/// Create Solid Login Widget for SolidUI Examples.
//
// Time-stamp: <Wednesday 2025-08-27 15:30:00 +1000 Tony Chen>
//
/// Copyright (C) 2025, Software Innovation Institute, ANU
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
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

import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidpod/solidpod.dart';

import 'package:solidui_simple_example/main.dart';

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
