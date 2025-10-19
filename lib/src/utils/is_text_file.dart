/// Utility function to check if a file is a text file.
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
/// Authors: Tony Chen (migrated from MovieStar)

library;

import 'package:path/path.dart' as path;

/// Checks if a file is a text file based on its extension.
///
/// Returns true if the file has a text-based extension, false otherwise.

bool isTextFile(String filePath) {
  final extension = path.extension(filePath).toLowerCase();

  const textExtensions = {
    '.txt',
    '.md',
    '.json',
    '.xml',
    '.yaml',
    '.yml',
    '.csv',
    '.html',
    '.htm',
    '.css',
    '.js',
    '.ts',
    '.dart',
    '.py',
    '.java',
    '.cpp',
    '.c',
    '.h',
    '.php',
    '.rb',
    '.go',
    '.rs',
    '.swift',
    '.kt',
    '.scala',
    '.sh',
    '.bat',
    '.ps1',
    '.sql',
    '.log',
    '.ini',
    '.cfg',
    '.conf',
    '.properties',
    '.gitignore',
    '.dockerfile',
    '.makefile',
    '.readme',
    '.license',
    '.changelog',
    '.ttl',
    '.rdf',
    '.owl',
    '.n3',
    '.nt',
    '.jsonld',
  };

  return textExtensions.contains(extension);
}
