/// Helper methods for SolidScaffoldState.
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

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart' show getWebId, isUserLoggedIn;

import 'package:solidui/src/services/solid_security_key_service.dart';
import 'package:solidui/src/widgets/solid_scaffold_init_helpers.dart';

/// Helper class for SolidScaffoldState security key operations.

class SolidScaffoldSecurityKeyHelper {
  final SolidSecurityKeyService? _securityKeyService;
  final void Function(bool) _onStatusChanged;
  final bool Function() _isMounted;
  bool _isUpdating = false;

  SolidScaffoldSecurityKeyHelper({
    required SolidSecurityKeyService? securityKeyService,
    required void Function(bool) onStatusChanged,
    required bool Function() isMounted,
  })  : _securityKeyService = securityKeyService,
        _onStatusChanged = onStatusChanged,
        _isMounted = isMounted;

  Future<void> updateStatusFromService(
    void Function(bool)? externalCallback,
  ) async {
    if (_isUpdating) return;
    _isUpdating = true;
    try {
      final isKeySaved =
          await SolidScaffoldInitHelpers.updateSecurityKeyStatusFromService(
        _securityKeyService,
        externalCallback,
      );
      if (_isMounted()) _onStatusChanged(isKeySaved);
    } finally {
      _isUpdating = false;
    }
  }

  Future<bool> loadStatus(void Function(bool)? externalCallback) async {
    if (_isUpdating) return false;
    _isUpdating = true;
    try {
      final hasKeyInMemory =
          await SolidScaffoldInitHelpers.loadSecurityKeyStatus(
        _securityKeyService,
        (hasKey) {
          if (_isMounted()) {
            _onStatusChanged(hasKey);
            externalCallback?.call(hasKey);
          }
        },
      );
      if (_isMounted()) _onStatusChanged(hasKeyInMemory);
      return hasKeyInMemory;
    } catch (e) {
      if (_isMounted()) _onStatusChanged(false);
      return false;
    } finally {
      _isUpdating = false;
    }
  }

  Future<void> refresh(
    bool currentStatus,
    void Function(bool)? externalCallback,
  ) async {
    if (_securityKeyService == null) return;

    try {
      final hasKey = await _securityKeyService.refreshAndNotify((
        bool keyStatus,
      ) {
        if (_isMounted() && keyStatus != currentStatus) {
          _onStatusChanged(keyStatus);
          externalCallback?.call(keyStatus);
        }
      });

      if (_isMounted() && hasKey != currentStatus) {
        _onStatusChanged(hasKey);
        externalCallback?.call(hasKey);
      }
    } catch (e) {
      debugPrint('Error refreshing security key status: $e');
    }
  }

  bool get isUpdating => _isUpdating;
}

/// Helper class for loading current WebId.

class SolidScaffoldWebIdHelper {
  static Future<String?> loadCurrentWebId({
    required bool Function() isMounted,
    required String? currentWebId,
  }) async {
    try {
      final webId = await getWebId();

      if (webId == null || webId.isEmpty) {
        return null;
      }

      final isLoggedIn = await isUserLoggedIn();
      return isLoggedIn ? webId : null;
    } catch (e) {
      debugPrint('Error loading current webId: $e');
      return null;
    }
  }
}
