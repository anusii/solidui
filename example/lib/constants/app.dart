/// Constants used throughout the app.
///
// Time-stamp: <Friday 2026-07-24 11:17:22 +1000 Graham Williams>
///
/// Copyright (C) 2024, Software Innovation Institute, ANU.
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

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

const String appTitle = 'DemoPod - Solid Pod Demonstrator';

const titleBackgroundColor = Color(0xFFF0E4D7);

// const dataFile = 'key-value.ttl';
const dataFile = 'keyvalue/key-value.ttl';

//const dataFilePlain = 'key-value-plain.ttl';
const dataFilePlain = dataFile;

String createDemoTtlStr(String fileName) {
  return '''@prefix demo: <#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .

demo:sampleData$fileName a demo:DemoResource ;
    rdfs:label "Demo File $fileName" ;
    demo:created "${DateTime.now().toIso8601String()}" ;
    demo:description "This is a file containing some demo ttl content" ;
    foaf:maker "Solid Demo" .

demo:exampleData$fileName
    demo:sampleProperty "Sample value" ;
    demo:category "demo-data".
''';
}

/// URL of the Solid-OIDC client identifier document.
const clientIdVal =
    'https://anusii.github.io/solidui/example/client-profile.jsonld';

/// Redirect URIs offered to the Solid-OIDC flow.
List<String> get redirectUrisList {
  if (kIsWeb) {
    return ['${Uri.base.origin}/redirect.html'];
  }
  return const [
    'com.example.soliduieg://redirect',
    'http://localhost:4400/redirect.html',
  ];
}

/// Post-logout redirect URIs, derived the same origin-aware way as
/// [redirectUrisList].
List<String> get postLogoutRedirectUrisList {
  if (kIsWeb) {
    return ['${Uri.base.origin}/redirect.html'];
  }
  return const [
    'com.example.soliduieg://redirect',
    'http://localhost:4400/redirect.html',
  ];
}
