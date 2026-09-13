/// Tests for remembering the desktop window size.
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

import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:solidui/src/utils/solid_window_size.dart';

/// The window the mocked window_manager reports, and the last size it was
/// asked to resize to.

Size mockWindow = const Size(1000, 700);
Size? resizedTo;

/// Stand in for the window_manager plugin, which has no native side under
/// `flutter test`.

void mockWindowManager() {
  resizedTo = null;

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('window_manager'),
    (call) async {
      switch (call.method) {
        case 'getBounds':
          return <String, dynamic>{
            'x': 0.0,
            'y': 0.0,
            'width': mockWindow.width,
            'height': mockWindow.height,
          };
        case 'setBounds':
          final arguments = call.arguments as Map<dynamic, dynamic>;
          resizedTo = Size(
            arguments['width'] as double,
            arguments['height'] as double,
          );

          return null;
        default:
          return null;
      }
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockWindow = const Size(1000, 700);
    mockWindowManager();
  });

  group('saved', () {
    test('is null until a size has been remembered', () async {
      expect(await SolidWindowSize.saved(), isNull);
    });

    test('is the remembered size once there is one', () async {
      await SolidWindowSize.save();

      expect(await SolidWindowSize.saved(), const Size(1000, 700));
    });

    test('is null again after forgetting it', () async {
      await SolidWindowSize.save();
      await SolidWindowSize.forget();

      expect(await SolidWindowSize.saved(), isNull);
    });
  });

  group('save', () {
    test('remembers by default', () async {
      expect(await SolidWindowSize.remembering(), isTrue);
    });

    test('does nothing while remembering is turned off', () async {
      await SolidWindowSize.setRemembering(false);
      await SolidWindowSize.save();

      expect(await SolidWindowSize.saved(), isNull);
    });

    test('ignores a window too small to be real', () async {
      // A minimised window, or one mid-transition, reports a size that would
      // leave the app unopenable next time.

      mockWindow = const Size(1, 1);
      await SolidWindowSize.save();

      expect(await SolidWindowSize.saved(), isNull);
    });
  });

  group('resize', () {
    test('resizes the window and remembers the new size', () async {
      expect(await SolidWindowSize.resize(const Size(1280, 800)), isTrue);

      expect(resizedTo, const Size(1280, 800));
      expect(await SolidWindowSize.saved(), const Size(1280, 800));
    });

    test('refuses a size too small to be usable', () async {
      expect(await SolidWindowSize.resize(const Size(40, 900)), isFalse);

      expect(resizedTo, isNull);
      expect(await SolidWindowSize.saved(), isNull);
    });

    test('remembers even while remembering is turned off', () async {
      // Turning off remembering stops the size being followed as the window
      // is dragged. A size typed into settings is still meant to stick.

      await SolidWindowSize.setRemembering(false);
      await SolidWindowSize.resize(const Size(1280, 800));

      expect(await SolidWindowSize.saved(), const Size(1280, 800));
    });
  });
}
