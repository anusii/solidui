/// Local cache of profile data for instant display at startup.
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
/// Authors: Graham Williams

library;

import 'dart:convert' show base64Decode, base64Encode;

import 'package:flutter/foundation.dart' show Uint8List, debugPrint;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidpod/solidpod.dart' show getWebId;

import 'package:solidui/src/services/solid_profile_notifier.dart';

// 20260718 gjw Loading the avatar from the Pod takes several network round
// trips (folder/ACL checks, encryption probe, read, decrypt) so the stock
// placeholder icon was visible for noticeably long at every startup. This
// cache keeps the last-seen avatar and display name in SharedPreferences,
// keyed by WebID, so the real avatar is shown within milliseconds of the
// scaffold building while the Pod fetch refreshes it in the background.
// The cropped avatar is at most 512x512 PNG so the base64 payload is well
// within SharedPreferences limits.

/// Persists the last-seen avatar and display name locally, keyed by WebID,
/// so they can be displayed immediately at startup before the Pod responds.

class SolidProfileCache {
  SolidProfileCache._();

  static final SolidProfileCache _instance = SolidProfileCache._();

  /// Singleton accessor.

  static SolidProfileCache get instance => _instance;

  static const String _avatarKeyPrefix = 'solidui_profile_avatar_';
  static const String _nameKeyPrefix = 'solidui_profile_name_';

  // Remember the WebID we last cached for so that [clear] can remove the
  // entries after logout, when getWebId() no longer returns a value.

  String? _lastWebId;

  /// Populates [notifier] from the local cache for the logged-in WebID.
  /// Only fills fields the notifier does not already have, so a fresher
  /// in-memory value is never overwritten by a stale cached one.

  Future<void> prime(SolidProfileNotifier notifier) async {
    try {
      final webId = await getWebId();
      if (webId == null) return;
      _lastWebId = webId;

      final prefs = await SharedPreferences.getInstance();

      if (!notifier.hasAvatar) {
        final b64 = prefs.getString('$_avatarKeyPrefix$webId');
        if (b64 != null && b64.isNotEmpty) {
          notifier.setAvatar(base64Decode(b64));
        }
      }

      if (!notifier.hasDisplayName) {
        final name = prefs.getString('$_nameKeyPrefix$webId');
        if (name != null && name.trim().isNotEmpty) {
          notifier.setDisplayName(name);
        }
      }
    } catch (e) {
      debugPrint('SolidProfileCache.prime: $e');
    }
  }

  /// Stores [bytes] as the cached avatar for the logged-in WebID, or
  /// removes the cached avatar when [bytes] is null or empty.

  Future<void> writeAvatar(Uint8List? bytes) async {
    try {
      final webId = await getWebId();
      if (webId == null) return;
      _lastWebId = webId;

      final prefs = await SharedPreferences.getInstance();
      final key = '$_avatarKeyPrefix$webId';
      if (bytes == null || bytes.isEmpty) {
        await prefs.remove(key);
      } else {
        await prefs.setString(key, base64Encode(bytes));
      }
    } catch (e) {
      debugPrint('SolidProfileCache.writeAvatar: $e');
    }
  }

  /// Stores [name] as the cached display name for the logged-in WebID, or
  /// removes it when [name] is null or blank.

  Future<void> writeDisplayName(String? name) async {
    try {
      final webId = await getWebId();
      if (webId == null) return;
      _lastWebId = webId;

      final prefs = await SharedPreferences.getInstance();
      final key = '$_nameKeyPrefix$webId';
      if (name == null || name.trim().isEmpty) {
        await prefs.remove(key);
      } else {
        await prefs.setString(key, name);
      }
    } catch (e) {
      debugPrint('SolidProfileCache.writeDisplayName: $e');
    }
  }

  /// Removes the cached entries. Call on logout so profile data is not
  /// left on the device for a logged-out user. Falls back to the last
  /// cached WebID since getWebId() returns null once logged out.

  Future<void> clear() async {
    try {
      final webId = await getWebId() ?? _lastWebId;
      if (webId == null) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_avatarKeyPrefix$webId');
      await prefs.remove('$_nameKeyPrefix$webId');
      _lastWebId = null;
    } catch (e) {
      debugPrint('SolidProfileCache.clear: $e');
    }
  }
}
