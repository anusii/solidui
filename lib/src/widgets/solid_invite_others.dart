/// Invite Others widget.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
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
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import 'package:solidui/src/widgets/solid_invite_others_models.dart';

/// An icon button that triggers the Invite Others flow when pressed.
///
/// This widget can be embedded anywhere in the app: as an AppBar
/// action, inside an information dialogue, in a navigation menu, or
/// as a follow-up step from another flow (for example, when granting
/// permission has failed because the recipient has not yet logged
/// in to the application).

class InviteOthers extends StatelessWidget {
  /// Configuration for the Invite Others flow.

  final SolidInviteOthersConfig config;

  /// Optional colour for the icon.

  final Color? color;

  /// Optional icon size override (matches the surrounding icon
  /// theme by default).

  final double? iconSize;

  const InviteOthers({
    super.key,
    required this.config,
    this.color,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final iconButton = IconButton(
      icon: Icon(config.effectiveIcon, size: iconSize ?? 22),
      onPressed: () => InviteOthersDialog.show(context, config: config),
      color: color,
      splashRadius: 20,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );

    return MarkdownTooltip(
      message: config.effectiveTooltip,
      child: iconButton,
    );
  }
}

/// Static helpers for showing the Invite Others dialogue.

class InviteOthersDialog {
  InviteOthersDialog._();

  /// Shows the Invite Others dialogue. If [config.onPressed] is
  /// set, the callback is invoked instead so apps can plug in their
  /// own invite flow.

  static Future<void> show(
    BuildContext context, {
    required SolidInviteOthersConfig config,
    String? prefixMessage,
  }) async {
    if (config.onPressed != null) {
      config.onPressed!();
      return;
    }

    final resolved = await _resolveAppMetadata(config);
    if (!context.mounted) return;

    final message = config.buildMessage(
      resolvedAppName: resolved.appName,
      resolvedAppUrl: resolved.appUrl,
    );

    final composedMessage =
        prefixMessage == null ? message : '$prefixMessage\n\n$message';

    final subject =
        config.subject ?? 'Try the ${resolved.appName} app on your Solid POD';

    await showDialog<void>(
      context: context,
      // useRootNavigator: false keeps the dialog within the nearest Navigator
      // ancestor (the SolidScaffold). Using the default true on macOS pushes
      // the route to the root Navigator, which causes the LayoutBuilder in
      // SolidScaffold to receive different constraints and incorrectly hides
      // the NavigationRail (LHS menu) while the dialog is open.
      useRootNavigator: false,
      builder: (dialogContext) => _InviteOthersPopup(
        config: config,
        message: composedMessage,
        subject: subject,
        appName: resolved.appName,
      ),
    );
  }

  /// Resolves the application name and URL using the provided
  /// configuration, falling back to `PackageInfo` when the name has
  /// not been supplied.

  static Future<({String appName, String appUrl})> _resolveAppMetadata(
    SolidInviteOthersConfig config,
  ) async {
    String appName = config.applicationName ?? '';
    if (appName.isEmpty) {
      try {
        final info = await PackageInfo.fromPlatform();
        appName = info.appName;
      } catch (e) {
        debugPrint('InviteOthers: PackageInfo lookup failed: $e');
        appName = 'this app';
      }
    }
    final appUrl = config.appUrl ?? '';
    return (appName: appName, appUrl: appUrl);
  }
}

/// A centred popup dialogue that offers sharing actions without
/// displaying the invitation text for editing.

class _InviteOthersPopup extends StatefulWidget {
  final SolidInviteOthersConfig config;
  final String message;
  final String subject;
  final String appName;

  const _InviteOthersPopup({
    required this.config,
    required this.message,
    required this.subject,
    required this.appName,
  });

  @override
  State<_InviteOthersPopup> createState() => _InviteOthersPopupState();
}

class _InviteOthersPopupState extends State<_InviteOthersPopup> {
  bool _copied = false;

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.message));
    if (!mounted) return;
    setState(() => _copied = true);
  }

  Future<void> _shareViaSystem() async {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final origin =
        box != null ? (box.localToGlobal(Offset.zero) & box.size) : Rect.zero;

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: widget.message,
          subject: widget.subject,
          sharePositionOrigin: origin,
        ),
      );
    } catch (e) {
      debugPrint('InviteOthers: SharePlus.share failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sharing is not available on this device: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 12, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      widget.config.effectiveIcon,
                      size: 22,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Invite others to ${widget.appName}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  MarkdownTooltip(
                    message: '''

                    **Close**

                    Dismiss this dialogue.

                    ''',
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  'Choose how to send the invitation. '
                  'You can edit the message in the app you choose.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: MarkdownTooltip(
                        message: '''

                        **Copy to Clipboard**

                        Copy the invitation message to the clipboard
                        so you can paste it into any chat, email, or
                        note-taking app.

                        ''',
                        child: OutlinedButton.icon(
                          onPressed: _copied ? null : _copyToClipboard,
                          icon: Icon(
                            _copied ? Icons.check : Icons.copy,
                            size: 18,
                          ),
                          label: Text(_copied ? 'Copied' : 'Copy'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MarkdownTooltip(
                        message: '''

                        **Share via App**

                        Open your device's share sheet to forward the
                        invitation through any installed messaging or
                        email application.

                        ''',
                        child: FilledButton.icon(
                          onPressed: _shareViaSystem,
                          icon: const Icon(Icons.send, size: 18),
                          label: const Text('Share'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
