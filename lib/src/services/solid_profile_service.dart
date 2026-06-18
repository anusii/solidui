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

import 'dart:convert' show base64Decode, base64Encode;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;

import 'package:rdflib/rdflib.dart' show Literal, Namespace, URIRef;
import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/services/solid_profile_notifier.dart';

/// Maximum allowed upload size for profile pictures (2 MB).

const int maxProfilePictureBytes = 2 * 1024 * 1024;

/// Allowed MIME extensions for profile pictures.

const Set<String> allowedProfileExtensions = {'.png', '.jpg', '.jpeg'};

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

  /// Loads profile data from the POD into [solidProfileNotifier].

  Future<void> loadProfile() async {
    if (!await isUserLoggedIn()) return;

    solidProfileNotifier.isLoading = true;

    try {
      await ensureProfileFolder();
      // Privacy must be resolved before avatar/display-name because it
      // determines the decryption mode used by readPod.
      await _loadPrivacyFromAcl();
      await Future.wait([_loadAvatar(), _loadDisplayName()]);
    } catch (e) {
      debugPrint('SolidProfileService.loadProfile: $e');
    } finally {
      solidProfileNotifier.isLoading = false;
    }
  }

  Future<void> _loadAvatar() async {
    final url = await _avatarUrl();
    if (await checkResourceStatus(url) != ResourceStatus.exist) return;

    try {
      final ttl = await readPod(url, pathType: PathType.absoluteUrl);
      final bytes = _extractAvatarBytes(ttl);
      solidProfileNotifier.setAvatar(bytes);
    } catch (e) {
      debugPrint('SolidProfileService._loadAvatar: $e');
    }
  }

  Future<void> _loadDisplayName() async {
    final url = await _displayNameUrl();
    if (await checkResourceStatus(url) != ResourceStatus.exist) return;

    try {
      final ttl = await readPod(url, pathType: PathType.absoluteUrl);
      final name = _extractDisplayName(ttl);
      if (name != null) solidProfileNotifier.setDisplayName(name);
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
    final ttl = await _buildAvatarTtl(pngBytes);

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
  }

  // Save display name.

  /// Persists [name] as the user's display name on the POD as linked data.

  Future<void> saveDisplayName(String name) async {
    await ensureProfileFolder();
    final url = await _displayNameUrl();
    final ttl = await _buildDisplayNameTtl(name);

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

    if (currentAvatar != null) {
      await saveAvatar(currentAvatar);
    }
    if (currentName != null && currentName.trim().isNotEmpty) {
      await saveDisplayName(currentName);
    }

    await _writeFolderAcl(mode);
  }

  // Clear local state.

  /// Resets cached state (call on logout).

  void clearCache() {
    _initialised = false;
    solidProfileNotifier.clear();
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

  /// Reads the profile folder ACL from the POD and updates
  /// [solidProfileNotifier] with the derived [SolidProfilePrivacy].
  /// Public mode is inferred from the presence of a public-read grant
  /// (`foaf:Agent` + `acl:Read`) in the ACL turtle.

  Future<void> _loadPrivacyFromAcl() async {
    try {
      final dirUrl = await _profileDirUrl();
      final aclUrl = '$dirUrl.acl';
      if (await checkResourceStatus(aclUrl) != ResourceStatus.exist) return;

      final content = await readPod(aclUrl, pathType: PathType.absoluteUrl);
      final isPublic =
          content.contains('foaf:Agent') && content.contains('acl:Read');
      solidProfileNotifier.setPrivacy(
        isPublic ? SolidProfilePrivacy.public : SolidProfilePrivacy.private,
      );
    } catch (e) {
      debugPrint('SolidProfileService._loadPrivacyFromAcl: $e');
    }
  }

  // Build the linked-data turtle for the display name. The user's WebID is
  // used as the subject so the triple is meaningful when read independently
  // by other agents and queries. We emit both `foaf:name` (the most widely
  // understood "name" predicate) and `vcard:fn` (the VCard "formatted name")
  // so different consumers can pick whichever they recognise.

  Future<String> _buildDisplayNameTtl(String name) async {
    final webId = await getWebId() ?? '';
    final subject = URIRef(webId.isEmpty ? '#me' : webId);
    final triples = <URIRef, Map<URIRef, dynamic>>{
      subject: {
        FoafPredicate.name.uriRef: Literal(name),
        VcardPredicate.fn.uriRef: Literal(name),
      },
    };

    // rdflib auto-binds the FOAF prefix (it lives in its standardPrefixes
    // table) so passing it again throws "foaf: already exists in prefixed
    // namespaces". We only need to register prefixes outside that set.

    return tripleMapToTurtle(
      triples,
      bindNamespaces: {
        'vcard': Namespace(ns: SolidConstants.namespaces.vcard),
      },
    );
  }

  // Build the linked-data turtle for the avatar. The image is embedded as a
  // standard `data:` URI on `vcard:hasPhoto`, anchored on the user's WebID,
  // so it is interpretable by any vcard-aware reader. The whole file is
  // wrapped through writePod() which handles encryption transparently.

  Future<String> _buildAvatarTtl(Uint8List pngBytes) async {
    final webId = await getWebId() ?? '';
    final subject = URIRef(webId.isEmpty ? '#me' : webId);
    final dataUri = 'data:image/png;base64,${base64Encode(pngBytes)}';
    final triples = <URIRef, Map<URIRef, dynamic>>{
      subject: {
        VcardPredicate.hasPhoto.uriRef: URIRef(dataUri),
      },
    };
    return tripleMapToTurtle(
      triples,
      bindNamespaces: {
        'vcard': Namespace(ns: SolidConstants.namespaces.vcard),
      },
    );
  }

  // Find the first display-name literal in the (decrypted) turtle. Tries
  // foaf:name then vcard:fn.

  String? _extractDisplayName(String ttl) {
    Map<String, Map<String, dynamic>> map;
    try {
      map = turtleToTripleMap(ttl);
    } catch (_) {
      return null;
    }
    for (final pred in [
      FoafPredicate.name.value,
      VcardPredicate.fn.value,
    ]) {
      for (final entry in map.values) {
        final value = entry[pred];
        if (value == null) continue;
        if (value is String && value.trim().isNotEmpty) return value;
        if (value is Iterable && value.isNotEmpty) {
          final first = value.first;
          if (first is String && first.trim().isNotEmpty) return first;
        }
      }
    }
    return null;
  }

  // Locate the vcard:hasPhoto data URI in the (decrypted) turtle and decode
  // its base64 payload back to PNG bytes.

  Uint8List? _extractAvatarBytes(String ttl) {
    Map<String, Map<String, dynamic>> map;
    try {
      map = turtleToTripleMap(ttl);
    } catch (_) {
      return null;
    }

    String? findPhotoUri() {
      for (final entry in map.values) {
        final v = entry[VcardPredicate.hasPhoto.value];
        if (v is String && v.isNotEmpty) return v;
        if (v is Iterable && v.isNotEmpty && v.first is String) {
          return v.first as String;
        }
      }
      return null;
    }

    final photo = findPhotoUri();
    if (photo == null) return null;

    // Expecting a `data:image/<type>;base64,<payload>` URI.

    const marker = ';base64,';
    final idx = photo.indexOf(marker);
    if (!photo.startsWith('data:') || idx < 0) return null;

    try {
      return base64Decode(photo.substring(idx + marker.length));
    } catch (e) {
      debugPrint('SolidProfileService._extractAvatarBytes: $e');
      return null;
    }
  }
}
