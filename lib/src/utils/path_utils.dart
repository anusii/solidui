/// Path utilities for SolidUI.
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

/// Utility class for path operations in SolidUI.
///
/// This class provides methods to normalise and manipulate paths used in
/// file browsing operations. All paths are treated as relative to the Pod
/// root and should not have leading forward slashes.

class PathUtils {
  const PathUtils._();

  /// Normalises a relative path by removing leading and trailing slashes.
  ///
  /// This ensures paths are consistently formatted for use with solidpod's
  /// `PathType.relativeToPod` option, which expects paths without leading
  /// slashes.
  ///
  /// Examples:
  /// - `/myapp/data` becomes `myapp/data`
  /// - `myapp/data/` becomes `myapp/data`
  /// - `//myapp//data//` becomes `myapp/data`
  /// - `` remains ``
  /// - `/` becomes ``

  static String normalise(String path) {
    if (path.isEmpty) return '';

    // Remove leading slashes.

    String normalised = path;
    while (normalised.startsWith('/')) {
      normalised = normalised.substring(1);
    }

    // Remove trailing slashes.

    while (normalised.endsWith('/')) {
      normalised = normalised.substring(0, normalised.length - 1);
    }

    // Remove consecutive slashes.

    normalised = normalised.replaceAll(RegExp(r'/+'), '/');

    return normalised;
  }

  /// Joins path segments into a normalised path.
  ///
  /// All segments are normalised and empty segments are filtered out.
  ///
  /// Examples:
  /// - join(['myapp', 'data', 'file.ttl']) returns `myapp/data/file.ttl`
  /// - join(['/myapp/', '/data/', 'file.ttl']) returns `myapp/data/file.ttl`
  /// - join(['', 'myapp', '', 'data']) returns `myapp/data`

  static String join(List<String> segments) {
    final normalisedSegments =
        segments.map(normalise).where((s) => s.isNotEmpty).toList();

    return normalisedSegments.join('/');
  }

  /// Extracts the relative path from a full path given a root path.
  ///
  /// Both paths are normalised before comparison. If the full path does not
  /// start with the root path, the full normalised path is returned.
  ///
  /// Examples:
  /// - relativeTo('myapp/data/subfolder', 'myapp/data') returns `subfolder`
  /// - relativeTo('/myapp/data/subfolder', '/myapp/data') returns `subfolder`
  /// - relativeTo('myapp/data', 'myapp/data') returns ``
  /// - relativeTo('other/path', 'myapp/data') returns `other/path`

  static String relativeTo(String fullPath, String rootPath) {
    final normalisedFull = normalise(fullPath);
    final normalisedRoot = normalise(rootPath);

    if (normalisedRoot.isEmpty) {
      return normalisedFull;
    }

    if (normalisedFull == normalisedRoot) {
      return '';
    }

    if (normalisedFull.startsWith('$normalisedRoot/')) {
      return normalisedFull.substring(normalisedRoot.length + 1);
    }

    return normalisedFull;
  }

  /// Combines a directory path and a file name into a full path.
  ///
  /// Both are normalised before joining.
  ///
  /// Examples:
  /// - combine('myapp/data', 'file.ttl') returns `myapp/data/file.ttl`
  /// - combine('/myapp/data/', '/file.ttl') returns `myapp/data/file.ttl`
  /// - combine('', 'file.ttl') returns `file.ttl`

  static String combine(String directoryPath, String fileName) {
    return join([directoryPath, fileName]);
  }

  /// Checks if a path is the root (empty or just slashes).
  ///
  /// Examples:
  /// - isRoot('') returns true
  /// - isRoot('/') returns true
  /// - isRoot('//') returns true
  /// - isRoot('myapp') returns false

  static bool isRoot(String path) {
    return normalise(path).isEmpty;
  }

  /// Gets the parent directory of a path.
  ///
  /// Returns empty string if the path has no parent (is root or single
  /// segment).
  ///
  /// Examples:
  /// - parent('myapp/data/subfolder') returns `myapp/data`
  /// - parent('myapp') returns ``
  /// - parent('') returns ``

  static String parent(String path) {
    final normalised = normalise(path);
    final lastSlash = normalised.lastIndexOf('/');
    if (lastSlash == -1) {
      return '';
    }
    return normalised.substring(0, lastSlash);
  }

  /// Returns the display label for a resource name, respecting the current
  /// display mode.
  ///
  /// - When [showTitle] is true and [titleData] contains [name], the mapped
  ///   title is returned; otherwise falls back to [name].
  /// - When [showFullPath] is true the full [name] is returned.
  /// - Otherwise the last path segment (basename) is returned.

  static String resourceDisplayName(
    String name, {
    required bool showFullPath,
    bool showTitle = false,
    Map<String, String>? titleData,
  }) {
    if (showTitle && titleData != null) {
      return titleData[name] ?? basename(name);
    }
    return showFullPath ? name : basename(name);
  }

  /// Gets the last segment (file or directory name) of a path.
  ///
  /// Examples:
  /// - basename('myapp/data/file.ttl') returns `file.ttl`
  /// - basename('myapp') returns `myapp`
  /// - basename('') returns ``

  static String basename(String path) {
    final normalised = normalise(path);
    final lastSlash = normalised.lastIndexOf('/');
    if (lastSlash == -1) {
      return normalised;
    }
    return normalised.substring(lastSlash + 1);
  }
}
