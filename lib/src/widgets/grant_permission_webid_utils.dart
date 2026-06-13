/// WebID comparison helpers used by the grant permission form.
///
/// Copyright (C) 2024-2026, Software Innovation Institute, ANU.
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
/// Authors: Jess Moore, Anushka Vidanage

library;

/// Message shown when the recipient WebID is the same as the resource
/// owner. Surfaced both for the individual recipient flow and as part of
/// the group flow when one of the group entries matches the owner.

const String selfShareMessage =
    'This resource is owned by you, so you already have full access. Please '
    'enter the WebID of another user if you would like to share this '
    'resource.';

/// Returns true when [webId] refers to the same WebID as [ownerWebId],
/// ignoring surrounding whitespace and trailing slashes. The comparison is
/// intentionally loose because the owner's WebID is captured from different
/// sources (login session, ACL lookup) and the trailing-slash form may vary
/// between them.

bool isSelfShare(String webId, String ownerWebId) {
  final entered = _normaliseWebId(webId);
  if (entered.isEmpty) return false;
  final owner = _normaliseWebId(ownerWebId);
  return owner.isNotEmpty && entered == owner;
}

String _normaliseWebId(String webId) {
  final trimmed = webId.trim();
  if (trimmed.isEmpty) return trimmed;
  // Drop a trailing slash on the WebID document portion so that, for
  // example, `https://alice.example/profile/card#me` and
  // `https://alice.example/profile/card/#me` compare equal.
  final hashIndex = trimmed.indexOf('#');
  final docPart = hashIndex >= 0 ? trimmed.substring(0, hashIndex) : trimmed;
  final fragment = hashIndex >= 0 ? trimmed.substring(hashIndex) : '';
  final canonicalDoc = docPart.endsWith('/')
      ? docPart.substring(0, docPart.length - 1)
      : docPart;
  return '$canonicalDoc$fragment'.toLowerCase();
}
