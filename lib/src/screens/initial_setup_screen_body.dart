/// Initial loaded screen set up page.
///
// Time-stamp: <Saturday 2025-07-19 09:54:50 +1000 Graham Williams>
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

// ignore_for_file: use_build_context_synchronously, public_member_api_docs

library;

import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:solidui/solidui.dart' show SolidLogin, logoutPopup;
import 'package:solidui/src/screens/initial_setup_widgets/enc_key_input_form.dart';
import 'package:solidui/src/screens/initial_setup_widgets/initial_setup_welcome.dart';
import 'package:solidui/src/screens/initial_setup_widgets/res_create_form_submission.dart';

/// A [StatefulWidget] that represents the initial setup screen for the desktop version of an application.
///
/// This widget is responsible for rendering the initial setup UI, which includes forms for user input and displaying
/// resources that will be created as part of the setup process.

class InitialSetupScreenBody extends StatefulWidget {
  /// Initialising the [StatefulWidget]

  const InitialSetupScreenBody({
    required this.resNeedToCreate,
    required this.child,
    this.originalLogin,
    super.key,
  });

  /// Resources that need to be created inside user's POD.

  final Map<dynamic, dynamic> resNeedToCreate;

  // Authentication data coming from the Solid server.
  // final Map<dynamic, dynamic> authData;

  // A URI that is uniquely assigned to the POD.
  // final String webId;

  // Name of the app.
  // final String appName;

  /// The child widget after logging in.

  final Widget child;

  /// The original SolidLogin widget to return to when back is pressed

  final SolidLogin? originalLogin;

  @override
  State<InitialSetupScreenBody> createState() {
    return _InitialSetupScreenBodyState();
  }
}

class _InitialSetupScreenBodyState extends State<InitialSetupScreenBody> {
  /// Shows a dialog displaying the resources to be created.

  void _showResourcesDialog(
    BuildContext context,
    String baseUrl,
    List<String?> extractedParts,
  ) {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Resources Dialog',
      barrierColor: Colors.black54,
      pageBuilder: (context, animation, secondaryAnimation) {
        // Use theme-aware colours for dark mode support.

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final dialogBg = isDark ? theme.cardColor : Colors.white;

        return Center(
          child: Material(
            borderRadius: BorderRadius.circular(12),
            elevation: 8,
            color: dialogBg,
            child: Container(
              width: 600,
              height: 500,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: dialogBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Resources to be created',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => rootNavigator.pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Within: $baseUrl',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Scrollable resource list.

                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.separated(
                        itemCount: extractedParts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final resLink = extractedParts[index];
                          if (resLink == null) return const SizedBox.shrink();
                          final isFolder = resLink.endsWith('/');
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Row(
                              children: [
                                Icon(
                                  isFolder
                                      ? Icons.folder_outlined
                                      : Icons.insert_drive_file_outlined,
                                  size: 20,
                                  color: isFolder ? Colors.amber : Colors.blue,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    resLink,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

    final resFoldersLink = (widget.resNeedToCreate['folders'] as List)
        .map((item) => item.toString())
        .toList();

    final resFilesLink = (widget.resNeedToCreate['files'] as List)
        .map((item) => item.toString())
        .toList();

    final combinedLinks = resFoldersLink + resFilesLink;

    // Get the common path among the URLs

    combinedLinks.sort((a, b) => a.length.compareTo(b.length));
    var baseUrl = combinedLinks.first;
    if (!baseUrl.endsWith('/')) {
      final items = baseUrl.split('/');
      baseUrl = '${items.getRange(0, items.length - 2).join('/')}/';
    }

    final extractedParts = combinedLinks
        .map((url) {
          // Check if the URL starts with the base URL and has additional parts.

          if (url.startsWith(baseUrl) && url.length > baseUrl.length) {
            // Extract everything after the base URL without splitting into segments.

            return url.substring(baseUrl.length);
          }

          // Return null for URLs that don't match the criteria.

          return null;
        })
        // Remove nulls.

        .where((item) => item != null)

        // Remove duplicates.

        .toSet()

        // Convert to list.

        .toList()
      // Sort alphabetically.
      ..sort();

    final resFileNames = (widget.resNeedToCreate['fileNames'] as List)
        .map((item) => item.toString())
        .toList();

    // Wrap in FocusTraversalGroup to enable ordered tab navigation.

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        children: [
          // Adding a Row for the back button and spacing.

          Row(
            children: [
              BackButton(
                onPressed: () {
                  // Navigate back to the original login screen with all
                  // parameters preserved.

                  if (widget.originalLogin != null) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => widget.originalLogin!,
                      ),
                    );
                  } else {
                    // Fallback to navigating to the root if original login is
                    // not available.

                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
              ),
            ],
          ),

          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView(
                  primary: false,
                  children: [
                    initialSetupWelcome(context),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          EncKeyInputForm(
                            formKey: formKey,
                            onSubmit: () => handleFormSubmission(
                              formKey,
                              context,
                              resFoldersLink,
                              resFilesLink,
                              widget.child,
                            ),
                          ),
                          const SizedBox(height: 20),
                          FractionallySizedBox(
                            widthFactor: 0.9,
                            alignment: Alignment.center,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                OutlinedButton(
                                  onPressed: () => _showResourcesDialog(
                                    context,
                                    baseUrl,
                                    extractedParts,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                    side: const BorderSide(color: Colors.blue),
                                  ),
                                  child: const Text(
                                    'RESOURCES',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // SUBMIT on left, LOGOUT on right.
                                // Tab order: Submit (3) then Logout (4).

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    FocusTraversalOrder(
                                      order: const NumericFocusOrder(3),
                                      child: resCreateFormSubmission(
                                        formKey,
                                        context,
                                        resFileNames,
                                        resFoldersLink,
                                        resFilesLink,
                                        widget.child,
                                      ),
                                    ),
                                    FocusTraversalOrder(
                                      order: const NumericFocusOrder(4),
                                      child: TextButton(
                                        onPressed: () async {
                                          await logoutPopup(
                                            context,
                                            widget.child,
                                          );
                                        },
                                        child: const Text(
                                          'LOGOUT',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
