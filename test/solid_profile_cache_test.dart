/// Tests for the profile kept on this device and the per-WebID cache.
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

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:solidui/src/services/solid_profile_cache.dart';
import 'package:solidui/src/services/solid_profile_notifier.dart';

const _webId = 'https://pod.example.org/alice/profile/card#me';

final _local = Uint8List.fromList([1, 2, 3]);
final _pod = Uint8List.fromList([4, 5, 6]);

Future<SolidProfileNotifier> _primed(String? webId) async {
  final notifier = SolidProfileNotifier();
  await SolidProfileCache.instance.prime(notifier, webId);
  return notifier;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('the device and the Pod each keep their own picture', () async {
    await SolidProfileCache.instance.writeAvatar(_local, null);
    await SolidProfileCache.instance.writeAvatar(_pod, _webId);

    expect((await _primed(null)).avatarBytes, _local);
    expect((await _primed(_webId)).avatarBytes, _pod);
  });

  test('the device and the Pod each keep their own name', () async {
    await SolidProfileCache.instance.writeDisplayName('On device', null);
    await SolidProfileCache.instance.writeDisplayName('On Pod', _webId);

    expect((await _primed(null)).displayName, 'On device');
    expect((await _primed(_webId)).displayName, 'On Pod');
  });

  test('removing the device picture leaves the Pod one', () async {
    await SolidProfileCache.instance.writeAvatar(_local, null);
    await SolidProfileCache.instance.writeAvatar(_pod, _webId);
    await SolidProfileCache.instance.writeAvatar(null, null);

    expect((await _primed(null)).hasAvatar, isFalse);
    expect((await _primed(_webId)).avatarBytes, _pod);
  });
}
