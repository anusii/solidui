/// Service for managing user profile data (avatar and display name) on POD.
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

import 'dart:convert' show utf8;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;

import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/services/solid_profile_notifier.dart';

/// Maximum allowed upload size for profile pictures (2 MB).

const int maxProfilePictureBytes = 2 * 1024 * 1024;

/// Allowed MIME extensions for profile pictures.

const Set<String> allowedProfileExtensions = {'.png', '.jpg', '.jpeg'};

/// Manages reading, writing, and deleting profile data on the user's POD.
///
/// Profile data lives under `<appDir>/profile/` and comprises an optional
/// avatar image (`avatar.png`) and an optional display name
/// (`display-name.txt`).

class SolidProfileService {
  SolidProfileService._();

  static final SolidProfileService _instance = SolidProfileService._();

  /// Singleton accessor.

  static SolidProfileService get instance => _instance;

  bool _initialised = false;

  // URL helpers.

  Future<String> _profileDirUrl() async {
    final appDir = SolidConstants.directories.app;
    return getDirUrl([appDir, profileDir].join('/'));
  }

  Future<String> _avatarUrl() async {
    final appDir = SolidConstants.directories.app;
    return getFileUrl([appDir, profileDir, profilePictureFile].join('/'));
  }

  Future<String> _displayNameUrl() async {
    final appDir = SolidConstants.directories.app;
    return getFileUrl([appDir, profileDir, displayNameFile].join('/'));
  }

  // Initialisation.

  /// Ensures the profile directory exists on the POD, creating it with an
  /// owner-only ACL if absent. Safe to call multiple times.

  Future<void> ensureProfileFolder() async {
    if (_initialised) return;
    if (!await isUserLoggedIn()) return;

    final dirUrl = await _profileDirUrl();
    final status = await checkResourceStatus(dirUrl, isFile: false);

    if (status == ResourceStatus.notExist) {
      await createResource(
        dirUrl,
        isFile: false,
        contentType: ResourceContentType.directory,
      );
    }

    _initialised = true;
  }

  // Load.

  /// Loads profile data from the POD into [solidProfileNotifier].

  Future<void> loadProfile() async {
    if (!await isUserLoggedIn()) return;

    solidProfileNotifier.isLoading = true;

    try {
      await ensureProfileFolder();
      await Future.wait([_loadAvatar(), _loadDisplayName()]);
    } catch (e) {
      debugPrint('SolidProfileService.loadProfile: $e');
    } finally {
      solidProfileNotifier.isLoading = false;
    }
  }

  Future<void> _loadAvatar() async {
    final url = await _avatarUrl();
    if (await checkResourceStatus(url) == ResourceStatus.exist) {
      final bytes = await getResource(url);
      solidProfileNotifier.setAvatar(bytes);
    }
  }

  Future<void> _loadDisplayName() async {
    final url = await _displayNameUrl();
    if (await checkResourceStatus(url) == ResourceStatus.exist) {
      final bytes = await getResource(url);
      solidProfileNotifier.setDisplayName(utf8.decode(bytes));
    }
  }

  // Save avatar.

  /// Writes [pngBytes] as the profile picture on the POD and updates the
  /// notifier. The bytes must be valid PNG data.

  Future<void> saveAvatar(Uint8List pngBytes) async {
    await ensureProfileFolder();
    final url = await _avatarUrl();

    await createResource(
      url,
      content: pngBytes,
      replaceIfExist: true,
      contentType: ResourceContentType.auto,
    );

    solidProfileNotifier.setAvatar(pngBytes);
  }

  // Delete avatar.

  /// Removes the profile picture from the POD.

  Future<void> deleteAvatar() async {
    final url = await _avatarUrl();
    if (await checkResourceStatus(url) == ResourceStatus.exist) {
      await deleteResource(url, ResourceContentType.binary);

      // Also remove the companion ACL if present.
      final aclUrl = '$url.acl';
      if (await checkResourceStatus(aclUrl) == ResourceStatus.exist) {
        await deleteResource(aclUrl, ResourceContentType.turtleText);
      }
    }
    solidProfileNotifier.setAvatar(null);
  }

  // Save display name.

  /// Persists [name] as the user's display name on the POD.

  Future<void> saveDisplayName(String name) async {
    await ensureProfileFolder();
    final url = await _displayNameUrl();

    await createResource(
      url,
      content: name,
      replaceIfExist: true,
      contentType: ResourceContentType.plainText,
    );

    solidProfileNotifier.setDisplayName(name);
  }

  // Clear local state.

  /// Resets cached state (call on logout).

  void clearCache() {
    _initialised = false;
    solidProfileNotifier.clear();
  }
}
