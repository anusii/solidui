/// Whether the login widget shows its loading screen.
///
/// Copyright (C) 2025-2026, Software Innovation Institute, ANU.
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

/// Whether [SolidLogin] shows its loading screen rather than the login page.
///
/// 20261007 gjw A pure function, and tested as one, because the bug it now
/// prevents was invisible to a widget test. The login page is only reachable
/// once its assets have resolved, which does not happen in a bare test
/// environment, so a test pumping SolidLogin passed just as happily WITH the
/// defect as without it.
///
/// The defect: [skipDecided] did not exist, and the decision to skip reads
/// SharedPreferences, so it arrives several frames late while asset
/// resolution races it. Whenever the assets won that race there was a window
/// with everything false, which this read as "show the login page" — and an
/// app with skipLogin: true flashed the entire login screen, spinner and
/// all, before skipping it.
///
/// [skipDecided] must therefore gate the page, and must be set whatever the
/// answer: an app that is NOT skipping needs it just as much, or its login
/// page would never be shown at all.

bool solidLoginIsLoading({
  required bool skipDecided,
  required bool assetsResolved,
  required bool checkingAutoLogin,
  required bool skipping,
}) =>
    !skipDecided || !assetsResolved || checkingAutoLogin || skipping;
