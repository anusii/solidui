/// Sort options for the file browser.
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

/// Sorting options for files and directories in the file browser.
///
/// Each option combines a sort field with a direction (ascending or
/// descending). The [displayLabel] property provides a human-readable
/// description suitable for use in menus.

enum FileSortOption {
  /// Sort by file/directory name, A to Z.

  nameAscending('Name', 'A → Z'),

  /// Sort by file/directory name, Z to A.

  nameDescending('Name', 'Z → A'),

  /// Sort by modification date, oldest first.

  dateModifiedAscending('Date Modified', 'Oldest first'),

  /// Sort by modification date, newest first.

  dateModifiedDescending('Date Modified', 'Newest first'),

  /// Sort by file type/extension, A to Z.

  typeAscending('Type', 'A → Z'),

  /// Sort by file type/extension, Z to A.

  typeDescending('Type', 'Z → A');

  /// Display label for the sort field.

  final String fieldLabel;

  /// Display label for the sort direction.

  final String directionLabel;

  const FileSortOption(this.fieldLabel, this.directionLabel);

  /// Full display label combining field and direction.

  String get displayLabel => '$fieldLabel ($directionLabel)';
}
