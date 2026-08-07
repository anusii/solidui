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

import 'package:solidpod/solidpod.dart' show KeyManager, isUserLoggedIn;

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

  // Indicates if a security key is cached locally.

  late bool _isKeyCached;

  // Controller for input field used in cache key dialogue.

  final _keyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isKeyCached = securityKeyNotifier.isKeySaved;
    _checkKeyStatus();
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  /// Checks if a security key is cached locally.

  Future<void> _checkKeyStatus({bool forceCheck = false}) async {
    final currentNotifierStatus = securityKeyNotifier.isKeySaved;
    if (!currentNotifierStatus && !forceCheck) {
      debugPrint('Notifier indicates no cached key, skipping check');
      if (mounted) setState(() => _isKeyCached = false);
      widget.onKeyStatusChanged(false);
      return;
    }
    final isCached = await SecurityKeyOperations.checkKeyStatus();
    if (!mounted) return;
    securityKeyNotifier.updateStatus(isCached);
    widget.onKeyStatusChanged(isCached);
    setState(() => _isKeyCached = isCached);
  }

  /// Shows the security key (when cached).

  Future<void> _handleShowKey(String title, BuildContext context) async {
    await SolidSecurityKeyManagerDialogs.showPrivateData(
      title,
      context,
      _isKeyCached,
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

  /// Handles the change security key action (when cached).

  Future<void> _handleChangeKey(BuildContext context) async {
    final changed = await SolidSecurityKeyManagerDialogs.showKeyInputDialog(
      context,
      widget.config.appWidget,
      () async {
        securityKeyNotifier.updateStatus(true);
        widget.onKeyStatusChanged(true);
        debugPrint('Security key changed, status remains: Cached Locally');
      },
    );

    // Dismiss the outer security key management dialogue once the key has
    // been successfully changed, so the user is not left staring at a stale
    // popup after completing the operation.

    if (changed && mounted && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Handles the cache security key action (when not cached).
  /// Prompts user to enter the security key, verifies it against POD's
  /// verification key, and caches it locally if valid.

  Future<void> _handleCacheKey(BuildContext context) async {
    // Check if user is logged in before attempting to cache the key.

    final isLoggedIn = await isUserLoggedIn();
    if (!mounted || !context.mounted) return;
    if (!isLoggedIn) {
      await SolidSecurityKeyManagerDialogs.handleLoginRedirect(context);
      return;
    }
    _keyController.clear();
    final result = await SolidSecurityKeyManagerDialogs.showCacheKeyDialog(
      context,
      _keyController,
    );
    if (result == null || result.isEmpty || !mounted) return;
    setState(() => _isLoading = true);
    try {
      // KeyManager.setSecurityKey() verifies the key against POD's verification
      // key and caches it locally if valid. Throws exception if invalid.

      await KeyManager.setSecurityKey(result);
      if (!mounted || !context.mounted) return;
      debugPrint('Security key verified and cached successfully');

      // Close the manager dialog FIRST to prevent UI flash.

      Navigator.of(context).pop();
      securityKeyNotifier.updateStatus(true);
      widget.onKeyStatusChanged(true);
      debugPrint('Security key status updated to: Cached Locally');
    } on Exception catch (e) {
      debugPrint('Failed to cache security key: $e');
      if (!mounted || !context.mounted) return;
      setState(() => _isLoading = false);

      await SolidSecurityKeyManagerDialogs.showInvalidKeyDialog(context);
    }
  }

  Future<void> _handleClearCache() async {
    final confirmed =
        await SolidSecurityKeyManagerUI.showClearCacheConfirmation(context);
    if (!confirmed || !mounted || !context.mounted) return;
    setState(() => _isLoading = true);
    try {
      await KeyManager.forgetSecurityKey();
      debugPrint('Local security key cache cleared successfully');
      if (!mounted || !context.mounted) return;
      Navigator.of(context).pop();
      securityKeyNotifier.updateStatus(false);
      widget.onKeyStatusChanged(false);
      debugPrint('Security key status updated to: Not Cached');
    } on Exception catch (e) {
      debugPrint('Error clearing cache: $e');
      if (!mounted || !context.mounted) return;
      setState(() => _isLoading = false);
      SecurityKeyUIHelpers.showErrorSnackBar(
        context,
        'Failed to clear cached security key: $e',
      );
    }
  }

  Future<void> _showKeyFileNotFoundDialog(BuildContext context) async {
    await SecurityKeyUIHelpers.showErrorDialog(
      context,
      'Security Key File Not Found',
      'The security key file could not be found on your POD. '
          'Please contact your administrator.',
    );
  }

  Widget _buildDialogContent(BuildContext context, String title) {
    return SolidSecurityKeyManagerUI.buildDialogContent(
      context,
      widget.config.title ?? 'Security Key Management',
      _isLoading,
      _isKeyCached,
      widget.config.showViewKeyButton,
      () async => await _handleShowKey(title, context),
      () async => await _handleChangeKey(context),
      () async => await _handleCacheKey(context),
      _handleClearCache,
      () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SolidSecurityKeyManagerUI.buildMainDialog(
      widget.config.title,
      (title) => _buildDialogContent(context, title),
    );
  }
}
