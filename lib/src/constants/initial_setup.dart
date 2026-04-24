/// Initial setup page constants.
///
// Time-stamp: <Thursday 2026-01-22 11:26:01 +1100 Graham Williams>
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
/// Authors: Anushka Vidanage

library;

import 'package:flutter/material.dart';

/// Colour variables used in initial setup screen.

const lightGreen = Color.fromARGB(255, 120, 219, 137);

/// Colour variables used in initial setup screen.

const darkBlue = Color.fromARGB(255, 7, 87, 153);

/// Colour variables used in initial setup screen.

// const kTitleTextColor = Color(0xFF30384D);

/// Padding value for initial setup screen.

// const double kDefaultPadding = 20.0;

/// First line of the welcome title, shown on its own for clarity.

const initialStructureTitleLine1 = 'Welcome to the Solid';

/// Second line of the welcome title for a first-time setup.

const initialStructureTitleLine2Setup =
    'Personal Online Datastore Setup Wizard';

/// Second line of the welcome title when the user already has an app
/// directory but is missing resources (e.g. a newly required folder).

const initialStructureTitleLine2Update =
    'Personal Online Datastore Update Wizard';

/// Third line of the welcome title; includes the app name so the user
/// knows which app's POD is being configured.

String initialStructureTitleLine3(String appName) => 'for $appName';

/// Text string variables as the title of the message box.

const initialStructureTitle = 'Solid Pod';

/// Message shown when the user is connecting the app to their POD for the
/// first time and the POD needs to be initialised.
///
/// The [appName] parameter is the current app name. The [serverName] is the
/// human-readable Solid server host (e.g. `pods.solidcommunity.au`); when
/// empty the server reference is omitted so the sentence still reads
/// naturally.

String initialStructureMsg(String appName, String serverName) {
  // Build the first sentence, including the optional server reference so
  // empty [serverName] values do not leave a dangling "server ." in the
  // output.

  final serverClause =
      serverName.trim().isEmpty ? '' : ' on Solid server $serverName';
  return 'You have connected for the first time the $appName app to your '
      'Personal Online Datastore (POD)$serverClause. '
      'A security key is required to encrypt and protect your data stored '
      'in your POD using this app. You must remember this security key to '
      'access your data created with the $appName app.';
}

/// Message shown when the user's POD already has an app directory but is
/// missing one or more resources (e.g. a newly required folder for a new
/// app feature). Only prompts for the existing security key once.
///
/// The [appName] parameter is the current app name.

String initialUpdateMsg(String appName) =>
    'Your POD already has a $appName app folder, but its structure needs '
    'to be updated to support new features of this version of the app. '
    'Please provide your existing security key to authorise the '
    'update to your POD. None of your existing files will be lost — the '
    'update only adds the new folders and files required by this version '
    'of the app.';

/// Snackbar text displayed when the app detects the POD is not yet set
/// up for this app and starts the setup wizard.

String initialStructureSnackbarMsg(String appName) =>
    'The POD is not initialised for $appName app. Setting up your POD...';

/// Snackbar text displayed when the POD already has the app folder but is
/// missing some resources and the update wizard is about to run.

String initialUpdateSnackbarMsg(String appName) =>
    'The POD needs updating for $appName app. Opening the update wizard...';

/// The string key of input form for the input of security key

const securityKeyStr = '_security_key';

/// The string key of the input form for retyping the security key.

const securityKeyStrReType = '__security_key';

/// Markdown tooltip text for the security key input field.

const securityKeyTooltip =
    'A security key can be any string of characters that you can remember. '
    'The longer the better, with a mix of characters.';

const securityKeyRetypeTooltip =
    'Please retype your security key to ensure it is correct. '
    'We ask this to protect against loss of your data.';

/// Tooltip text for the SUBMIT button.
///
/// The [appName] parameter allows the tooltip to display the actual app name.

String submitButtonTooltip(String appName) =>
    'Tap here once you have provided your security key. '
    'This will record the key and create the Pod folder for $appName.';

/// Tooltip text for the RESOURCES button.
///
/// The [appName] parameter allows the tooltip to display the actual app name.

String resourcesButtonTooltip(String appName) =>
    'Tap here to list all of the $appName resources '
    'that will be created to initialise your Pod.';

/// Tooltip text for the LOGOUT button.
///
/// The [appName] parameter allows the tooltip to display the actual app name.

String logoutButtonTooltip(String appName) =>
    'Tap here to logout from your connection to your Pod on the Solid server. '
    'Next time you start $appName you will need to log into the server again.';
