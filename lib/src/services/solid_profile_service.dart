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

import 'dart:async' show unawaited;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/services/solid_profile_cache.dart';
import 'package:solidui/src/services/solid_profile_notifier.dart';
import 'package:solidui/src/services/solid_profile_turtle.dart';

/// Maximum allowed upload size for profile pictures (2 MB).

const int maxProfilePictureBytes = 2 * 1024 * 1024;

/// Allowed MIME extensions for profile pictures.

const Set<String> allowedProfileExtensions = {'.png', '.jpg', '.jpeg'};

// SharedPreferences key prefix for the per-WebID privacy preference.

const String _privacyPrefKey = 'solidui_profile_privacy_';

/// Manages reading, writing, and deleting profile data on the user's POD.

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

  // Path arguments for writePod / readPod (relative to the app directory).

  String get _avatarRelPath => [profileDir, profilePictureFile].join('/');

  String get _displayNameRelPath => [profileDir, displayNameFile].join('/');

  // Initialisation.

  /// Ensures the profile directory (and its `.acl`) exist on the POD and
  /// loads the user's privacy preference from local storage. Safe to call
  /// multiple times — it only marks itself as initialised once both the
  /// directory and its ACL have been confirmed to exist.

  Future<void> ensureProfileFolder() async {
    if (_initialised) return;
    if (!await isUserLoggedIn()) return;

    await _loadPrivacyPreference();

    final dirUrl = await _profileDirUrl();

    // Create the folder if it is missing. We deliberately do not swallow
    // exceptions here so that the caller can surface a meaningful error
    // and a future call will retry.

    final dirStatus = await checkResourceStatus(dirUrl, isFile: false);
    if (dirStatus == ResourceStatus.notExist) {
      await createResource(
        dirUrl,
        isFile: false,
        contentType: ResourceContentType.directory,
      );
    }

    // Always make sure the folder's ACL is in place. This recovers PODs
    // whose profile directory was created without an ACL (e.g. by an older
    // version of the app, or via the server admin UI).

    final aclUrl = '$dirUrl.acl';
    final aclStatus = await checkResourceStatus(aclUrl);
    if (aclStatus != ResourceStatus.exist) {
      await _writeFolderAcl(solidProfileNotifier.privacy);
    }

    _initialised = true;
  }

  // Load.

  Future<void> loadProfile() async {
    if (!await isUserLoggedIn()) return;

    solidProfileNotifier.isLoading = true;

    // 20260718 gjw Show the last-seen avatar and display name immediately
    // from the local cache, before any Pod round trips, so the stock
    // placeholder is only ever visible on a genuine first launch. The
    // Pod load below then refreshes the notifier (and the cache) with
    // the authoritative data.

    await SolidProfileCache.instance.prime(solidProfileNotifier);

    try {
      await ensureProfileFolder();

      // 20260718 gjw Run the privacy detection concurrently with the
      // avatar and display name loads rather than before them. readPod
      // detects encryption per file, so the loads do not depend on the
      // privacy state, which only governs subsequent writes. This takes
      // the detection's round trips off the avatar's critical path.

      await Future.wait([
        _syncPrivacyFromPod(),
        _loadAvatar(),
        _loadDisplayName(),
      ]);
    } catch (e) {
      debugPrint('SolidProfileService.loadProfile: $e');
    } finally {
      solidProfileNotifier.isLoading = false;
    }
  }

  // Check the actual encryption status on the POD to sync multi-session
  // state, updating the notifier and the persisted preference.

  Future<void> _syncPrivacyFromPod() async {
    final detectedPrivacy = await _detectPrivacyFromPod();
    if (detectedPrivacy != null) {
      solidProfileNotifier.setPrivacy(detectedPrivacy);
      await _persistPrivacyPreference(detectedPrivacy);
    }
  }

  Future<void> _loadAvatar() async {
    final url = await _avatarUrl();
    if (await checkResourceStatus(url) != ResourceStatus.exist) {
      // 20260718 gjw The avatar was removed on the Pod (e.g. from another
      // device), so drop any cached copy the prime step may have shown.

      solidProfileNotifier.setAvatar(null);
      await SolidProfileCache.instance.writeAvatar(null);
      return;
    }

    try {
      final ttl = await readPod(url, pathType: PathType.absoluteUrl);
      final bytes = extractAvatarBytes(ttl);
      solidProfileNotifier.setAvatar(bytes);
      await SolidProfileCache.instance.writeAvatar(bytes);
    } catch (e) {
      debugPrint('SolidProfileService._loadAvatar: $e');
    }
  }

  Future<void> _loadDisplayName() async {
    final url = await _displayNameUrl();
    if (await checkResourceStatus(url) != ResourceStatus.exist) {
      solidProfileNotifier.setDisplayName(null);
      await SolidProfileCache.instance.writeDisplayName(null);
      return;
    }

    try {
      final ttl = await readPod(url, pathType: PathType.absoluteUrl);
      final name = extractDisplayName(ttl);
      if (name != null) {
        solidProfileNotifier.setDisplayName(name);
        await SolidProfileCache.instance.writeDisplayName(name);
      }
    } catch (e) {
      debugPrint('SolidProfileService._loadDisplayName: $e');
    }
  }

  // Save avatar.

  /// Writes [pngBytes] as the profile picture on the POD and updates the
  /// notifier. The bytes must be valid PNG data.

  Future<void> saveAvatar(Uint8List pngBytes) async {
    await ensureProfileFolder();
    final url = await _avatarUrl();
    final ttl = buildAvatarTtl(await getWebId() ?? '', pngBytes);

    final exists = await checkResourceStatus(url) == ResourceStatus.exist;
    await writePod(
      _avatarRelPath,
      ttl,
      pathType: PathType.relativeToApp,
      encrypted: solidProfileNotifier.privacy == SolidProfilePrivacy.private,
      createAcl: false,
      overwrite: exists,
    );

    solidProfileNotifier.setAvatar(pngBytes);
    await SolidProfileCache.instance.writeAvatar(pngBytes);
  }

  // Delete avatar.

  /// Removes the profile picture from the POD.

  Future<void> deleteAvatar() async {
    final url = await _avatarUrl();
    if (await checkResourceStatus(url) == ResourceStatus.exist) {
      await deleteResource(url, ResourceContentType.turtleText);

      final aclUrl = '$url.acl';
      if (await checkResourceStatus(aclUrl) == ResourceStatus.exist) {
        await deleteResource(aclUrl, ResourceContentType.turtleText);
      }
    }
    solidProfileNotifier.setAvatar(null);
    await SolidProfileCache.instance.writeAvatar(null);
  }

  // Save display name.

  /// Persists [name] as the user's display name on the POD as linked data.

  Future<void> saveDisplayName(String name) async {
    await ensureProfileFolder();
    final url = await _displayNameUrl();
    final ttl = buildDisplayNameTtl(await getWebId() ?? '', name);

    final exists = await checkResourceStatus(url) == ResourceStatus.exist;
    await writePod(
      _displayNameRelPath,
      ttl,
      pathType: PathType.relativeToApp,
      encrypted: solidProfileNotifier.privacy == SolidProfilePrivacy.private,
      createAcl: false,
      overwrite: exists,
    );

    solidProfileNotifier.setDisplayName(name);
    await SolidProfileCache.instance.writeDisplayName(name);
  }

  // Privacy preference.

  /// Switches the profile between [SolidProfilePrivacy.private] (encrypted
  /// at rest, owner-only ACL) and [SolidProfilePrivacy.public] (plaintext
  /// linked data, public read ACL). Existing data is rewritten under the
  /// new mode and the folder's ACL is updated accordingly.

  Future<void> setPrivacy(SolidProfilePrivacy mode) async {
    if (!await isUserLoggedIn()) return;
    if (solidProfileNotifier.privacy == mode) return;

    await ensureProfileFolder();

    // Capture the current data (loaded into the notifier) and rewrite it
    // under the new mode after switching the notifier so writePod sees
    // the right encryption flag.

    final currentAvatar = solidProfileNotifier.avatarBytes;
    final currentName = solidProfileNotifier.displayName;

    solidProfileNotifier.setPrivacy(mode);
    await _persistPrivacyPreference(mode);

    if (currentAvatar != null) {
      await saveAvatar(currentAvatar);
    }
    if (currentName != null && currentName.trim().isNotEmpty) {
      await saveDisplayName(currentName);
    }

    await _writeFolderAcl(mode);
  }

  // Clear local state.

  /// Resets cached state (call on logout). Also removes the locally
  /// cached avatar and display name so profile data is not left on the
  /// device for a logged-out user.

  void clearCache() {
    _initialised = false;
    solidProfileNotifier.clear();

    // 20260718 gjw Fire-and-forget: the local wipe needs no ordering
    // guarantees and clearCache() is called from sync contexts.

    unawaited(SolidProfileCache.instance.clear());
  }

  // Helpers.

  Future<void> _writeFolderAcl(SolidProfilePrivacy mode) async {
    final dirUrl = await _profileDirUrl();
    final aclUrl = '$dirUrl.acl';

    final aclTurtle = await genAclTurtle(
      dirUrl,
      isFile: false,
      publicAccess: mode == SolidProfilePrivacy.public
          ? const {AccessMode.read}
          : const {},
    );

    await createResource(aclUrl, content: aclTurtle, replaceIfExist: true);
  }

  Future<void> _loadPrivacyPreference() async {
    try {
      final webId = await getWebId();
      if (webId == null) return;
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('$_privacyPrefKey$webId');
      if (stored == SolidProfilePrivacy.public.name) {
        solidProfileNotifier.setPrivacy(SolidProfilePrivacy.public);
      } else {
        solidProfileNotifier.setPrivacy(SolidProfilePrivacy.private);
      }
    } catch (e) {
      debugPrint('SolidProfileService._loadPrivacyPreference: $e');
    }
  }

  Future<void> _persistPrivacyPreference(SolidProfilePrivacy mode) async {
    try {
      final webId = await getWebId();
      if (webId == null) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_privacyPrefKey$webId', mode.name);
    } catch (e) {
      debugPrint('SolidProfileService._persistPrivacyPreference: $e');
    }
  }

  Future<SolidProfilePrivacy?> _detectPrivacyFromPod() async {
    try {
      final displayNameUrl = await _displayNameUrl();
      if (await checkResourceStatus(displayNameUrl) == ResourceStatus.exist) {
        final encrypted = await isFileEncrypted(
          displayNameUrl,
          pathType: PathType.absoluteUrl,
        );
        return encrypted
            ? SolidProfilePrivacy.private
            : SolidProfilePrivacy.public;
      }

      final avatarUrl = await _avatarUrl();
      if (await checkResourceStatus(avatarUrl) == ResourceStatus.exist) {
        final encrypted =
            await isFileEncrypted(avatarUrl, pathType: PathType.absoluteUrl);
        return encrypted
            ? SolidProfilePrivacy.private
            : SolidProfilePrivacy.public;
      }
    } catch (e) {
      debugPrint('SolidProfileService._detectPrivacyFromPod: $e');
    }
    return null;
  }
}
