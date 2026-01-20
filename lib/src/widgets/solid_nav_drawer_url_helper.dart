/// URL helper for SolidNavDrawer widget.
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
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

/// Helper class for URL-related operations in navigation drawer.

class SolidNavDrawerUrlHelper {
  /// Simplifies the WebID URL for display purposes.
  /// Returns the domain name and username for display.

  static String getSimplifiedUrl(String webId) {
    try {
      final uri = Uri.parse(webId);
      String host = uri.host;
      String username = '';
      final pathSegments = uri.pathSegments;

      if (pathSegments.isNotEmpty) {
        username = pathSegments.first;
      }

      if (username.isNotEmpty) {
        return '$host/$username';
      } else {
        return host;
      }
    } catch (e) {
      try {
        String cleaned = webId;
        if (cleaned.startsWith('https://')) {
          cleaned = cleaned.substring(8);
        } else if (cleaned.startsWith('http://')) {
          cleaned = cleaned.substring(7);
        }
        const suffix = '/profile/card#me';
        if (cleaned.endsWith(suffix)) {
          cleaned = cleaned.substring(0, cleaned.length - suffix.length);
        }
        return cleaned;
      } catch (e2) {
        return webId;
      }
    }
  }

  /// Gets the complete profile card URL from a WebID.

  static String getProfileCardUrl(String webId) {
    try {
      final uri = Uri.parse(webId);
      final scheme = uri.scheme;
      final host = uri.host;
      final pathSegments = uri.pathSegments;

      if (pathSegments.isNotEmpty) {
        final username = pathSegments.first;
        return '$scheme://$host/$username/profile/card#';
      } else {
        return webId;
      }
    } catch (e) {
      return webId;
    }
  }

  /// Launches the profile card URL in a browser.

  static Future<void> launchProfileUrl(String webId) async {
    try {
      final profileUrl = getProfileCardUrl(webId);
      final uri = Uri.parse(profileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Cannot launch URL: $profileUrl');
      }
    } catch (e) {
      debugPrint('Error launching profile URL: $e');
    }
  }
}
