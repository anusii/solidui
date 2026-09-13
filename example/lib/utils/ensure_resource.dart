/// Utility to ensure a Pod resource exists before performing actions on it.
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

// ignore_for_file: use_build_context_synchronously

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart'
    show
        ResourceStatus,
        checkResourceStatus,
        createContainer,
        filenameToResourceUrl,
        writePod;

import 'package:demopod/dialogs/alert.dart';

/// Ensures the resource at [relativePath] exists in the user's Pod.
///
/// The [relativePath] is interpreted relative to the app's data directory
/// (e.g. `keyvalue/key-value.ttl`). When the resource is missing on the Pod,
/// a new file is created using [defaultContent] (encrypted by default) so
/// downstream actions such as granting permissions do not fail.
///
/// Returns `true` when the resource is available (already existed or was
/// just created), and `false` otherwise.

Future<bool> ensurePodResourceExists(
  BuildContext context, {
  required String relativePath,
  required String defaultContent,
  bool encrypted = true,
}) async {
  try {
    final fileUrl = await filenameToResourceUrl(fileName: relativePath);

    final status = await checkResourceStatus(fileUrl);

    switch (status) {
      case ResourceStatus.exist:
        return true;

      case ResourceStatus.notExist:
        await _ensureParentContainerWithAcl(relativePath);
        await writePod(relativePath, defaultContent, encrypted: encrypted);

        if (context.mounted) {
          await alert(
            context,
            'The resource "$relativePath" did not exist on your Pod, '
            'so a new file with placeholder content has been created '
            'automatically.',
          );
        }
        return true;

      case ResourceStatus.forbidden:
        if (context.mounted) {
          await alert(
            context,
            'Access to "$relativePath" is forbidden. Please check the '
            'permissions on your Pod and try again.',
          );
        }
        return false;

      case ResourceStatus.unknown:
        if (context.mounted) {
          await alert(
            context,
            'Unable to determine whether "$relativePath" exists on your Pod. '
            'Please try again in a moment.',
          );
        }
        return false;
    }
  } on Object catch (e) {
    debugPrint('ensurePodResourceExists() failed: $e');
    if (context.mounted) {
      await alert(
        context,
        'Failed to ensure "$relativePath" exists on your Pod: $e',
      );
    }
    return false;
  }
}

/// Ensures the parent folder of [relativePath] exists on the Pod with its own
/// `.acl` file.
///
/// [relativePath] is a file path relative to the app's data directory (e.g.
/// `keyvalue/key-value.ttl`). When the path contains no folder component the
/// file sits directly in the data root and there is nothing to create.
///
/// If the parent folder already exists it is left untouched (it may already
/// carry an `.acl`); otherwise [createContainer] creates it together with a
/// default `.acl` so the folder can be shared.

Future<void> _ensureParentContainerWithAcl(String relativePath) async {
  final slash = relativePath.lastIndexOf('/');
  if (slash < 0) return;

  final dirPath = relativePath.substring(0, slash);

  // Resolve the directory URL relative to the app data directory (the same
  // convention used by writePod and createContainer). filenameToResourceUrl
  // prepends `appname/data` and is idempotent for paths that already include
  // it.

  final dirUrl = await filenameToResourceUrl(
    fileName: dirPath,
    isFile: false,
  );

  // Skip creation if the folder already exists; createContainer would fail on
  // an existing container, and an existing folder may already have its `.acl`.

  if (await checkResourceStatus(dirUrl, isFile: false) ==
      ResourceStatus.exist) {
    return;
  }

  // Split the directory path into its parent path and leaf folder name as
  // expected by createContainer.

  final sep = dirPath.lastIndexOf('/');
  final parentPath = sep < 0 ? '' : dirPath.substring(0, sep);
  final folderName = sep < 0 ? dirPath : dirPath.substring(sep + 1);

  await createContainer(parentPath, folderName);
}
