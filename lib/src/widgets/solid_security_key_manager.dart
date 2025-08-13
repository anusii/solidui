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
        AppInfo,
        KeyManager,
        SolidFunctionCallStatus,
        changeKeyPopup,
        deleteFile,
        getEncKeyPath,
        getWebId,
        readPod;

import 'solid_security_key_view.dart';

/// Configuration for the Security Key Manager.

class SolidSecurityKeyManagerConfig {
  /// The app widget to use for change key popup.

  final Widget appWidget;

  /// Custom title for the security key manager.

  final String? customTitle;

  /// Whether to show the 'Show Security Key' button.

  final bool showViewKeyButton;

  /// Whether to show the 'Forget Security Key' button.

  final bool showForgetKeyButton;

  const SolidSecurityKeyManagerConfig({
    required this.appWidget,
    this.customTitle,
    this.showViewKeyButton = true,
    this.showForgetKeyButton = true,
  });
}

/// Security Key Manager.
///
/// This class represents a dialogue interface for managing local security keys.
/// It provides features like showing the current security key, changing the key,
/// and forgetting the key locally altogether.

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
    // On initialisation, verify if a key is already saved.

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
    try {
      final hasKey = await KeyManager.hasSecurityKey();

      if (widget.onKeyStatusChanged != null) {
        widget.onKeyStatusChanged(hasKey);
      }

      setState(() {
        _hasExistingKey = hasKey;
      });
    } catch (e) {
      setState(() {
        _hasExistingKey = false;
      });
    }
  }

  /// Defines consistent button styles.

  ButtonStyle _getButtonStyle({bool isDestructive = false}) {
    final theme = Theme.of(context);
    return ElevatedButton.styleFrom(
      backgroundColor:
          isDestructive ? theme.colorScheme.error : theme.colorScheme.surface,
      foregroundColor:
          isDestructive ? theme.colorScheme.onError : theme.colorScheme.primary,
      side: BorderSide(
        color:
            isDestructive ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  /// Returns decoration for input fields.

  InputDecoration _getInputDecoration(String label) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: theme.colorScheme.outline),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  /// Handles the retrieval and display of security key information.

  Future<void> _showPrivateData(String title, BuildContext context) async {
    if (!_hasExistingKey) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Notice'),
          content: const Text(
              'No security key found. Please set a security key first.'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Show loading indicator while retrieving key data.

    setState(() {
      _isLoading = true;
    });

    try {
      final filePath = await getEncKeyPath();
      if (!context.mounted) return;

      final fileContent = await readPod(
        filePath,
        context,
        SolidSecurityKeyManager(
          config: widget.config,
          onKeyStatusChanged: widget.onKeyStatusChanged,
        ),
      );
      if (!context.mounted) return;

      // If key retrieval is successful, navigate to key display screen.

      if (![
        SolidFunctionCallStatus.notLoggedIn.toString(),
        SolidFunctionCallStatus.fail.toString()
      ].contains(fileContent)) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SolidSecurityKeyView(
              keyInfo: fileContent,
              title: title,
            ),
          ),
        );
      }
    } on Exception catch (e) {
      debugPrint('Exception: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Prompts the user to input or change a security key.

  Future<void> _showKeyInputDialog(BuildContext context) async {
    _keyController.clear();
    _confirmKeyController.clear();

    if (_hasExistingKey) {
      try {
        await changeKeyPopup(
          context,
          widget.config.appWidget,
        );
        widget.onKeyStatusChanged(true);
        await _checkKeyStatus();
      } catch (e) {
        if (context.mounted) {
          _showErrorSnackBar(context, e.toString());
        }
      } finally {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
      return;
    }

    // Display a dialogue for entering a new key.

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Set Security Key',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _keyController,
              decoration: _getInputDecoration('Enter Security Key'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmKeyController,
              decoration: _getInputDecoration('Confirm Security Key'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            style: _getButtonStyle(),
            onPressed: () => _handleKeySubmission(context),
            child: const Text(
              'Set Key',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  /// Submits and validates the entered security key.

  Future<void> _handleKeySubmission(BuildContext context) async {
    final key = _keyController.text;
    final confirmKey = _confirmKeyController.text;

    if (key.isEmpty || confirmKey.isEmpty) {
      _showErrorSnackBar(context, 'Please enter both keys');
      return;
    }

    if (key != confirmKey) {
      _showErrorSnackBar(context, 'Keys do not match');
      return;
    }

    try {
      setState(() => _isLoading = true);
      await KeyManager.initPodKeys(key);
      widget.onKeyStatusChanged(true);
      await _checkKeyStatus();

      if (context.mounted) {
        Navigator.of(context).pop();
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Security key set successfully'),
            backgroundColor: theme.colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Shows a snack bar with an error message.

  void _showErrorSnackBar(BuildContext context, String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Retrieves app information for the title.

  Future<({String name, String? webId})> _getInfo() async =>
      (name: await AppInfo.name, webId: await getWebId());

  /// Builds the content of the dialogue.

  Widget _buildDialogContent(BuildContext context, String title) {
    const smallGapV = SizedBox(height: 20.0);

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header.

            Container(
              color: Theme.of(context).colorScheme.surface,
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.config.customTitle ?? 'Security Key Management',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Interactive options.

            Container(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 32.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.config.showViewKeyButton) ...[
                          SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _hasExistingKey
                                    ? Theme.of(context).colorScheme.surface
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                foregroundColor: _hasExistingKey
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                side: BorderSide(
                                  color: _hasExistingKey
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _hasExistingKey
                                  ? () async {
                                      await _showPrivateData(title, context);
                                    }
                                  : null,
                              child: const Text('Show Security Key'),
                            ),
                          ),
                          smallGapV,
                        ],
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              foregroundColor:
                                  Theme.of(context).colorScheme.primary,
                              side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              await _showKeyInputDialog(context);
                            },
                            child: Text(
                                _hasExistingKey ? 'Change Key' : 'Set Key'),
                          ),
                        ),
                        if (_hasExistingKey &&
                            widget.config.showForgetKeyButton) ...[
                          smallGapV,
                          SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                foregroundColor:
                                    Theme.of(context).colorScheme.error,
                                side: BorderSide(
                                    color: Theme.of(context).colorScheme.error),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                final confirmed =
                                    await _showForgetKeyConfirmation(context);
                                if (!confirmed) return;

                                late String msg;
                                try {
                                  await KeyManager.forgetSecurityKey();
                                  final encKeyPath = await getEncKeyPath();
                                  await deleteFile(encKeyPath);
                                  widget.onKeyStatusChanged(false);
                                  await _checkKeyStatus();
                                  msg =
                                      'Successfully forgot local security key.';
                                } on Exception catch (e) {
                                  msg =
                                      'Failed to forget local security key: $e';
                                }

                                if (context.mounted) {
                                  await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      title: const Text('Notice'),
                                      content: Text(msg),
                                      actions: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              child: const Text('Forget Security Key'),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a confirmation dialogue before forgetting the security key.

  Future<bool> _showForgetKeyConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Confirm Delete',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to forget this security key?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                Text(
                  'This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                style: _getButtonStyle(isDestructive: true),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Builds the dialogue widget.

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: FutureBuilder<({String name, String? webId})>(
        future: _getInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final appName = snapshot.data?.name;
            final title = 'Security Key Management - '
                '${appName!.isNotEmpty ? appName[0].toUpperCase() + appName.substring(1) : ""}';
            return _buildDialogContent(context, title);
          } else {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(24.0),
              child: const Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
