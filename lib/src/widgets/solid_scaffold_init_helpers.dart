/// Solid Scaffold Initialisation Helpers.
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
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

import 'package:package_info_plus/package_info_plus.dart';

import 'package:solidui/src/services/solid_security_key_service.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_theme_notifier.dart';

/// Helper class for Solid Scaffold initialization.

class SolidScaffoldInitHelpers {
  /// Initialises security key service if needed.

  static SolidSecurityKeyService? initializeSecurityKeyService(
    bool hasSecurityKeyConfig,
    Function() onKeyChanged,
    Function() loadKeyStatus,
  ) {
    if (!hasSecurityKeyConfig) return null;

    final service = SolidSecurityKeyService();
    service.addListener(onKeyChanged);
    return service;
  }

  /// Initialises theme notifier if using internal management.

  static void initializeThemeNotifier(
    bool usesInternalManagement,
    VoidCallback onThemeChanged,
  ) {
    if (!usesInternalManagement) return;

    if (!solidThemeNotifier.isInitialized) {
      solidThemeNotifier.initialize();
    }
    solidThemeNotifier.addListener(onThemeChanged);
  }

  /// Loads app version if version config is present.

  static Future<String?> loadAppVersion(bool hasVersionConfig) async {
    if (!hasVersionConfig) return null;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      debugPrint('Error loading app version: $e');
      return '';
    }
  }

  /// Checks if app bar has version config.

  static bool hasVersionConfig(dynamic appBar) {
    if (appBar is! SolidAppBarConfig) return false;
    return appBar.versionConfig != null;
  }

  /// Updates security key status from service.

  static Future<bool> updateSecurityKeyStatusFromService(
    SolidSecurityKeyService? service,
    Function(bool)? onKeyStatusChanged,
  ) async {
    if (service == null) return false;

    try {
      final isKeySaved = await service.isKeySaved();
      onKeyStatusChanged?.call(isKeySaved);
      return isKeySaved;
    } catch (e) {
      debugPrint('Error updating security key status: $e');
      return false;
    }
  }

  /// Loads security key status using service.

  static Future<bool> loadSecurityKeyStatus(
    SolidSecurityKeyService? service,
    Function(bool) onKeyStatusChanged,
  ) async {
    if (service == null) return false;

    try {
      final hasKeyInMemory = await service.isKeySaved();

      await service.fetchKeySavedStatus((bool hasKey) {
        onKeyStatusChanged(hasKey);
      });

      return hasKeyInMemory;
    } catch (e) {
      debugPrint('Error loading security key status: $e');
      return false;
    }
  }
}
