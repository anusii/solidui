/// Settings page - Demonstrates subpage navigation.
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

/// Settings page widget (accessed as a subpage, not in main menu).
///
/// This page demonstrates the bodyOverride feature of SolidScaffold.
/// It is not in the main navigation menu but is accessible via the
/// settings icon in the AppBar. Navigation back to menu pages is
/// handled automatically when clicking menu items.

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This page is accessed via bodyOverride (subpage navigation)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 32),
          _buildSettingsSection(
            context,
            'General',
            [
              _buildSettingTile(
                context,
                'Language',
                'English',
                Icons.language,
              ),
              _buildSettingTile(
                context,
                'Notifications',
                'Enabled',
                Icons.notifications,
              ),
              _buildSettingTile(
                context,
                'Auto-save',
                'Every 5 minutes',
                Icons.save,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            'Privacy & Security',
            [
              _buildSettingTile(
                context,
                'Two-factor Authentication',
                'Disabled',
                Icons.security,
              ),
              _buildSettingTile(
                context,
                'Data Encryption',
                'Enabled',
                Icons.lock,
              ),
              _buildSettingTile(
                context,
                'Privacy Mode',
                'Standard',
                Icons.privacy_tip,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            'Storage',
            [
              _buildSettingTile(
                context,
                'Cache Size',
                '156 MB',
                Icons.storage,
              ),
              _buildSettingTile(
                context,
                'Clear Cache',
                'Tap to clear',
                Icons.delete_sweep,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Subpage Navigation Demo',
                        style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This Settings page is not in the main navigation menu. '
                        'It is accessed via the settings icon in the AppBar and '
                        'displayed using the bodyOverride parameter.\n\n'
                        'Click any navigation menu item (Home, Files, About) to '
                        'return to that page. No back button needed!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
      BuildContext context,
      String title,
      List<Widget> children,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        debugPrint('Tapped: $title');
      },
    );
  }
}
