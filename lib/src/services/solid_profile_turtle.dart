/// Turtle (linked-data) builders and parsers for profile data.
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
/// Authors: Tony Chen, Graham Williams

// 20260718 gjw Extracted verbatim from solid_profile_service.dart to keep
// that file within the 300 code-line limit after the startup-cache work.
// These helpers are pure text transformations with no Pod I/O; the WebID
// is passed in by the caller rather than fetched here.

library;

import 'dart:convert' show base64Decode, base64Encode;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;

import 'package:rdflib/rdflib.dart' show Literal, Namespace, URIRef;
import 'package:solidpod/solidpod.dart';

/// Build the linked-data turtle for the display name. The user's [webId] is
/// used as the subject so the triple is meaningful when read independently
/// by other agents and queries. We emit both `foaf:name` (the most widely
/// understood "name" predicate) and `vcard:fn` (the VCard "formatted name")
/// so different consumers can pick whichever they recognise.

String buildDisplayNameTtl(String webId, String name) {
  final subject = URIRef(webId.isEmpty ? '#me' : webId);
  final triples = <URIRef, Map<URIRef, dynamic>>{
    subject: {
      FoafPredicate.name.uriRef: Literal(name),
      VcardPredicate.fn.uriRef: Literal(name),
    },
  };

  // rdflib auto-binds the FOAF prefix (it lives in its standardPrefixes
  // table) so passing it again throws "foaf: already exists in prefixed
  // namespaces". We only need to register prefixes outside that set.

  return tripleMapToTurtle(
    triples,
    bindNamespaces: {'vcard': Namespace(ns: SolidConstants.namespaces.vcard)},
  );
}

/// Build the linked-data turtle for the avatar. The image is embedded as a
/// standard `data:` URI on `vcard:hasPhoto`, anchored on the user's [webId],
/// so it is interpretable by any vcard-aware reader. The whole file is
/// wrapped through writePod() which handles encryption transparently.

String buildAvatarTtl(String webId, Uint8List pngBytes) {
  final subject = URIRef(webId.isEmpty ? '#me' : webId);
  final dataUri = 'data:image/png;base64,${base64Encode(pngBytes)}';
  final triples = <URIRef, Map<URIRef, dynamic>>{
    subject: {VcardPredicate.hasPhoto.uriRef: URIRef(dataUri)},
  };
  return tripleMapToTurtle(
    triples,
    bindNamespaces: {'vcard': Namespace(ns: SolidConstants.namespaces.vcard)},
  );
}

/// Find the first display-name literal in the (decrypted) turtle. Tries
/// foaf:name then vcard:fn.

String? extractDisplayName(String ttl) {
  Map<String, Map<String, dynamic>> map;
  try {
    map = turtleToTripleMap(ttl);
  } catch (_) {
    return null;
  }
  for (final pred in [FoafPredicate.name.value, VcardPredicate.fn.value]) {
    for (final entry in map.values) {
      final value = entry[pred];
      if (value == null) continue;
      if (value is String && value.trim().isNotEmpty) return value;
      if (value is Iterable && value.isNotEmpty) {
        final first = value.first;
        if (first is String && first.trim().isNotEmpty) return first;
      }
    }
  }
  return null;
}

/// Locate the vcard:hasPhoto data URI in the (decrypted) turtle and decode
/// its base64 payload back to PNG bytes.

Uint8List? extractAvatarBytes(String ttl) {
  Map<String, Map<String, dynamic>> map;
  try {
    map = turtleToTripleMap(ttl);
  } catch (_) {
    return null;
  }

  String? findPhotoUri() {
    for (final entry in map.values) {
      final v = entry[VcardPredicate.hasPhoto.value];
      if (v is String && v.isNotEmpty) return v;
      if (v is Iterable && v.isNotEmpty && v.first is String) {
        return v.first as String;
      }
    }
    return null;
  }

  final photo = findPhotoUri();
  if (photo == null) return null;

  // Expecting a `data:image/<type>;base64,<payload>` URI.

  const marker = ';base64,';
  final idx = photo.indexOf(marker);
  if (!photo.startsWith('data:') || idx < 0) return null;

  try {
    return base64Decode(photo.substring(idx + marker.length));
  } catch (e) {
    debugPrint('extractAvatarBytes: $e');
    return null;
  }
}
