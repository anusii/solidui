/// Upload operations for SolidUI.
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
/// Authors: Tony Chen

library;

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:solidpod/solidpod.dart';
import 'package:solidui/src/utils/is_text_file.dart';
import 'package:solidui/src/utils/loading_dialog_controller.dart';
import 'package:solidui/src/utils/path_utils.dart';
import 'package:solidui/src/utils/solid_pod_helpers.dart';

/// Upload operations for SolidUI widgets.

class SolidFileUploadOperations {
  const SolidFileUploadOperations._();

  /// Default file upload implementation.

  static Future<void> uploadFile(
    BuildContext context,
    String currentPath, {
    VoidCallback? onSuccess,
  }) async {
    try {
      // Pick file to upload.

      final result = await FilePicker.pickFiles();
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.path == null) return;

      if (!context.mounted) return;

      // Show loading dialog via a controller, so it can be torn down
      // reliably in the `finally` block even if the originating context
      // is unmounted while the upload is in flight.

      final loading = LoadingDialogController.show(
        context: context,
        title: 'Uploading',
      );

      try {
        final localFile = File(file.path!);
        String fileContent;

        // Read file content.

        if (isTextFile(file.path!)) {
          fileContent = await localFile.readAsString();
        } else {
          final bytes = await localFile.readAsBytes();
          fileContent = base64Encode(bytes);
        }

        // Sanitise file name and append encryption extension.

        String sanitizedFileName = path
            .basename(file.path!)
            .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')
            .replaceAll(RegExp(r'\.enc\.ttl$'), '');

        final remoteFileName = '$sanitizedFileName.enc.ttl';

        // Construct the full upload path relative to the Pod root.

        final normalisedCurrentPath = PathUtils.normalise(currentPath);
        final uploadPath = normalisedCurrentPath.isNotEmpty
            ? PathUtils.combine(normalisedCurrentPath, remoteFileName)
            : remoteFileName;

        if (!context.mounted) return;

        // Ensure the security key is available before writing encrypted data.

        await getKeyFromUserIfRequired(
          context,
          const Text('Please enter your security key to upload the file'),
        );

        if (!context.mounted) return;

        // Upload file with encryption using PathType.relativeToPod.

        await writePod(
          uploadPath,
          fileContent,
          encrypted: true,
          pathType: PathType.relativeToPod,
        );

        if (!context.mounted) return;

        // Show success message.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File "${file.name}" uploaded successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Call success callback if provided.

        onSuccess?.call();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } finally {
        // Always tear down the loading dialog, even if we returned early
        // because the originating context became unmounted.

        loading.close();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
