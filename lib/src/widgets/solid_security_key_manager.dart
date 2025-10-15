/// Solid Security Key Manager.
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
/// Authors: Ashley Tang, Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart'
    show KeyManager, deleteFile, getEncKeyPath, readPod;

import 'package:solidui/src/widgets/solid_security_key_manager_dialogs.dart';
import 'package:solidui/src/widgets/solid_security_key_manager_helpers.dart';
import 'package:solidui/src/widgets/solid_security_key_manager_ui.dart';

/// Configuration for the Security Key Manager.

class SolidSecurityKeyManagerConfig {
  /// The app widget to use for change key popup.

  final Widget appWidget;

  /// Custom title for the security key manager.

  final String? title;

  /// Whether to show the 'Show Security Key' button.

  final bool showViewKeyButton;

  /// Whether to show the 'Forget Security Key' button.

  final bool showForgetKeyButton;

  const SolidSecurityKeyManagerConfig({
    required this.appWidget,
    this.title,
    this.showViewKeyButton = true,
    this.showForgetKeyButton = true,
  });
}

/// Security Key Manager.

class SolidSecurityKeyManager extends StatefulWidget {
  /// Configuration for the security key manager.

  final SolidSecurityKeyManagerConfig config;

  /// Callback to notify parent widget when key status changes.

  final Function(bool) onKeyStatusChanged;

  const SolidSecurityKeyManager({
    super.key,
    required this.config,
    required this.onKeyStatusChanged,
  });

  @override
  SolidSecurityKeyManagerState createState() => SolidSecurityKeyManagerState();
}

/// State class that powers `SolidSecurityKeyManager` widget.

class SolidSecurityKeyManagerState extends State<SolidSecurityKeyManager>
    with SingleTickerProviderStateMixin {
  // Tracks whether a background operation is in progress.

  bool _isLoading = false;

  // Indicates if a security key exists for the user.

  bool _hasExistingKey = false;

  // Controllers for input fields used in dialogues.

  final _keyController = TextEditingController();
  final _confirmKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkKeyStatus();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _confirmKeyController.dispose();
    super.dispose();
  }

  /// Checks if a security key exists.

  Future<void> _checkKeyStatus() async {
    final hasValidKey = await SolidSecurityKeyManagerHelpers.checkKeyStatus(
      () async => await getEncKeyPath(),
      (filePath) async {
        if (!mounted) return '';
        return await readPod(filePath, context, widget, basePath: '');
      },
    );

    widget.onKeyStatusChanged(hasValidKey);
    setState(() {
      _hasExistingKey = hasValidKey;
    });
  }

  Future<void> _showPrivateData(String title, BuildContext context) async {
    await SolidSecurityKeyManagerDialogs.showPrivateData(
      title,
      context,
      _hasExistingKey,
      SolidSecurityKeyManager(
        config: widget.config,
        onKeyStatusChanged: widget.onKeyStatusChanged,
      ),
      (loading) {
        if (mounted) setState(() => _isLoading = loading);
      },
      widget.onKeyStatusChanged,
      _checkKeyStatus,
      _showKeyFileNotFoundDialog,
    );
  }

  Future<void> _showKeyInputDialog(BuildContext context) async {
    _keyController.clear();
    _confirmKeyController.clear();

    if (_hasExistingKey) {
      await SolidSecurityKeyManagerDialogs.showKeyInputDialog(
        context,
        widget.config.appWidget,
        () async {
          await _checkKeyStatus();
          if (!mounted) return;
          widget.onKeyStatusChanged(true);
          if (context.mounted) Navigator.of(context).pop();
        },
      );
      return;
    }
    return _showNewKeyDialog(context);
  }

  Future<void> _showNewKeyDialog(BuildContext context) async {
    await SolidSecurityKeyManagerDialogs.showNewKeyDialog(
      context,
      _keyController,
      _confirmKeyController,
      () async {
        await _checkKeyStatus();
        if (!mounted) return;
        widget.onKeyStatusChanged(true);
        if (context.mounted) Navigator.of(context).pop();
      },
      (key, confirmKey) async {
        return await SolidSecurityKeyManagerHelpers.handleKeySubmission(
          key,
          confirmKey,
          (filePath) async {
            if (!mounted) return '';
            return await readPod(
              filePath,
              context,
              const SizedBox(),
              basePath: '',
            );
          },
          (message) => SolidSecurityKeyManagerHelpers.showErrorSnackBar(
            context,
            message,
          ),
          (message) => SolidSecurityKeyManagerHelpers.showSuccessSnackBar(
            context,
            message,
          ),
        );
      },
    );
  }

  Future<void> _showKeyFileNotFoundDialog(BuildContext context) async {
    await SolidSecurityKeyManagerHelpers.showErrorDialog(
      context,
      'Security Key File Not Found',
      'The security key file could not be found. '
          'Would you like to set a new security key?',
    );
    await KeyManager.forgetSecurityKey();
    await _checkKeyStatus();
    if (context.mounted) {
      await _showKeyInputDialog(context);
    }
  }

  Widget _buildDialogContent(BuildContext context, String title) {
    return SolidSecurityKeyManagerUI.buildDialogContent(
      context,
      widget.config.title ?? 'Security Key Management',
      _isLoading,
      _hasExistingKey,
      widget.config.showViewKeyButton,
      widget.config.showForgetKeyButton,
      () async => await _showPrivateData(title, context),
      () async => await _showKeyInputDialog(context),
      _handleForgetKey,
    );
  }

  /// Handles the forget key action.

  Future<void> _handleForgetKey() async {
    final confirmed = await _showForgetKeyConfirmation(context);
    if (!confirmed || !mounted) return;

    late String msg;
    try {
      await KeyManager.forgetSecurityKey();
      final encKeyPath = await getEncKeyPath();
      await deleteFile(encKeyPath);

      if (!mounted) return;

      widget.onKeyStatusChanged(false);
      await _checkKeyStatus();
      msg = 'Successfully forgot local security key.';
    } on Exception catch (e) {
      msg = 'Failed to forget local security key: $e';
    }

    if (!mounted) return;

    await SolidSecurityKeyManagerHelpers.showErrorDialog(
      context,
      'Notice',
      msg,
    );
  }

  /// Shows a confirmation dialogue before forgetting the security key.

  Future<bool> _showForgetKeyConfirmation(BuildContext context) async {
    return SolidSecurityKeyManagerUI.showForgetKeyConfirmation(context);
  }

  @override
  Widget build(BuildContext context) {
    return SolidSecurityKeyManagerUI.buildMainDialog(
      widget.config.title,
      (title) => _buildDialogContent(context, title),
    );
  }
}
