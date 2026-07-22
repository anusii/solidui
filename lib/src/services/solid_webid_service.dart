/// Service for reading and patching the user's own WebID document.
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

library;

import 'dart:convert' show utf8;

import 'package:solidpod/solidpod.dart';

/// The `solid:` terms namespace used for OIDC issuer discovery and
/// registration-token verification on a WebID document.

const String _solidTermsNs = 'http://www.w3.org/ns/solid/terms#';

const String _oidcIssuerPredicate = '${_solidTermsNs}oidcIssuer';
const String _oidcIssuerRegistrationTokenPredicate =
    '${_solidTermsNs}oidcIssuerRegistrationToken';

/// Reads and patches the RDF triples on the logged-in user's own WebID
/// document — specifically the `solid:oidcIssuerRegistrationToken` and
/// `solid:oidcIssuer` triples used to link the WebID to another Solid Pod
/// server's login. All writes are targeted SPARQL PATCH updates so the rest
/// of the WebID document (name, storage, other triples) is left untouched.

class SolidWebIdService {
  SolidWebIdService._();

  static final SolidWebIdService _instance = SolidWebIdService._();

  /// Singleton accessor.

  static SolidWebIdService get instance => _instance;

  /// Resolves the logged-in user's WebID together with its document URL
  /// (the WebID with any `#fragment` stripped).

  Future<({String webId, String docUrl})> _current() async {
    final webId = await getWebId();
    if (webId == null || webId.isEmpty) {
      throw StateError('Cannot resolve the WebID: not logged in.');
    }
    return (webId: webId, docUrl: webId.split('#').first);
  }

  /// Fetches the raw turtle content of the logged-in user's own WebID
  /// document.

  Future<String> fetchWebIdTurtle() async {
    if (!await isUserLoggedIn()) {
      throw StateError('You must be logged in to view your WebID.');
    }
    final docUrl = (await _current()).docUrl;
    final bytes = await getResource(docUrl);
    return utf8.decode(bytes);
  }

  /// Looks for a pending `solid:oidcIssuerRegistrationToken` triple in
  /// [turtle] (as previously fetched by [fetchWebIdTurtle]) and returns its
  /// literal value, or `null` when none is present.

  String? findPendingRegistrationToken(String turtle) {
    Map<String, Map<String, dynamic>> map;
    try {
      map = turtleToTripleMap(turtle);
    } catch (_) {
      return null;
    }
    for (final entry in map.values) {
      final value = entry[_oidcIssuerRegistrationTokenPredicate];
      if (value is String && value.trim().isNotEmpty) return value;
      if (value is Iterable && value.isNotEmpty) {
        final first = value.first;
        if (first is String && first.trim().isNotEmpty) return first;
      }
    }
    return null;
  }

  /// Adds a `solid:oidcIssuerRegistrationToken` triple carrying [token] to
  /// the user's WebID document, proving ownership to another Pod server
  /// that is being linked.

  Future<void> addRegistrationToken(String token) async {
    final (:webId, :docUrl) = await _current();
    final escaped = _escapeLiteral(token);
    final query = 'INSERT DATA '
        '{<$webId> <$_oidcIssuerRegistrationTokenPredicate> "$escaped"};';
    await updateFileByQuery(docUrl, query);
  }

  /// Removes any `solid:oidcIssuerRegistrationToken` triple and adds a
  /// `solid:oidcIssuer` triple pointing at [podIssuerUrl], completing a Pod
  /// link once the other Pod server has verified the token.

  Future<void> completeLink(String podIssuerUrl) async {
    final (:webId, :docUrl) = await _current();
    final issuerUrl = podIssuerUrl.endsWith('/')
        ? podIssuerUrl.substring(0, podIssuerUrl.length - 1)
        : podIssuerUrl;
    final query = 'DELETE {<$webId> <$_oidcIssuerRegistrationTokenPredicate>'
        ' ?o} WHERE {<$webId> <$_oidcIssuerRegistrationTokenPredicate> ?o};'
        ' INSERT DATA {<$webId> <$_oidcIssuerPredicate> <$issuerUrl>};';
    await updateFileByQuery(docUrl, query);
  }

  // Escapes characters that would otherwise break out of the SPARQL string
  // literal when interpolating untrusted user input (the registration
  // token).

  String _escapeLiteral(String value) =>
      value.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
}
