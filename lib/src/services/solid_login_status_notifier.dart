/// Login Status Notifier.
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

import 'package:solidpod/solidpod.dart' show getWebId, isUserLoggedIn;

/// Global notifier broadcasting changes to the Solid login state.

class SolidLoginStatusNotifier extends ChangeNotifier {
  String? _webId;
  bool _isChecking = false;

  /// The cached WebID, or `null` when the user is logged out or the status
  /// has not been resolved yet.

  String? get webId => _webId;

  /// Whether the user is currently considered logged in.

  bool get isLoggedIn => _webId != null && _webId!.isNotEmpty;

  /// Whether a status check is currently in flight.

  bool get isChecking => _isChecking;

  /// Re-reads the authentication state from solidpod and notifies listeners
  /// when the resolved [webId] changes. Returns the freshly resolved WebID
  /// (or `null` when logged out).
  ///
  /// Concurrent calls are coalesced: while one refresh is in progress,
  /// subsequent calls return the in-flight result and do not trigger a
  /// duplicate fetch.

  Future<String?> refreshStatus() async {
    if (_isChecking) return _webId;

    _isChecking = true;
    try {
      final fetched = await getWebId();
      final loggedIn = await isUserLoggedIn();
      final resolved = (loggedIn && fetched != null && fetched.isNotEmpty)
          ? fetched
          : null;

      if (resolved != _webId) {
        _webId = resolved;
        notifyListeners();
      }
      return resolved;
    } on Object catch (e) {
      debugPrint('SolidLoginStatusNotifier: refreshStatus failed: $e');
      if (_webId != null) {
        _webId = null;
        notifyListeners();
      }
      return null;
    } finally {
      _isChecking = false;
    }
  }

  /// Clears the cached WebID and notifies listeners.

  void markLoggedOut() {
    if (_webId != null) {
      _webId = null;
      notifyListeners();
    }
  }
}

/// Global singleton instance shared by the package.

final solidLoginStatusNotifier = SolidLoginStatusNotifier();
