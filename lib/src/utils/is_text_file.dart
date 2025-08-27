/// Utility function to check if a file is a text file.
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
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
    '.jsonld'
  };

  return textExtensions.contains(extension);
}
