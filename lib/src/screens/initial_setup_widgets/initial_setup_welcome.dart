/// Common functions used across the package.
///
// Time-stamp: <Tuesday 2024-04-02 21:21:41 +1100 Graham Williams>
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

import 'package:solidui/src/constants/initial_setup.dart';
import 'package:solidui/src/widgets/build_message_container.dart';

/// Get the height of screen.

// double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

/// Get the width of screen.

// double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

/// A widget displaying an alert for the user noting that they have probably a
/// newly created Solid Pod or their App's Pod is missing resources.
///
/// The widget will inform the user about creating/re-creating these resources.
///
/// The [appName] parameter is used to display the actual app name in the
/// message instead of a generic reference.
///
/// The [webId] parameter, when provided, is displayed beneath the welcome
/// title so that the user can identify which POD is being set up.
///
/// The [serverName] parameter is the human-readable host of the Solid
/// server (e.g. `pods.solidcommunity.au`) that is shown in the setup
/// message so the user can see which server is being initialised.
///
/// The [isUpdate] flag distinguishes between a first-time POD setup (the
/// app has never been initialised for this user) and an update to an
/// existing app folder (e.g. a new version of the app requires a new
/// folder). The wording of the title and body is adjusted accordingly.

SizedBox initialSetupWelcome(
  BuildContext context,
  String appName,
  String? webId, {
  required String serverName,
  bool isUpdate = false,
}) {
  final titleColour = Theme.of(context).textTheme.titleLarge?.color;
  final titleStyle = TextStyle(
    fontSize: 25,
    color: titleColour,
    fontWeight: FontWeight.w500,
  );

  final line2 =
      isUpdate ? initialStructureTitleLine2Update : initialStructureTitleLine2Setup;

  return SizedBox(
    child: Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: lightGreen,
            ),
            alignment: Alignment.center,
            child: Icon(
              isUpdate ? Icons.system_update_alt : Icons.playlist_add,
              color: Colors.white,
              size: 50,
            ),
          ),
          const SizedBox(height: 10),

          // Render the welcome title across three lines so the purpose of
          // the wizard (setup vs update, and for which app) is immediately
          // obvious to a first-time user.

          Text(
            initialStructureTitleLine1,
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
          Text(
            line2,
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
          Text(
            initialStructureTitleLine3(appName),
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
          if (webId != null && webId.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 18,
                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                      Colors.grey[700],
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: SelectableText(
                    webId,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color ??
                          Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Center(
            child: buildMsgBox(
              context,
              'warning',
              '', // No title for the message box.
              isUpdate
                  ? initialUpdateMsg(appName)
                  : initialStructureMsg(appName, serverName),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Creates a row widget displaying a piece of profile information.
///
/// This function constructs a `Row` widget designed to display a single piece
/// of information in a profile UI. It is primarily used for laying out text-based
/// information such as names, titles, or other key details in the profile section.
///

// comment out the following function as it is not used in the current version
// of the app, anushka might need to use to in the future so keeping it here.

// Row buildInfoRow(String profName) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: <Widget>[
//       Text(
//         profName,
//         style: TextStyle(
//           color: Colors.grey[800],
//           letterSpacing: 2.0,
//           fontSize: 17.0,
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Poppins',
//         ),
//       ),
//     ],
//   );
// }

/// Builds a row widget displaying a label and its corresponding value.
///
/// This function creates a [Column] widget containing a [Row] with two text elements:
/// one for the label and the other for the profile name. It's used to display
/// information in a key-value pair format, where `labelName` is the key and
/// `profName` is the value.
///

// comment out the following function as it is not used in the current version
// of the app, anushka might need to use to in the future so keeping it here.

// Column buildLabelRow(String labelName, String profName, BuildContext context) {
//   return Column(
//     children: [
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           Text(
//             '$labelName: ',
//             style: TextStyle(
//               color: kTitleTextColor,
//               letterSpacing: 2.0,
//               fontSize: screenWidth(context) * 0.015,
//               fontWeight: FontWeight.bold,
//               //fontFamily: 'Poppins',
//             ),
//           ),
//           profName.length > longStrLength
//               ? Tooltip(
//                   message: profName,
//                   height: 30,
//                   textStyle: const TextStyle(fontSize: 15, color: Colors.white),
//                   verticalOffset: kDefaultPadding / 2,
//                   child: Text(
//                     truncateString(profName),
//                     style: TextStyle(
//                       color: Colors.grey[800],
//                       letterSpacing: 2.0,
//                       fontSize: screenWidth(context) * 0.015,
//                     ),
//                   ),
//                 )
//               : Text(
//                   profName,
//                   style: TextStyle(
//                       color: Colors.grey[800],
//                       letterSpacing: 2.0,
//                       fontSize: screenWidth(context) * 0.015),
//                 ),
//         ],
//       ),
//       SizedBox(
//         height: screenHeight(context) * 0.005,
//       )
//     ],
//   );
// }
