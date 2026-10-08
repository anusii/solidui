/// Tests for when SolidLogin shows its loading screen.
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

import 'package:flutter_test/flutter_test.dart';

import 'package:solidui/src/widgets/solid_login_loading.dart';

/// The gate, with every flag at its "ready to show the login page" value.
/// Each test then moves ONE of them.

bool _loading({
  bool skipDecided = true,
  bool assetsResolved = true,
  bool checkingAutoLogin = false,
  bool skipping = false,
}) =>
    solidLoginIsLoading(
      skipDecided: skipDecided,
      assetsResolved: assetsResolved,
      checkingAutoLogin: checkingAutoLogin,
      skipping: skipping,
    );

void main() {
  // 20261007 gjw THIS IS THE FLASH, as a single line. The skip decision
  // reads SharedPreferences and lands several frames late, while asset
  // resolution races it. Before skipDecided existed, the frames where the
  // assets had won and the decision had not yet arrived looked exactly like
  // "ready to show the login page" — so an app with skipLogin: true drew the
  // whole login screen, and its spinner, before skipping it.
  //
  // Tested here rather than by pumping SolidLogin because a widget test
  // CANNOT see this: the login page needs its assets resolved, which does
  // not happen in a bare test environment, so a pumping test passed with the
  // defect present just as it did without it. It was checked both ways.

  test('the login page waits for the skip decision', () {
    expect(_loading(skipDecided: false), isTrue);
  });

  test('everything else being ready does not override that', () {
    expect(
      _loading(
        skipDecided: false,
        assetsResolved: true,
        checkingAutoLogin: false,
        skipping: false,
      ),
      isTrue,
      reason: 'this exact combination was the flash',
    );
  });

  test('the login page shows once everything is settled', () {
    expect(_loading(), isFalse);
  });

  // The gate must not trap an app that is NOT skipping. skipDecided is set
  // whatever the answer, so a decided "no" shows the page.

  test('a decided no shows the login page', () {
    expect(_loading(skipping: false), isFalse);
  });

  test('a decided yes keeps the loading screen', () {
    expect(_loading(skipping: true), isTrue);
  });

  group('the older reasons to wait still hold', () {
    test('assets not yet resolved', () {
      expect(_loading(assetsResolved: false), isTrue);
    });

    test('an auto-login check in progress', () {
      expect(_loading(checkingAutoLogin: true), isTrue);
    });
  });
}
