/// Central key manager to prevent multiple security key prompts.
///
/// Copyright (C) 2025, Software Innovation Institute, ANU
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
/// Authors: Ashley Tang, Tony Chen

library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

/// Central manager for security key operations to prevent duplicate prompts.
///
/// This singleton keeps track of security key verification status and
/// ensures that the key is only requested once during app initialisation.

class SolidSecurityKeyCentralManager {
  // Singleton instance.

  static final SolidSecurityKeyCentralManager _instance = 
      SolidSecurityKeyCentralManager._internal();

  // Factory constructor.

  factory SolidSecurityKeyCentralManager() => _instance;

  // Private constructor.

  SolidSecurityKeyCentralManager._internal();

  // Key verification status.

  bool _keyVerified = false;

  // Completer to track verification process.

  Completer<bool>? _verificationCompleter;

  // Get singleton instance.

  static SolidSecurityKeyCentralManager get instance => _instance;

  /// Checks if security key is needed and initiates a single verification process.
  ///
  /// Returns true if key is verified (either now or previously), false otherwise.
  /// Ensures that only one prompt is shown even if called from multiple places.

  Future<bool> ensureSecurityKey(BuildContext context, Widget child) async {
    // If key is already verified, return immediately.

    if (_keyVerified) {
      //debugPrint('⚠️ Security key already verified, skipping prompt');
      return true;
    }

    // If verification is in progress, wait for it to complete.

    if (_verificationCompleter != null &&
        !_verificationCompleter!.isCompleted) {
      //debugPrint('⚠️ Security key verification already in progress, waiting...');

      // Wait for the existing verification to complete and return its result.

      return _verificationCompleter!.future;
    }

    // Start new verification process.

    _verificationCompleter = Completer<bool>();

    try {
      // Check if security key exists.

      final hasKey = await KeyManager.hasSecurityKey();

      if (hasKey) {
        //debugPrint('⚠️ Security key found, no prompt needed');
        _keyVerified = true;
        _verificationCompleter!.complete(true);
        return true;
      }

      // Get verification key.

      final verificationKey = await KeyManager.getVerificationKey();

      // If no verification key, no security key is needed.

      if (verificationKey.isEmpty) {
        //debugPrint('⚠️ No verification key found, no security key needed');
        _keyVerified = true;
        _verificationCompleter!.complete(true);
        return true;
      }

      // Show security key prompt once.

      if (!context.mounted) {
        _verificationCompleter!.complete(false);
        return false;
      }

      //debugPrint('⚠️ Showing security key prompt');

      // Attempt to get the key using the standard SolidPod function

      try {
        await getKeyFromUserIfRequired(context, child);
      } catch (e) {
        debugPrint('⚠️ Error showing key dialogue: $e');
      }

      // Double-check if key was provided.

      final hasKeyNow = await KeyManager.hasSecurityKey();
      _keyVerified = hasKeyNow;

      _verificationCompleter!.complete(hasKeyNow);
      return hasKeyNow;
    } catch (e) {
      //debugPrint('⚠️ Error in security key verification: $e');
      _verificationCompleter?.complete(false);
      return false;
    } finally {
      // If the completer didn't complete for some reason, complete it now.

      if (_verificationCompleter != null &&
          !_verificationCompleter!.isCompleted) {
        _verificationCompleter!.complete(false);
      }
    }
  }

  /// Reset the key verification status.
  ///
  /// Should be called when logging out or when key needs re-verification.

  void reset() {
    _keyVerified = false;

    // Clear any in-progress verification.

    if (_verificationCompleter != null &&
        !_verificationCompleter!.isCompleted) {
      _verificationCompleter!.complete(false);
    }
    _verificationCompleter = null;

    //debugPrint('⚠️ Security key verification status reset');
  }
}
