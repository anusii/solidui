/// Notifier for profile state changes (avatar and display name).
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

import 'package:flutter/foundation.dart';

/// Holds the current profile state and notifies listeners on changes.

class SolidProfileNotifier extends ChangeNotifier {
  Uint8List? _avatarBytes;
  String? _displayName;
  bool _isLoading = false;

  /// The current profile picture bytes (PNG), or null if none set.

  Uint8List? get avatarBytes => _avatarBytes;

  /// The current display name, or null if none set.

  String? get displayName => _displayName;

  /// Whether a profile operation is in progress.

  bool get isLoading => _isLoading;

  /// Whether the user has a profile picture.

  bool get hasAvatar => _avatarBytes != null && _avatarBytes!.isNotEmpty;

  /// Whether the user has a display name.

  bool get hasDisplayName =>
      _displayName != null && _displayName!.trim().isNotEmpty;

  set isLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  /// Updates the avatar bytes and notifies listeners.

  void setAvatar(Uint8List? bytes) {
    _avatarBytes = bytes;
    notifyListeners();
  }

  /// Updates the display name and notifies listeners.

  void setDisplayName(String? name) {
    _displayName = name;
    notifyListeners();
  }

  /// Clears all profile data (e.g. on logout).

  void clear() {
    _avatarBytes = null;
    _displayName = null;
    _isLoading = false;
    notifyListeners();
  }
}

/// Global singleton instance used throughout the application.

final solidProfileNotifier = SolidProfileNotifier();
