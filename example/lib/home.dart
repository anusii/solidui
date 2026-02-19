/// A screen to demonstrate various capabilities of solidlogin.
///
// Time-stamp: <Wednesday 2025-09-17 08:23:30 +1000 Graham Williams>
///
/// Copyright (C) 2024, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://opensource.org/license/gpl-3-0.
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
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
///
///
/// Authors: Zheyuan Xu, Anushka Vidanage, Kevin Wang, Dawei Chen, Graham Williams

// TODO 20240411 gjw EITHER REPAIR ALL CONTEXT ISSUES OR EXPLAIN WHY NOT?

// ignore_for_file: use_build_context_synchronously

library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:solidpod/solidpod.dart';
import 'package:solidui/solidui.dart';

import 'package:intl/intl.dart';
import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:solidpod/solidpod.dart';
import 'package:solidui/solidui.dart'
    show
        GrantPermissionUi,
        InitialSetupScreenBody,
        SharedResourcesUi,
        SolidScaffold,
        changeKeyPopup,
        getKeyFromUserIfRequired,
        largeGapV,
        loginIfRequired,
        logoutPopup,
        smallGapV;

import 'package:demopod/app.dart';
import 'package:demopod/constants/app.dart';
import 'package:demopod/dialogs/alert.dart';
import 'package:demopod/features/create_acl_inherited_file.dart';
import 'package:demopod/features/edit_keyvalue.dart';
import 'package:demopod/features/file_service.dart';
import 'package:demopod/features/permission_callback_demo.dart';
import 'package:demopod/features/read_acl_inherited_file.dart';
import 'package:demopod/features/view_keys.dart';
import 'package:demopod/utils/rdf.dart';

/// A widget for the demonstration screen of the application.

class Home extends StatefulWidget {
  /// Initialise widget variables.

  final String title;

  const Home({super.key, this.title = 'Home'});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final appDataPath = await getDataDirPath();
      final filePath = PathUtils.combine(appDataPath, 'user_info.enc.ttl');

      final content = await readPod(filePath, pathType: PathType.relativeToPod);

      if (content != SolidFunctionCallStatus.fail.toString() &&
          content != SolidFunctionCallStatus.notLoggedIn.toString() &&
          content.isNotEmpty) {
        final data = jsonDecode(content);
        _nameController.text = data['name'] ?? '';
        _commentController.text = data['comment'] ?? '';
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Ensure the security key is available before writing encrypted data.
      await getKeyFromUserIfRequired(
        context,
        const Text('Please enter your security key to save the data'),
      );

      if (!mounted) return;

      final data = {
        'name': _nameController.text,
        'comment': _commentController.text,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      final appDataPath = await getDataDirPath();
      final filePath = PathUtils.combine(appDataPath, 'user_info.enc.ttl');

      await writePod(
        filePath,
        jsonEncode(data),
        encrypted: true,
        pathType: PathType.relativeToPod,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data saved to POD successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.home,
                            size: 48,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'POD Data Storage Example',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This data is stored securely and encrypted on your POD.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'NAME',
                          hintText: 'Enter your name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          labelText: 'COMMENT',
                          hintText: 'Enter a comment',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.comment),
                        ),
                        maxLines: 3,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveData,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: const Text('Save to POD'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About SolidUI',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome to the SolidUI Template App!\n\n'
                        'This template demonstrates the key features of SolidUI:\n\n'
                        '• Responsive navigation (rail ↔ drawer)\n'
                        '• Theme switching (light/dark/system)\n'
                        '• Customisable About dialogues\n'
                        '• Version information display\n'
                        '• Security key management\n'
                        '• Status bar integration\n'
                        '• User information display\n\n'
                        'Explore the different tabs to see these features in action!',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
