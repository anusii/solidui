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
import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:solidpod/solidpod.dart' show getWebId;

import 'package:solidui/solidui.dart' show SolidLogin, logoutPopup;
import 'package:solidui/src/constants/initial_setup.dart';
import 'package:solidui/src/screens/initial_setup_widgets/enc_key_input_form.dart';
import 'package:solidui/src/screens/initial_setup_widgets/initial_setup_welcome.dart';
import 'package:solidui/src/screens/initial_setup_widgets/res_create_form_submission.dart';
import 'package:solidui/src/screens/initial_setup_widgets/resources_dialog.dart';

/// A [StatefulWidget] that represents the initial setup screen.

class InitialSetupScreenBody extends StatefulWidget {
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

  /// The original SolidLogin widget to return to when back is pressed.

  final SolidLogin? originalLogin;

  @override
  State<InitialSetupScreenBody> createState() => _InitialSetupScreenBodyState();
}

class _InitialSetupScreenBodyState extends State<InitialSetupScreenBody> {
  // Form key should be created once and persisted across rebuilds.
  // Creating it in build() would cause the form state to be lost on every
  // rebuild.

  final _formKey = GlobalKey<FormBuilderState>();

  String _appName = 'the App';
  String? _webId;

  @override
  void initState() {
    super.initState();
    _loadAppName();
    _loadWebId();
  }

  Future<void> _loadAppName() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        // Capitalise the first letter of the app name for display.
        final name = packageInfo.appName;
        _appName = name.isNotEmpty
            ? name[0].toUpperCase() + name.substring(1)
            : 'the App';
      });
    }
  }

  Future<void> _loadWebId() async {
    final webId = await getWebId();
    if (mounted) {
      setState(() {
        _webId = webId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final resFoldersLink = (widget.resNeedToCreate['folders'] as List)
        .map((item) => item.toString())
        .toList();

    final resFilesLink = (widget.resNeedToCreate['files'] as List)
        .map((item) => item.toString())
        .toList();

    final combinedLinks = resFoldersLink + resFilesLink;
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
          Row(
            children: [
              BackButton(onPressed: () => _handleBackPressed(context)),
            ],
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView(
                  primary: false,
                  children: [
                    initialSetupWelcome(context, _appName, _webId),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          EncKeyInputForm(
                            formKey: _formKey,
                            onSubmit: () async => _handleFormSubmit(
                              resFileNames,
                              resFoldersLink,
                              resFilesLink,
                            ),
                          ),
                          const SizedBox(height: 20),
                          FractionallySizedBox(
                            widthFactor: 0.9,
                            alignment: Alignment.center,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSubmitButton(
                                  context,
                                  resFileNames,
                                  resFoldersLink,
                                  resFilesLink,
                                ),
                                const SizedBox(height: 30),
                                _buildActionButtons(
                                  context,
                                  baseUrl,
                                  extractedParts,
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

  void _handleBackPressed(BuildContext context) {
    if (widget.originalLogin != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => widget.originalLogin!),
      );
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _handleFormSubmit(
    List<String> resFileNames,
    List<String> resFoldersLink,
    List<String> resFilesLink,
  ) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final button = resCreateFormSubmission(
        _formKey,
        context,
        resFileNames,
        resFoldersLink,
        resFilesLink,
        widget.child,
      );
      button.onPressed?.call();
    }
  }

  Widget _buildSubmitButton(
    BuildContext context,
    List<String> resFileNames,
    List<String> resFoldersLink,
    List<String> resFilesLink,
  ) {
    return FocusTraversalOrder(
      order: const NumericFocusOrder(3),
      child: MarkdownTooltip(
        message: submitButtonTooltip(_appName),
        child: OutlinedButton(
          onPressed: () async =>
              _handleFormSubmit(resFileNames, resFoldersLink, resFilesLink),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            side: const BorderSide(color: Colors.blue),
          ),
          child: const Text(
            'SUBMIT',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    String baseUrl,
    List<String?> extractedParts,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FocusTraversalOrder(
          order: const NumericFocusOrder(4),
          child: MarkdownTooltip(
            message: resourcesButtonTooltip(_appName),
            child: TextButton(
              onPressed: () =>
                  ResourcesDialog.show(context, baseUrl, extractedParts),
              child: const Text(
                'RESOURCES',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        FocusTraversalOrder(
          order: const NumericFocusOrder(5),
          child: MarkdownTooltip(
            message: logoutButtonTooltip(_appName),
            child: TextButton(
              onPressed: () async => await logoutPopup(context, widget.child),
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
        ),
      ],
    );
  }
}
