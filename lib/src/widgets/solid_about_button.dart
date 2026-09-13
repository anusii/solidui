/// Solid About Button.
///
// Time-stamp: <Friday 2026-06-12 10:10:22 +1000 Graham Williams>
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
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:gap/gap.dart';
import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:solidui/src/constants/about.dart';
import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_feedback_models.dart';
import 'package:solidui/src/widgets/solid_invite_others.dart';
import 'package:solidui/src/widgets/solid_preferences_dialog.dart';

/// A button that shows an About dialogue when pressed.

class SolidAboutButton extends StatefulWidget {
  /// Configuration for the About dialogue.

  final SolidAboutConfig config;

  /// Optional colour for the button icon.

  final Color? color;

  const SolidAboutButton({super.key, required this.config, this.color});

  @override
  State<SolidAboutButton> createState() => _SolidAboutButtonState();
}

class _SolidAboutButtonState extends State<SolidAboutButton> {
  String? _packageName;
  String? _version;
  String? _buildNumber;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _packageName = packageInfo.appName;
          _version = packageInfo.version;
          _buildNumber = packageInfo.buildNumber;
        });
      }
    } catch (e) {
      debugPrint('Error loading package info: $e');
    }
  }

  void _showAboutDialog() {
    if (widget.config.onPressed != null) {
      widget.config.onPressed!();
      return;
    }

    if (widget.config.customContent != null) {
      _showCustomAboutDialog();
      return;
    }

    _showDefaultAboutDialog();
  }

  void _showCustomAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: widget.config.customContent,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showDefaultAboutDialog() {
    final applicationName =
        widget.config.applicationName ?? _packageName ?? 'Application';

    final applicationVersion = widget.config.applicationVersion ??
        (_version != null && _buildNumber != null
            ? '$_version+$_buildNumber'
            : _version) ??
        '1.0.0';

    SolidAbout._showAboutDialogHelper(
      context: context,
      applicationName: applicationName,
      applicationVersion: applicationVersion,
      config: widget.config,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget iconButton = IconButton(
      icon: Icon(widget.config.effectiveIcon),
      onPressed: _showAboutDialog,
      color: widget.color,
    );

    // Wrap with MarkdownTooltip.

    return MarkdownTooltip(
      message: widget.config.effectiveTooltip,
      child: iconButton,
    );
  }
}

/// Strips common leading whitespace from a triple-quoted string without
/// hard-wrapping lines. Preserves blank lines as paragraph breaks for markdown.
String _dedent(String text) {
  final lines = text.split('\n').map((l) => l.trimLeft()).toList();
  return lines.join('\n').trim();
}

/// A static helper for showing About dialogues programmatically.

class SolidAbout {
  /// Shows an About dialogue with the given configuration.

  static void show(BuildContext context, SolidAboutConfig config) {
    if (config.onPressed != null) {
      config.onPressed!();
      return;
    }

    if (config.customContent != null) {
      _showCustomAboutDialog(context, config);
      return;
    }

    _showDefaultAboutDialog(context, config);
  }

  static void _showCustomAboutDialog(
    BuildContext context,
    SolidAboutConfig config,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: config.customContent,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _showDefaultAboutDialog(
    BuildContext context,
    SolidAboutConfig config,
  ) async {
    String? packageName;
    String? version;
    String? buildNumber;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      packageName = packageInfo.appName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    } catch (e) {
      debugPrint('Error loading package info: $e');
    }

    final applicationName =
        config.applicationName ?? packageName ?? 'Application';

    final applicationVersion = config.applicationVersion ??
        (version != null && buildNumber != null
            ? '$version+$buildNumber'
            : version) ??
        '1.0.0';

    if (context.mounted) {
      _showAboutDialogHelper(
        context: context,
        applicationName: applicationName,
        applicationVersion: applicationVersion,
        config: config,
      );
    }
  }

  /// Shows a default About dialogue with minimal configuration.

  static void showDefault(
    BuildContext context, {
    String? applicationName,
    String? applicationVersion,
    Widget? applicationIcon,
    String? applicationLegalese,
    List<Widget>? children,
  }) {
    final config = SolidAboutConfig(
      applicationName: applicationName,
      applicationVersion: applicationVersion,
      applicationIcon: applicationIcon,
      applicationLegalese: applicationLegalese,
      children: children,
    );

    show(context, config);
  }

  /// Helper method to show About dialogue with consistent formatting.

  static void _showAboutDialogHelper({
    required BuildContext context,
    required String applicationName,
    required String applicationVersion,
    required SolidAboutConfig config,
  }) {
    // Build children based on provided configuration.

    List<Widget> children = [];

    // If text is provided, use it with MarkdownBody.

    if (config.text != null && config.text!.isNotEmpty) {
      children.add(const Gap(AboutConstants.contentVerticalSpacing));

      // Get the same text style as applicationLegalese.

      final textTheme = Theme.of(context).textTheme;
      final bodySmallStyle = textTheme.bodySmall;

      // Create MarkdownStyleSheet to match legalese formatting.

      final cs = Theme.of(context).colorScheme;

      final markdownStyleSheet = MarkdownStyleSheet(
        p: bodySmallStyle,
        h1: bodySmallStyle?.copyWith(fontWeight: FontWeight.bold),
        h2: bodySmallStyle?.copyWith(fontWeight: FontWeight.bold),
        h3: bodySmallStyle?.copyWith(fontWeight: FontWeight.bold),
        h4: bodySmallStyle?.copyWith(fontWeight: FontWeight.bold),
        h5: bodySmallStyle?.copyWith(fontWeight: FontWeight.bold),
        h6: bodySmallStyle?.copyWith(fontWeight: FontWeight.bold),
        strong: bodySmallStyle?.copyWith(fontWeight: FontWeight.bold),
        em: bodySmallStyle?.copyWith(fontStyle: FontStyle.italic),
        listBullet: bodySmallStyle,
        a: bodySmallStyle?.copyWith(
          color: cs.primary,
          decoration: TextDecoration.underline,
        ),
        blockSpacing: AboutConstants.markdownBlockSpacing,
        code: bodySmallStyle?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: Colors.transparent,
        ),
        codeblockDecoration: const BoxDecoration(color: Colors.transparent),
      );

      children.add(
        MarkdownBody(
          data: _dedent(config.text!),
          styleSheet: markdownStyleSheet,
          softLineBreak: false,
          onTapLink: (text, href, title) {
            if (href != null) {
              launchUrl(Uri.parse(href));
            }
          },
        ),
      );
    } else {
      // Fall back to children if text is not provided.

      children.addAll(config.children ?? []);
    }

    // Build the action row shown at the bottom of the About dialog.
    //
    // The row contains the Share (Invite Others) and Feedback buttons.
    // Share is rendered only when an invite configuration is supplied.
    // Feedback is always rendered: if a feedback configuration is missing
    // or disabled, the button is greyed out as a placeholder so the visual
    // layout stays consistent and the integration point is preserved for
    // future releases.

    final actionButtons = <Widget>[];

    // 20260913 gjw The AppBar and Menu buttons that used to open a dialogue
    // each are now sections of the one Settings dialogue, reached from the
    // profile menu so that the word Settings names one thing in one place.
    // About is left to be about the app.
    //
    // An app with [enableProfile] turned off has no profile menu to reach
    // Settings through, so it keeps the button here rather than losing its
    // settings altogether. Each app's existing flags still decide which
    // sections it offers.

    if (!config.profileEnabled &&
        (config.showLayoutPreferences || config.showMenuLayoutPreferences)) {
      actionButtons.add(
        Builder(
          builder: (dialogContext) => MarkdownTooltip(
            message: '''

            **Settings**

            Customise which buttons appear in the AppBar, hide the ones you do
            not need, and reorder them to taste. For narrow screens choose
            whether the menu navigation items sit along the bottom or inside
            the menu drawer (hamburger menu); the webid, login and security key
            status always remain with the menu drawer. On the desktop set the
            size of the app window, and whether the size you leave it at is
            remembered for next time.

            ''',
            child: TextButton.icon(
              icon: const Icon(Icons.tune),
              label: const Text('Settings'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                SolidPreferencesDialog.show(
                  context,
                  showAppBarSection: config.showLayoutPreferences,
                  showMenuSection: config.showMenuLayoutPreferences,
                  scaffoldMenuInBottomBar: config.scaffoldMenuInBottomBar,
                );
              },
            ),
          ),
        ),
      );
    }

    if (config.inviteConfig != null && config.inviteConfig!.enabled) {
      actionButtons.add(
        Builder(
          builder: (dialogContext) => MarkdownTooltip(
            message: config.inviteConfig!.effectiveTooltip,
            child: TextButton.icon(
              icon: Icon(config.inviteConfig!.effectiveIcon),
              label: const Text('Invite'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                InviteOthersDialog.show(
                  context,
                  config: config.inviteConfig!,
                );
              },
            ),
          ),
        ),
      );
    }

    // README button — shown when a readmeUrl is provided.

    if (config.readmeUrl != null && config.readmeUrl!.isNotEmpty) {
      actionButtons.add(
        MarkdownTooltip(
          message: '''

          **README**

          Open the application README in your browser for full
          documentation and setup instructions.

          ''',
          child: TextButton.icon(
            icon: const Icon(Icons.menu_book_outlined),
            label: const Text('README'),
            onPressed: () => launchUrl(
              Uri.parse(config.readmeUrl!),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ),
      );
    }

    // Always show Feedback: enabled when a configuration is supplied,
    // greyed out otherwise.

    final feedback = config.feedbackConfig;
    final feedbackInteractive = feedback?.isInteractive ?? false;
    actionButtons.add(
      Builder(
        builder: (dialogContext) => MarkdownTooltip(
          message: feedback?.effectiveTooltip ??
              const SolidFeedbackConfig(enabled: false).effectiveTooltip,
          child: TextButton.icon(
            icon: Icon(feedback?.effectiveIcon ?? Icons.feedback_outlined),
            label: Text(feedback?.effectiveLabel ?? 'Feedback'),
            onPressed: feedbackInteractive
                ? () {
                    Navigator.of(dialogContext).pop();
                    if (feedback!.onPressed != null) {
                      feedback.onPressed!();
                    } else if (feedback.url != null &&
                        feedback.url!.isNotEmpty) {
                      launchUrl(Uri.parse(feedback.url!));
                    }
                  }
                : null,
          ),
        ),
      ),
    );

    if (actionButtons.isNotEmpty) {
      children.add(const Gap(AboutConstants.contentVerticalSpacing));
      children.add(const Divider());
      children.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: actionButtons,
          ),
        ),
      );
    }

    // showAboutDialog is equivalent to showDialog(builder: AboutDialog).
    // We replicate that here so we can inject a Theme that caps the
    // dialog width at 600px — roughly 100 characters of body text.
    showDialog<void>(
      context: context,
      builder: (ctx) => Theme(
        data: Theme.of(ctx).copyWith(
          dialogTheme: Theme.of(ctx).dialogTheme.copyWith(
                constraints: const BoxConstraints(maxWidth: 600),
              ),
        ),
        child: AboutDialog(
          applicationName: applicationName,
          applicationVersion: applicationVersion,
          applicationIcon: config.applicationIcon,
          applicationLegalese: config.applicationLegalese ??
              '© ${DateTime.now().year} $applicationName\n\n',
          children: children,
        ),
      ),
    );
  }
}
