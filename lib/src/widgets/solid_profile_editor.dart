/// Full-screen or dialog editor for profile picture and display name.
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

import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:solidpod/solidpod.dart' show isUserLoggedIn;

import 'package:solidui/src/services/solid_profile_notifier.dart';
import 'package:solidui/src/services/solid_profile_service.dart';
import 'package:solidui/src/widgets/solid_profile_avatar.dart';
import 'package:solidui/src/widgets/solid_profile_crop_dialog.dart';
import 'package:solidui/src/widgets/solid_webid_section.dart';

/// A dialog that lets the user upload/change/delete a profile picture and
/// set a display name. Changes are persisted to the user's Solid POD.

class SolidProfileEditor extends StatefulWidget {
  const SolidProfileEditor({super.key});

  /// Opens the editor as a modal dialog.

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SolidProfileEditor(),
    );
  }

  @override
  State<SolidProfileEditor> createState() => _SolidProfileEditorState();
}

class _SolidProfileEditorState extends State<SolidProfileEditor> {
  late final TextEditingController _nameController;
  Uint8List? _pendingAvatar;
  bool _avatarRemoved = false;
  bool _isSaving = false;
  late SolidProfilePrivacy _pendingPrivacy;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: solidProfileNotifier.displayName ?? '',
    );
    _pendingAvatar = solidProfileNotifier.avatarBytes;
    _pendingPrivacy = solidProfileNotifier.privacy;

    // The WebID section reads/writes the user's own Pod, so it only makes
    // sense to show it while a session is active.

    isUserLoggedIn().then((loggedIn) {
      if (mounted) setState(() => _loggedIn = loggedIn);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    final nameChanged =
        _nameController.text.trim() != (solidProfileNotifier.displayName ?? '');
    final avatarChanged =
        _avatarRemoved ||
        !identical(_pendingAvatar, solidProfileNotifier.avatarBytes);
    final privacyChanged = _pendingPrivacy != solidProfileNotifier.privacy;
    return nameChanged || avatarChanged || privacyChanged;
  }

  // Image picking.

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    if (bytes.length > maxProfilePictureBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image must be smaller than 2 MB')),
        );
      }
      return;
    }

    // Open crop dialog.
    if (!mounted) return;
    final cropped = await SolidProfileCropDialog.show(context, bytes);
    if (cropped != null && mounted) {
      setState(() {
        _pendingAvatar = cropped;
        _avatarRemoved = false;
      });
    }
  }

  void _removeAvatar() {
    setState(() {
      _pendingAvatar = null;
      _avatarRemoved = true;
    });
  }

  // Save.

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final service = SolidProfileService.instance;

      // Apply privacy first so subsequent writes use the correct mode and
      // ACL. setPrivacy is a no-op when the mode hasn't changed.

      if (_pendingPrivacy != solidProfileNotifier.privacy) {
        await service.setPrivacy(_pendingPrivacy);
      }

      // Avatar changes.
      if (_avatarRemoved) {
        await service.deleteAvatar();
      } else if (_pendingAvatar != null &&
          !identical(_pendingAvatar, solidProfileNotifier.avatarBytes)) {
        await service.saveAvatar(_pendingAvatar!);
      }

      // Display name changes.
      final newName = _nameController.text.trim();
      if (newName != (solidProfileNotifier.displayName ?? '')) {
        await service.saveDisplayName(newName);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Profile save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Privacy selector.

  Widget _buildPrivacySelector(ThemeData theme) {
    final isPrivate = _pendingPrivacy == SolidProfilePrivacy.private;
    final summary = isPrivate
        ? 'Encrypted on your POD; only you can read it.'
        : 'Stored as plaintext linked data; readable by anyone with the URL.';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPrivate ? Icons.lock_outline : Icons.public,
                size: 18,
                color: theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(
                'Profile visibility',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<SolidProfilePrivacy>(
            segments: const [
              ButtonSegment(
                value: SolidProfilePrivacy.private,
                label: Text('Private'),
                icon: Icon(Icons.lock_outline, size: 16),
              ),
              ButtonSegment(
                value: SolidProfilePrivacy.public,
                label: Text('Public'),
                icon: Icon(Icons.public, size: 16),
              ),
            ],
            selected: {_pendingPrivacy},
            onSelectionChanged: _isSaving
                ? null
                : (values) => setState(() => _pendingPrivacy = values.first),
          ),
          const SizedBox(height: 6),
          Text(
            summary,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // Build.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAvatar = _pendingAvatar != null && _pendingAvatar!.isNotEmpty;

    // Scale the dialog with the window instead of a fixed width — the raw
    // WebID turtle content in SolidWebIdSection is much easier to read with
    // more horizontal room on larger windows, while narrow/mobile windows
    // still get a dialog sized to fit comfortably.

    final windowSize = MediaQuery.of(context).size;
    final dialogWidth = (windowSize.width * 0.9).clamp(320.0, 640.0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: windowSize.height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Profile',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // Avatar preview with action buttons.
              Stack(
                alignment: Alignment.center,
                children: [
                  if (hasAvatar)
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: MemoryImage(_pendingAvatar!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    const SolidProfileAvatar(size: 120),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _isSaving ? null : _pickImage,
                    icon: const Icon(Icons.upload, size: 18),
                    label: Text(hasAvatar ? 'Change Photo' : 'Upload Photo'),
                  ),
                  if (hasAvatar)
                    TextButton.icon(
                      onPressed: _isSaving ? null : _removeAvatar,
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: theme.colorScheme.error,
                      ),
                      label: Text(
                        'Remove',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // Display name input.
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'Enter your display name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 16),

              // Privacy toggle. Defaults to private (encrypted, owner-only)
              // so apps that already encrypt user data keep the profile
              // private as well. Users may opt in to a public profile if
              // they want their display name and avatar to be discoverable.
              _buildPrivacySelector(theme),

              if (_loggedIn) ...[
                const SizedBox(height: 16),

                // WebID viewer and Pod-linking entry point. Only shown while
                // logged in since it reads/writes the user's own WebID
                // document on their Pod.
                const SolidWebIdSection(),
              ],

              const SizedBox(height: 24),

              // Action buttons.
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: (_isSaving || !_hasChanges) ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
