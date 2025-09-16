/// Upload operations for SolidUI.
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
/// Authors: Tony Chen

library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/utils/is_text_file.dart';

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

      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.path == null) return;

      if (!context.mounted) return;

      // Show loading dialog.

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Uploading'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Please wait...'),
            ],
          ),
        ),
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

        // Determine upload path.

        String uploadPath = remoteFileName;
        if (currentPath.isNotEmpty && currentPath != '/') {
          // Remove leading slash if present.

          final cleanPath = currentPath.startsWith('/')
              ? currentPath.substring(1)
              : currentPath;
          uploadPath = '$cleanPath/$remoteFileName';
        }

        if (!context.mounted) return;

        // Upload file with encryption.

        final result = await writePod(
          uploadPath,
          fileContent,
          context,
          const Text('Upload'),
          encrypted: true,
        );

        if (!context.mounted) return;

        // Close loading dialog.

        Navigator.of(context).pop();

        if (result == SolidFunctionCallStatus.success) {
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
        } else {
          // Show error message.

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Upload failed - please check your connection and permissions',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          // Close loading dialog if still open.

          Navigator.of(context).pop();

          // Show error message.

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
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
