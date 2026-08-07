/// Solid WebID parser utility.
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

/// Parsed identity details extracted from a Solid WebID.
///
/// A Solid WebID is a URL that uniquely identifies a user on a remote Solid
/// server, for example
/// `https://pods.solidcommunity.au/watson01/profile/card#me`. Parsing yields
/// the [username] (`watson01`), the server [host] (`pods.solidcommunity.au`),
/// as well as the [scheme] and [port] so callers can reconstruct derived URLs
/// such as the server URI or the user's profile card URL without having to
/// re-parse the original WebID string.

class WebIdParts {
  const WebIdParts({
    required this.webId,
    required this.scheme,
    required this.host,
    required this.port,
    required this.username,
  });

  /// The original WebID string from which the parts were extracted.

  final String webId;

  /// URL scheme, typically `https`.

  final String scheme;

  /// Server host (domain) portion of the WebID.

  final String host;

  /// TCP port specified in the WebID URL. Uses 0 when the URL omits a port.

  final int port;

  /// Username segment taken from the first path component. Empty when the
  /// WebID URL has no path segments.

  final String username;

  /// Server URL comprising scheme, host, and a non-default port when present.
  ///
  /// Returns strings such as `https://pods.solidcommunity.au` or
  /// `http://localhost:3000` depending on the original WebID.

  String get serverUri {
    final hasCustomPort = port != 0 && port != 80 && port != 443;
    final schemeUri =
        'scheme://$host'
        ':$port';
    return hasCustomPort ? schemeUri : '$scheme://$host';
  }

  /// Host and username joined with a slash for compact display, for example
  /// `pods.solidcommunity.au/watson01`. Falls back to the host alone when no
  /// username is available.

  String get hostWithUsername => username.isEmpty ? host : '$host/$username';

  /// Canonical profile card URL reconstructed from the parsed components,
  /// for example `https://pods.solidcommunity.au/watson01/profile/card#`.
  /// Falls back to the original [webId] when a username is missing.

  String get profileCardUrl =>
      username.isEmpty ? webId : '$scheme://$host/$username/profile/card#';

  /// Try to parse a WebID URL into its components.
  ///
  /// Returns `null` when [webId] is null, empty, or cannot be parsed into a
  /// URL carrying a non-empty host. Callers should handle the `null` case
  /// with whatever fallback presentation suits their context.

  static WebIdParts? tryParse(String? webId) {
    if (webId == null || webId.isEmpty) return null;
    try {
      final uri = Uri.parse(webId);
      if (uri.host.isEmpty) return null;
      final segments = uri.pathSegments;
      final username = segments.isNotEmpty ? segments.first : '';
      return WebIdParts(
        webId: webId,
        scheme: uri.scheme.isEmpty ? 'https' : uri.scheme,
        host: uri.host,
        port: uri.port,
        username: username,
      );
    } catch (_) {
      return null;
    }
  }

  /// Produce a short, human-readable representation of a WebID suitable for
  /// display in navigation drawers, status bars, and similar UI surfaces.
  ///
  /// When [webId] parses cleanly this returns [hostWithUsername], for example
  /// `pods.solidcommunity.au/watson01`. If [webId] cannot be parsed, this
  /// falls back to stripping the `http(s)://` prefix and the conventional
  /// `/profile/card#me` suffix so the caller still gets a compact string
  /// rather than the raw, unhelpful input.

  static String formatForDisplay(String webId) {
    final parts = tryParse(webId);
    if (parts != null) {
      return parts.hostWithUsername;
    }

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
  }
}
