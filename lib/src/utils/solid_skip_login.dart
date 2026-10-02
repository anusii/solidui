/// Whether the app goes straight in at start-up, as if CONTINUE were tapped.
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

import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// Skip the login page at start-up, going straight into the app exactly as
/// though the user had tapped CONTINUE.
///
/// Only an app that offers CONTINUE (a `SolidLogin` with `required: false`)
/// can skip. The app chooses the default through `SolidLogin.skipLogin`, and
/// the user can override it from the Login Page section of the settings
/// dialogue. The choice is a device preference, kept in SharedPreferences.
///
/// The decision is made once, by the first `SolidLogin` of the run. The login
/// page an app returns to on logout, or opens to log in from within the app,
/// is also a `SolidLogin`, and skipping that would make logging in from the
/// app impossible.

class SolidSkipLogin {
  SolidSkipLogin._();

  /// The preference the user's own choice is kept in. It is absent while the
  /// user follows the app's default.

  static const String skipPref = 'solidui.skipLogin';

  static bool _decided = false;

  static bool? _appDefault;

  static bool _skipping = false;

  /// Whether the app offers CONTINUE, and so whether there is anything for
  /// the settings dialogue to offer.

  static bool get offered => _appDefault != null;

  /// The app's own default, so the settings dialogue can restore it.

  static bool get appDefault => _appDefault ?? false;

  /// Whether the login page is currently skipped at start-up.

  static bool get skipping => _skipping;

  /// Decide, once per run, whether to skip the login page.
  ///
  /// Returns true only on the first call, and only when the app offers
  /// CONTINUE ([required] is false) and skipping is the user's choice or,
  /// failing that, the app's default [byDefault].

  static Future<bool> atStartup({
    required bool required,
    required bool byDefault,
  }) async {
    if (_decided) return false;
    _decided = true;
    if (required) return false;

    _appDefault = byDefault;
    final prefs = await SharedPreferences.getInstance();
    _skipping = prefs.getBool(skipPref) ?? byDefault;

    return _skipping;
  }

  /// Record whether to skip from the next start-up on. A choice that matches
  /// the app's default is forgotten, so the user follows the app's default
  /// again should the app change it.

  static Future<void> setSkipping(bool value) async {
    _skipping = value;
    final prefs = await SharedPreferences.getInstance();

    if (value == _appDefault) {
      await prefs.remove(skipPref);
    } else {
      await prefs.setBool(skipPref, value);
    }
  }

  /// Forget the decision for this run, so a test can start afresh.

  @visibleForTesting
  static void reset() {
    _decided = false;
    _appDefault = null;
    _skipping = false;
  }
}
