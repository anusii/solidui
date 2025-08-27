/// Solid About Button.
///
// Time-stamp: <Monday 2025-08-25 09:43:05 +1000 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gap/gap.dart';
import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:solidui/src/constants/about.dart';
import 'package:solidui/src/widgets/solid_about_models.dart';

/// A button that shows an About dialogue when pressed.

class SolidAboutButton extends StatefulWidget {
  /// Configuration for the About dialogue.

  final SolidAboutConfig config;

  /// Optional colour for the button icon.

  final Color? color;

  const SolidAboutButton({
    super.key,
    required this.config,
    this.color,
  });

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
        blockSpacing: AboutConstants.markdownBlockSpacing, // Consistent spacing
      );

      children.add(
        MarkdownBody(
          data: wordWrap(config.text!),
          styleSheet: markdownStyleSheet,
          selectable: true,
          softLineBreak: true,
          onTapLink: (text, href, about) {
            if (href != null) {
              final Uri url = Uri.parse(href);
              launchUrl(url);
            }
          },
        ),
      );
    } else {
      // Fall back to children if text is not provided.

      children.addAll(config.children ?? []);
    }

    showAboutDialog(
      context: context,
      applicationName: applicationName,
      applicationVersion: applicationVersion,
      applicationIcon: config.applicationIcon,
      applicationLegalese: wordWrap(
        config.applicationLegalese ??
            '© ${DateTime.now().year} $applicationName\n\n',
      ),
      children: children,
    );
  }
}
