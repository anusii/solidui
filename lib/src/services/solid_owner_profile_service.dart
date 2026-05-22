/// Service for fetching public profile data (avatar + display name) for any
/// POD owner identified by their WebID.
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

import 'dart:async';
import 'dart:convert' show base64Decode;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;

import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/utils/web_id_parser.dart';

/// Snapshot of a remote POD owner's profile derived from publicly readable
/// resources in their app profile folder.
///
/// `null` fields indicate the corresponding data could not be fetched (either
/// because the resource does not exist, the owner has not made it public, or
/// a network error occurred). [isLoaded] is `true` once at least one fetch
/// attempt has completed, regardless of outcome.

@immutable
class SolidOwnerProfile {
  /// Bytes of the owner's profile picture (typically PNG), if any.

  final Uint8List? avatarBytes;

  /// Display name (foaf:name / vcard:fn), if any.

  final String? displayName;

  /// Whether a fetch has completed at least once for this owner.

  final bool isLoaded;

  const SolidOwnerProfile({
    this.avatarBytes,
    this.displayName,
    this.isLoaded = false,
  });

  /// Convenience empty/loaded marker used as the default cache value when a
  /// fetch attempt produced no usable data.

  static const empty = SolidOwnerProfile(isLoaded: true);

  /// Whether [avatarBytes] holds a non-empty image payload.

  bool get hasAvatar => avatarBytes != null && avatarBytes!.isNotEmpty;

  /// Whether [displayName] holds a non-empty, non-whitespace string.

  bool get hasDisplayName =>
      displayName != null && displayName!.trim().isNotEmpty;
}

/// Singleton that fetches and caches public profile data (avatar bytes +
/// display name) for arbitrary POD owners, keyed by WebID.
///
/// The data is read from the owner's `<appDir>/profile/avatar.ttl` and
/// `<appDir>/profile/display-name.ttl` resources, written by
/// [SolidProfileService] when the user opts to keep their profile public.
/// Private (encrypted) profiles cannot be decrypted by other users and will
/// simply resolve to [SolidOwnerProfile.empty].
///
/// Results are cached in memory for the lifetime of the process so list views
/// do not refetch on every rebuild. Call [clearCache] on logout to drop the
/// previous user's view of the world.

class SolidOwnerProfileService {
  SolidOwnerProfileService._();

  /// Singleton accessor.

  static final SolidOwnerProfileService instance = SolidOwnerProfileService._();

  final Map<String, SolidOwnerProfile> _cache = {};
  final Map<String, Future<SolidOwnerProfile>> _inflight = {};

  /// Synchronously returns the cached profile for [webId], or `null` when no
  /// fetch attempt has completed for this owner yet.

  SolidOwnerProfile? cachedProfile(String webId) => _cache[webId];

  /// Fetches the public profile for [webId], caching the result. Concurrent
  /// calls for the same WebID share a single network request.

  Future<SolidOwnerProfile> fetchProfile(String webId) {
    final cached = _cache[webId];
    if (cached != null) return Future.value(cached);
    return _inflight.putIfAbsent(webId, () => _fetch(webId));
  }

  /// Removes any cached entry for [webId] so that the next [fetchProfile]
  /// call goes back to the network.

  void invalidate(String webId) {
    _cache.remove(webId);
    _inflight.remove(webId);
  }

  /// Clears every cached profile. Call this on logout.

  void clearCache() {
    _cache.clear();
    _inflight.clear();
  }

  // Network.

  Future<SolidOwnerProfile> _fetch(String webId) async {
    try {
      final parts = WebIdParts.tryParse(webId);
      if (parts == null || parts.username.isEmpty) {
        return _cache[webId] = SolidOwnerProfile.empty;
      }

      // The profile resources are written by [SolidProfileService] under the
      // current app's directory. Resolve them on the owner's POD using the
      // same convention.

      final appDir = SolidConstants.directories.app;
      if (appDir.isEmpty) {
        return _cache[webId] = SolidOwnerProfile.empty;
      }
      final profileBase =
          '${parts.serverUri}/${parts.username}/$appDir/$profileDir';
      final avatarUrl = '$profileBase/$profilePictureFile';
      final displayNameUrl = '$profileBase/$displayNameFile';

      final results = await Future.wait<Object?>([
        _safeFetchAvatar(avatarUrl),
        _safeFetchDisplayName(displayNameUrl),
      ]);

      final profile = SolidOwnerProfile(
        avatarBytes: results[0] as Uint8List?,
        displayName: results[1] as String?,
        isLoaded: true,
      );
      _cache[webId] = profile;
      return profile;
    } catch (e) {
      debugPrint('SolidOwnerProfileService._fetch($webId): $e');
      return _cache[webId] = SolidOwnerProfile.empty;
    } finally {
      _inflight.remove(webId);
    }
  }

  Future<Uint8List?> _safeFetchAvatar(String url) async {
    try {
      if (await checkResourceStatus(url) != ResourceStatus.exist) return null;
      final ttl = await readPod(url, pathType: PathType.absoluteUrl);
      return _extractAvatarBytes(ttl);
    } catch (e) {
      // Silently ignore: typical reasons are 403 (private profile) and
      // 404 (no avatar set). Either way there is nothing to display.

      debugPrint('SolidOwnerProfileService._safeFetchAvatar($url): $e');
      return null;
    }
  }

  Future<String?> _safeFetchDisplayName(String url) async {
    try {
      if (await checkResourceStatus(url) != ResourceStatus.exist) return null;
      final ttl = await readPod(url, pathType: PathType.absoluteUrl);
      return _extractDisplayName(ttl);
    } catch (e) {
      debugPrint('SolidOwnerProfileService._safeFetchDisplayName($url): $e');
      return null;
    }
  }

  // Turtle parsing.
  //
  // Mirrors the extraction logic used in [SolidProfileService] so that owner
  // resources written via that service can be read back out by other users.

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

    const marker = ';base64,';
    final idx = photo.indexOf(marker);
    if (!photo.startsWith('data:') || idx < 0) return null;

    try {
      return base64Decode(photo.substring(idx + marker.length));
    } catch (e) {
      debugPrint('SolidOwnerProfileService._extractAvatarBytes: $e');
      return null;
    }
  }
}

/// A pair of background + foreground colours used to render an owner's
/// initials or placeholder icon.
///
/// Both colours together satisfy WCAG AA contrast (≥ 4.5:1) so labels remain
/// legible for low-vision users.

@immutable
class SolidOwnerColourPair {
  /// Fill colour for the avatar circle.

  final Color background;

  /// Recommended text/icon colour for legible contrast on [background].

  final Color foreground;

  const SolidOwnerColourPair({
    required this.background,
    required this.foreground,
  });
}

/// Accessible colour palette used to distinguish between different POD owners
/// who happen to share the same initials (or first WebID letters).
///
/// Each background is dark enough that white foreground text/icons satisfy
/// WCAG AA contrast (computed contrast ratios all exceed 4.5:1). The hues are
/// spread around the colour wheel so that adjacent entries remain
/// distinguishable under common forms of colour-vision deficiency
/// (deuteranopia, protanopia, tritanopia). The palette is intentionally
/// kept short (10 swatches) to maximise pairwise distinguishability — beyond
/// this many owners, collisions are unavoidable without sacrificing clarity.

const List<SolidOwnerColourPair> accessibleOwnerColourPalette =
    <SolidOwnerColourPair>[
  // Deep navy blue.
  SolidOwnerColourPair(
    background: Color(0xFF1F4E79),
    foreground: Color(0xFFFFFFFF),
  ),
  // Burnt orange / rust.
  SolidOwnerColourPair(
    background: Color(0xFFB35900),
    foreground: Color(0xFFFFFFFF),
  ),
  // Forest green.
  SolidOwnerColourPair(
    background: Color(0xFF2E7D32),
    foreground: Color(0xFFFFFFFF),
  ),
  // Royal purple.
  SolidOwnerColourPair(
    background: Color(0xFF6A1B9A),
    foreground: Color(0xFFFFFFFF),
  ),
  // Raspberry / dark pink.
  SolidOwnerColourPair(
    background: Color(0xFFC2185B),
    foreground: Color(0xFFFFFFFF),
  ),
  // Deep teal.
  SolidOwnerColourPair(
    background: Color(0xFF00695C),
    foreground: Color(0xFFFFFFFF),
  ),
  // Chocolate brown.
  SolidOwnerColourPair(
    background: Color(0xFF5D4037),
    foreground: Color(0xFFFFFFFF),
  ),
  // Blue-grey slate.
  SolidOwnerColourPair(
    background: Color(0xFF455A64),
    foreground: Color(0xFFFFFFFF),
  ),
  // Magenta.
  SolidOwnerColourPair(
    background: Color(0xFFAD1457),
    foreground: Color(0xFFFFFFFF),
  ),
  // Cerulean blue.
  SolidOwnerColourPair(
    background: Color(0xFF01579B),
    foreground: Color(0xFFFFFFFF),
  ),
];

/// Returns a stable accent colour pair for [webId] drawn from
/// [accessibleOwnerColourPalette].
///
/// The mapping is deterministic: the same WebID always resolves to the same
/// entry, so an owner's avatar colour is consistent across rebuilds, sessions
/// and devices. Returns `null` when [webId] is `null` or empty so that
/// callers can fall back to a neutral theme colour for unknown owners.

SolidOwnerColourPair? ownerColourPairFor(String? webId) {
  if (webId == null) return null;
  final trimmed = webId.trim();
  if (trimmed.isEmpty) return null;

  // Use a deterministic char-code based hash so the mapping is stable across
  // platforms and runs, unlike `String.hashCode` which is documented as
  // implementation-defined.

  var hash = 0;
  for (final code in trimmed.codeUnits) {
    hash = (hash * 31 + code) & 0x7FFFFFFF;
  }
  final index = hash % accessibleOwnerColourPalette.length;
  return accessibleOwnerColourPalette[index];
}

/// Computes a short text label (the "initials") to display when no avatar
/// image is available for a POD owner.
///
/// Rules, applied in order:
///   1. If [displayName] contains multiple whitespace-separated words, use
///      the first letter of the first word together with the first letter of
///      the last word (e.g. `Ada Byron Lovelace` → `AL`).
///   2. If [displayName] is a single word, use its first two letters
///      (e.g. `cher` → `CH`). A one-character name returns that character.
///   3. Otherwise fall back to the first two letters of the WebID's
///      username segment (e.g. `https://pods.example.au/john-doe/profile/card#me`
///      → `JO`).
///   4. Returns an empty string when none of the above can be derived. The
///      caller is expected to fall back to a placeholder icon in that case.

String computeOwnerInitials({String? displayName, String? webId}) {
  final name = displayName?.trim() ?? '';
  if (name.isNotEmpty) {
    final words = name
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList(growable: false);
    if (words.length == 1) {
      final w = words.first;
      return w.length >= 2 ? w.substring(0, 2).toUpperCase() : w.toUpperCase();
    } else if (words.length > 1) {
      return (words.first[0] + words.last[0]).toUpperCase();
    }
  }

  if (webId != null && webId.isNotEmpty) {
    final parts = WebIdParts.tryParse(webId);
    final username = parts?.username ?? '';
    if (username.length >= 2) return username.substring(0, 2).toUpperCase();
    if (username.length == 1) return username.toUpperCase();
  }

  return '';
}
