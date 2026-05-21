/// Persist and restore the last-selected SolidScaffold menu index.
///
/// Used internally when [SolidScaffold.rememberLastIndex] is true so the
/// user lands back on the screen they last visited. Backed by
/// shared_preferences.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
///
/// Licensed under the MIT License (the "License").
///
/// License: https://choosealicense.com/licenses/mit/.
///
/// Authors: Software Innovation Institute, ANU

library;

import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// Storage helpers for the `last selected menu index`.
///
/// Static-only utility; never instantiated.
class SolidScaffoldLastIndex {
  static const String _key = 'solidui_last_menu_index';

  SolidScaffoldLastIndex._();

  /// Read the saved index. Returns `null` if no value is stored, the
  /// stored value is out of range, or anything throws. Callers pass
  /// [menuLength] so a stale saved value (e.g. after removing a menu
  /// item) is treated as absent rather than crashing later.
  static Future<int?> load({required int menuLength}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getInt(_key);
      if (value == null) return null;
      if (value < 0 || value >= menuLength) return null;
      return value;
    } on Exception catch (e) {
      debugPrint('[SolidScaffoldLastIndex] load failed: $e');
      return null;
    }
  }

  /// Persist [index]. Fire-and-forget: failures are logged but never
  /// propagated, since saving the position should not block navigation.
  static Future<void> save(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, index);
    } on Exception catch (e) {
      debugPrint('[SolidScaffoldLastIndex] save failed: $e');
    }
  }
}
