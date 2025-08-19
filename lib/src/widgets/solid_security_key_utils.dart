/// Common utilities for working with security key RDF data.
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
/// Authors: Dawei Chen, Graham Williams, Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:rdflib/rdflib.dart';
import 'package:solidpod/solidpod.dart' show KeyManager;

/// Parses enc-key file information and extracts content into a map.
///
/// This function processes the provided file information, which is expected to be
/// in Turtle (Terse RDF Triple Language) format. It uses a graph-based approach
/// to parse the Turtle data and extract key attributes and their values.
///
/// Parameters:
/// - [fileInfo]: The RDF/Turtle formatted string containing encryption key data
///
/// Returns a Map containing the parsed key-value pairs from the RDF data.

Map<dynamic, dynamic> parseEncKeyContent(String fileInfo) {
  final g = Graph();
  g.parseTurtle(fileInfo);
  final fileContentMap = {};
  final fileContentList = [];

  for (final t in g.triples) {
    final predicate = t.pre.value as String;
    if (predicate.contains('#')) {
      final subject = t.sub.value;
      final attributeName = predicate.split('#')[1];
      final attrVal = t.obj.value.toString();
      if (attributeName != 'type') {
        fileContentList.add([subject, attributeName, attrVal]);
      }
      fileContentMap[attributeName] = [subject, attrVal];
    }
  }

  return fileContentMap;
}

/// Utility functions for security key status checking.
///
/// This class provides static methods for common security key operations
/// that can be used across different Solid applications.

class SolidSecurityKeyUtils {
  /// Checks if a security key is currently saved.
  ///
  /// This is a convenience method that wraps the KeyManager.hasSecurityKey()
  /// call with proper error handling.

  static Future<bool> isKeySaved() async {
    try {
      return await KeyManager.hasSecurityKey();
    } catch (e) {
      debugPrint('Error checking security key status: $e');
      return false;
    }
  }

  /// Fetches the security key status with callback support.
  ///
  /// This function checks if an encryption key is available for the user.
  /// It provides a simple way to check key status and optionally trigger
  /// a callback when the status is determined.
  ///
  /// Parameters:
  /// - [onKeyStatusChanged]: Optional callback that receives the key status
  ///
  /// Returns true if a security key exists, false otherwise.

  static Future<bool> fetchKeySavedStatus(
      [Function(bool)? onKeyStatusChanged]) async {
    try {
      // Simply check if the security key exists in memory.

      final hasKey = await KeyManager.hasSecurityKey();

      // Call the callback if provided.

      if (onKeyStatusChanged != null) {
        onKeyStatusChanged(hasKey);
      }

      return hasKey;
    } catch (e) {
      debugPrint('Error fetching security key status: $e');
      return false;
    }
  }

  /// Checks if a security key is needed for the current user.
  ///
  /// This method determines if a security key needs to be set up
  /// by checking both the current key status and verification key.

  static Future<bool> isSecurityKeyNeeded() async {
    try {
      // If key already exists, it's not needed to be set.

      final hasKey = await KeyManager.hasSecurityKey();
      if (hasKey) return false;

      // Check if a verification key exists (indicating encryption is used).

      final verificationKey = await KeyManager.getVerificationKey();
      return verificationKey.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if security key is needed: $e');
      return false;
    }
  }

  /// Gets a user-friendly status message for the security key.
  ///
  /// Returns a string describing the current security key status
  /// that can be displayed to users.

  static Future<String> getSecurityKeyStatusMessage() async {
    try {
      final hasKey = await KeyManager.hasSecurityKey();
      if (hasKey) {
        return 'Security key is saved and ready';
      }

      final verificationKey = await KeyManager.getVerificationKey();
      if (verificationKey.isNotEmpty) {
        return 'Security key is required but not set';
      }

      return 'No security key needed';
    } catch (e) {
      debugPrint('Error getting security key status message: $e');
      return 'Unable to determine security key status';
    }
  }
}
