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
import 'package:solidpod/solidpod.dart'
    show
        ResourceStatus,
        checkResourceStatus,
        getEncKeyPath,
        getFileUrl,
        getWebId;

import 'package:solidui/solidui.dart' show SolidLogin, logoutPopup;
import 'package:solidui/src/constants/initial_setup.dart';
import 'package:solidui/src/screens/initial_setup_widgets/enc_key_input_form.dart';
import 'package:solidui/src/screens/initial_setup_widgets/initial_setup_welcome.dart';
import 'package:solidui/src/screens/initial_setup_widgets/res_create_form_submission.dart';
import 'package:solidui/src/screens/initial_setup_widgets/resources_dialog.dart';
import 'package:solidui/src/services/solid_security_key_notifier.dart';

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

  // Shared by the ListView and its Scrollbar so the always-visible
  // scrollbar thumb tracks the same scroll position as the list.

  final _scrollController = ScrollController();

  String _appName = 'the App';
  String? _webId;
  String _serverName = '';

  // True when the POD already holds the encryption key for this app, so the
  // wizard is only topping up missing folders/files for a newer version of
  // the app rather than doing a first-time setup. When true the user is
  // only asked for their existing security key once (no retype) and the
  // title/body switch to "Update Wizard" wording.

  bool _isUpdate = false;

  // Becomes true after the asynchronous update-mode detection has
  // completed, so we do not flash the first-time-setup wording to users
  // who are in fact running an update.

  bool _modeResolved = false;

  @override
  void initState() {
    super.initState();
    _loadAppName();
    _loadWebId();
    _resolveSetupMode();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        _serverName = _deriveServerName(webId);
      });
    }
  }

  /// Extracts the Solid server host from a WebID URL (e.g.
  /// `https://pods.solidcommunity.au/alice/profile/card#me` →
  /// `pods.solidcommunity.au`). Falls back to an empty string if the
  /// WebID cannot be parsed, in which case the welcome widget simply
  /// omits the server name from the message.

  String _deriveServerName(String? webId) {
    if (webId == null || webId.isEmpty) return '';
    try {
      final host = Uri.parse(webId).host;
      return host.isEmpty ? '' : host;
    } on FormatException {
      return '';
    }
  }

  /// Determines whether the wizard is running in "update" mode by checking
  /// whether the encryption key file already exists on the server. If it
  /// does, the user has previously initialised their POD for this app and
  /// we must reuse the existing key rather than asking them to invent a
  /// new one.

  Future<void> _resolveSetupMode() async {
    var isUpdate = false;
    try {
      final encKeyUrl = await getFileUrl(await getEncKeyPath());
      isUpdate = await checkResourceStatus(encKeyUrl) == ResourceStatus.exist;
    } on Object catch (e) {
      debugPrint('InitialSetupScreenBody: failed to resolve setup mode: $e');
    }
    if (mounted) {
      setState(() {
        _isUpdate = isUpdate;
        _modeResolved = true;
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

    // While the setup mode is still being resolved, show a lightweight
    // spinner instead of the first-time-setup wording so we do not
    // briefly show it to users who are actually doing an update.

    if (!_modeResolved) {
      return const Center(child: CircularProgressIndicator());
    }

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

                // Show the scrollbar thumb even when the user is not
                // hovering the list, so that additional unseen content
                // is discoverable at a glance.

                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: ListView(
                    controller: _scrollController,
                    primary: false,
                    children: [
                      initialSetupWelcome(
                        context,
                        _appName,
                        _webId,
                        serverName: _serverName,
                        isUpdate: _isUpdate,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            EncKeyInputForm(
                              formKey: _formKey,
                              requireRetype: !_isUpdate,
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
              onPressed: () async => await logoutPopup(
                context,
                widget.child,
                onLogoutSuccess: securityKeyNotifier.reset,
              ),
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
