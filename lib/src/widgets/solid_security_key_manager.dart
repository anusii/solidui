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
    show
        KeyManager,
        deleteFile,
        getEncKeyPath,
        getFileUrl,
        checkResourceStatus,
        ResourceStatus;

import 'package:solidui/src/services/solid_security_key_notifier.dart';
import 'package:solidui/src/widgets/solid_security_key_manager_dialogs.dart';
import 'package:solidui/src/widgets/solid_security_key_manager_ui.dart';
import 'package:solidui/src/widgets/solid_security_key_operations.dart';
import 'package:solidui/src/widgets/solid_security_key_ui_helpers.dart';

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

  // Initialise with the current notifier status to avoid showing wrong state.

  late bool _hasExistingKey;

  // Controllers for input fields used in dialogues.

  final _keyController = TextEditingController();
  final _confirmKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialise with current notifier status to avoid flashing wrong UI.

    _hasExistingKey = securityKeyNotifier.isKeySaved;
    _checkKeyStatus();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _confirmKeyController.dispose();
    super.dispose();
  }

  /// Checks if a security key exists.
  ///
  /// If [forceCheck] is true, always performs a full check regardless of
  /// the notifier state. This is used after setting a new key.

  Future<void> _checkKeyStatus({bool forceCheck = false}) async {
    // First check the global notifier state.
    // This avoids race conditions where we just deleted the key.

    final currentNotifierStatus = securityKeyNotifier.isKeySaved;

    // If notifier says no key and we're not forcing a check, trust it.
    // This prevents re-checking after deletion.

    if (!currentNotifierStatus && !forceCheck) {
      debugPrint('Notifier indicates no key, skipping file check');
      if (mounted) {
        setState(() {
          _hasExistingKey = false;
        });
      }
      widget.onKeyStatusChanged(false);
      return;
    }

    // Perform a full check.

    final hasValidKey = await SecurityKeyOperations.checkKeyStatus();

    // Update all states with the verified status, but check mounted first.

    if (!mounted) return;

    securityKeyNotifier.updateStatus(hasValidKey);
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
          // Update status immediately after changing key.

          _updateKeyStatusAfterSet();
        },
      );
      return;
    }

    // CRITICAL FIX: Check if server has enc-keys.ttl before showing new key dialog.
    // If server has keys but local doesn't, user needs to RESTORE key, not create new.
    // Creating new would overwrite server keys and cause permanent data loss!

    try {
      final encKeyPath = await getEncKeyPath();
      final encKeyUrl = await getFileUrl(encKeyPath);
      final status = await checkResourceStatus(encKeyUrl, isFile: true);

      if (status == ResourceStatus.exist) {
        // Server has keys - show restore key dialog instead of new key dialog.
        if (!context.mounted) return;
        await _showRestoreKeyDialog(context);
        return;
      }
    } catch (e) {
      debugPrint('Error checking server key status: $e');
      // On error, fall through to new key dialog (safer default for new users).
    }

    if (!context.mounted) return;
    return _showNewKeyDialog(context);
  }

  /// Shows dialog to restore/verify an existing security key.
  /// Used when server has enc-keys.ttl but local storage doesn't have the key.
  Future<void> _showRestoreKeyDialog(BuildContext context) async {
    await SolidSecurityKeyManagerDialogs.showRestoreKeyDialog(
      context,
      _keyController,
      () async {
        _updateKeyStatusAfterSet();
      },
      (key) async {
        return await SecurityKeyOperations.handleRestoreKey(
          key,
          (message) {
            if (mounted) {
              // ignore: use_build_context_synchronously
              SecurityKeyUIHelpers.showErrorSnackBar(this.context, message);
            }
          },
        );
      },
      onForgotKey: () async {
        await _handleForgotKeyReset();
      },
    );
  }

  /// Handles the forgot key reset - deletes all encryption keys and shows new key dialog.
  Future<void> _handleForgotKeyReset() async {
    try {
      // Delete encryption key files from server
      final encKeyPath = await getEncKeyPath();
      await deleteFile(encKeyPath, isKey: true);

      // Clear any local key state
      await KeyManager.forgetSecurityKey();

      // Update status
      if (mounted) {
        setState(() => _hasExistingKey = false);
        securityKeyNotifier.updateStatus(false);
        widget.onKeyStatusChanged(false);
      }

      // Show new key dialog
      if (mounted) {
        await _showNewKeyDialog(context);
      }
    } catch (e) {
      if (mounted) {
        SecurityKeyUIHelpers.showErrorSnackBar(
          context,
          'Failed to reset security key: $e',
        );
      }
    }
  }

  Future<void> _showNewKeyDialog(BuildContext context) async {
    await SolidSecurityKeyManagerDialogs.showNewKeyDialog(
      context,
      _keyController,
      _confirmKeyController,
      () async {
        // Update status immediately after setting new key.

        _updateKeyStatusAfterSet();
      },
      (key, confirmKey) async {
        return await SecurityKeyOperations.handleKeySubmission(
          key,
          confirmKey,
          (message) => SecurityKeyUIHelpers.showErrorSnackBar(
            context,
            message,
          ),
        );
      },
    );
  }

  /// Updates the key status immediately after setting a key.
  /// This avoids async checks that might fail if the widget is disposed.

  void _updateKeyStatusAfterSet() {
    if (!mounted) return;

    // Immediately update all states to true.

    setState(() {
      _hasExistingKey = true;
    });

    // Update global notifier.

    securityKeyNotifier.updateStatus(true);

    // Notify parent widget.

    widget.onKeyStatusChanged(true);

    debugPrint('Security key status updated to saved');
  }

  Future<void> _showKeyFileNotFoundDialog(BuildContext context) async {
    await SecurityKeyUIHelpers.showErrorDialog(
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
      () => Navigator.of(context).pop(),
    );
  }

  /// Handles the forget key action.

  Future<void> _handleForgetKey() async {
    final confirmed = await _showForgetKeyConfirmation(context);
    if (!confirmed || !mounted) return;

    late String msg;
    bool success = false;

    try {
      // Clear the key from memory.

      await KeyManager.forgetSecurityKey();

      // Delete the key file from POD.
      // IMPORTANT: Use isKey: true to skip permission revocation
      // because encryption files are NOT in the data directory

      final encKeyPath = await getEncKeyPath();
      await deleteFile(encKeyPath, isKey: true);

      success = true;
      msg = 'Successfully forgot local security key.';
    } on Exception catch (e) {
      debugPrint('Error forgetting key: $e');
      msg = 'Failed to forget local security key: $e';
    }

    if (!mounted) return;

    // Force update all states to false immediately.

    if (success) {
      // Update local widget state.

      setState(() {
        _hasExistingKey = false;
      });

      // Update global notifier - this will trigger UI updates.

      securityKeyNotifier.updateStatus(false);

      // Notify parent widget.

      widget.onKeyStatusChanged(false);
    }

    if (!mounted) return;

    // Close the security key manager dialog first.

    Navigator.of(context).pop();

    // Show the notice dialog.

    await SecurityKeyUIHelpers.showErrorDialog(
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
