/// The application's home page with POD data storage demonstration.
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the MIT License (the "License").
///
/// License: https://choosealicense.com/licenses/mit/.

library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:solidpod/solidpod.dart';
import 'package:solidui/solidui.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

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
