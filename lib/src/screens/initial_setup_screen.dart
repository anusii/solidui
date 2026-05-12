/// Initial loading widget set up page.
///
// Time-stamp: <Saturday 2025-07-19 09:53:23 +1000 Graham Williams>
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
/// Authors: Zheyuan Xu, Anushka Vidanage

library;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart' show SolidLogin;
import 'package:solidui/src/screens/initial_setup_screen_body.dart';

/// Numeric variables used in initial setup page.

// const double normalLoadingScreenHeight = 200.0;

/// A [StatefulWidget] for the initial setup screen of an application, handling the initial configuration and resource allocation.
///
/// This widget serves as the main interface for the initial setup process of the application. It takes in essential parameters
/// for authentication and setup, and manages the state and UI flow for setting up the application's initial environment.

class InitialSetupScreen extends StatefulWidget {
  /// Parameters for initla setup screen

  const InitialSetupScreen({
    required this.resCheckList,
    required this.child,
    this.originalLogin,
    this.isUpdate,
    super.key,
  });

  // Validated authentication data returing from the Solid server.
  // Includes Access token, Refresh token, logout URL, RSA info, Client info, etc.
  // final Map<dynamic, dynamic> authData;

  // The authenticated user specific URI.
  // final String webId;

  // Name of the app that the user is authenticating into
  // final String appName;

  /// A dynamic list of missing resources from the user's POD

  final List<dynamic> resCheckList;

  /// The child widget after logging in.

  final Widget child;

  /// The original SolidLogin widget to return to when back is pressed

  final SolidLogin? originalLogin;

  /// Pre-computed "update mode" flag supplied by the caller (typically the
  /// login handler). When non-null the wizard uses this value directly and
  /// skips its own remote check, avoiding a loading spinner and an extra
  /// network round-trip. When null the wizard falls back to detecting
  /// update mode itself for backwards compatibility.

  final bool? isUpdate;

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  Widget _loadedScreen(List<dynamic> resCheckList) {
    final resNeedToCreate = resCheckList.last as Map;

    // Use theme-aware background colour for dark mode support.

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Expanded(
            child: InitialSetupScreenBody(
              resNeedToCreate: resNeedToCreate,
              originalLogin: widget.originalLogin,
              isUpdate: widget.isUpdate,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(child: _loadedScreen(widget.resCheckList)),
    );
  }
}
