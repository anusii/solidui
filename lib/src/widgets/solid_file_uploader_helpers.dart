/// File Uploader Helper Functions.
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

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

import 'package:solidui/src/utils/is_text_file.dart';

/// Helper class for file uploader operations.

class SolidFileUploaderHelpers {
  /// Handles file selection via file picker.

  static Future<String?> pickFile() async {
    final file = await FilePicker.pickFile();
    if (file != null) {
      return file.path;
    }
    return null;
  }

  /// Generates file preview content.

  static Future<String> generateFilePreview(String filePath) async {
    try {
      final file = File(filePath);
      final fileName = path.basename(filePath);

      if (isTextFile(filePath)) {
        // For text files, read content.

        final content = await file.readAsString();
        return content.length > 500
            ? '${content.substring(0, 500)}...'
            : content;
      } else {
        // For binary files, show basic info

        final bytes = await file.readAsBytes();
        return 'Binary file\n'
            'Name: $fileName\n'
            'Size: ${(bytes.length / 1024).toStringAsFixed(2)} KB\n'
            'Type: ${path.extension(fileName)}';
      }
    } catch (e) {
      return 'Error reading file: $e';
    }
  }

  /// Builds upload status widget.

  static Widget buildUploadStatus({
    required bool uploadInProgress,
    required bool uploadDone,
    required String? remoteFileName,
    required String? cleanFileName,
  }) {
    if (uploadInProgress) {
      return const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 8),
          Text('Uploading...'),
        ],
      );
    }

    if (uploadDone) {
      return Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 48),
          const SizedBox(height: 8),
          const Text('Upload completed successfully!'),
          if (remoteFileName != null) ...[
            const SizedBox(height: 8),
            Text('Remote file: $remoteFileName'),
          ],
          if (cleanFileName != null) ...[
            const SizedBox(height: 4),
            Text('Original name: $cleanFileName'),
          ],
        ],
      );
    }

    return const SizedBox.shrink();
  }

  /// Builds file info display widget.

  static Widget buildFileInfo(String? uploadFile) {
    if (uploadFile == null) return const SizedBox.shrink();

    final fileName = path.basename(uploadFile);
    final fileExtension = path.extension(uploadFile);
    final file = File(uploadFile);

    return FutureBuilder<int>(
      future: file.length(),
      builder: (context, snapshot) {
        final fileSize = snapshot.data ?? 0;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected File:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('Name: $fileName'),
                Text(
                  'Type: ${fileExtension.isEmpty ? 'Unknown' : fileExtension}',
                ),
                Text('Size: ${(fileSize / 1024).toStringAsFixed(2)} KB'),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds a preview card UI component.

  static Widget buildPreviewCard(
    BuildContext context,
    String? filePreview,
    VoidCallback onClose,
  ) {
    if (filePreview == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8.0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.preview,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Preview',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Text(
                filePreview,
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
