/// Solid Scaffold Initialisation Helpers.
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
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
    loadKeyStatus();
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
