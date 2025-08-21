/// Solid About Button.
///
// Time-stamp: <Thursday 2025-08-21 15:20:34 +1000 Tony Chen>
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
import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

    showAboutDialog(
      context: context,
      applicationName: applicationName,
      applicationVersion: applicationVersion,
      applicationIcon: widget.config.applicationIcon,
      applicationLegalese: widget.config.applicationLegalese ??
          '© ${DateTime.now().year} $applicationName\n\n',
      children: widget.config.children ?? [],
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
      BuildContext context, SolidAboutConfig config) {
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
      BuildContext context, SolidAboutConfig config) async {
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
      showAboutDialog(
        context: context,
        applicationName: applicationName,
        applicationVersion: applicationVersion,
        applicationIcon: config.applicationIcon,
        applicationLegalese: config.applicationLegalese ??
            '© ${DateTime.now().year} $applicationName\n\n',
        children: config.children ?? [],
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
}
