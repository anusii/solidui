/// File operations for SolidFile widget.
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

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/models/file_state.dart';
import 'package:solidui/src/utils/is_text_file.dart';

/// Helper class for file operations in SolidFile widget.

class SolidFileOperations {
  /// Handles file upload by reading its contents and encrypting it for upload.

  static Future<FileState> handleUpload(
    FileState fileState,
    String basePath,
    Future<SolidFunctionCallStatus> Function(
      String uploadPath,
      String fileContent,
    ) uploadFunction,
  ) async {
    if (fileState.uploadFile == null) return fileState;

    try {
      FileState newState = fileState.copyWith(
        uploadInProgress: true,
        uploadDone: false,
      );

      final file = File(fileState.uploadFile!);
      String fileContent;

      // For text files, we directly read the content.
      // For binary files, we encode them into base64 format.

      if (isTextFile(fileState.uploadFile!)) {
        fileContent = await file.readAsString();
      } else {
        final bytes = await file.readAsBytes();
        fileContent = base64Encode(bytes);
      }

      // Sanitise file name and append encryption extension.

      String sanitizedFileName = path
          .basename(fileState.uploadFile!)
          .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')
          .replaceAll(RegExp(r'\.enc\.ttl$'), '');

      final remoteFileName = '$sanitizedFileName.enc.ttl';
      final cleanFileName = sanitizedFileName;

      // Extract the subdirectory path.

      String? subPath =
          fileState.currentPath?.replaceFirst(basePath, '').trim();
      String uploadPath = subPath == null || subPath.isEmpty
          ? remoteFileName
          : '${subPath.startsWith("/") ? subPath.substring(1) : subPath}/$remoteFileName';

      // Upload file with encryption.

      final result = await uploadFunction(uploadPath, fileContent);

      return newState.copyWith(
        uploadDone: result == SolidFunctionCallStatus.success,
        uploadInProgress: false,
        remoteFileName: remoteFileName,
        cleanFileName: cleanFileName,
      );
    } catch (e) {
      debugPrint('Upload error: $e');
      return fileState.copyWith(uploadInProgress: false);
    }
  }

  /// Handles the download and decryption of files from the POD.

  static Future<FileState> handleDownload(
    FileState fileState,
    String basePath,
    Future<void> Function() promptForKeyFunction,
    Future<String> Function(String relativePath) readFunction,
  ) async {
    if (fileState.remoteFileName == null || fileState.currentPath == null) {
      return fileState;
    }

    try {
      FileState newState = fileState.copyWith(
        downloadInProgress: true,
        downloadDone: false,
      );

      // Let user choose where to save the file.

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save file as:',
        fileName: fileState.cleanFileName ??
            fileState.remoteFileName?.replaceAll('.enc.ttl', ''),
      );

      if (outputFile == null) {
        return fileState.copyWith(downloadInProgress: false);
      }

      final baseDir = basePath;
      final relativePath = fileState.currentPath == baseDir
          ? '$baseDir/${fileState.remoteFileName}'
          : '${fileState.currentPath}/${fileState.remoteFileName}';

      await promptForKeyFunction();

      final fileContent = await readFunction(relativePath);

      if (fileContent == SolidFunctionCallStatus.fail.toString() ||
          fileContent == SolidFunctionCallStatus.notLoggedIn.toString()) {
        throw Exception(
          'Download failed - please check your connection and permissions',
        );
      }

      // Save the decrypted content to file

      final outputFileHandle = File(outputFile);
      await outputFileHandle.writeAsString(fileContent);

      return newState.copyWith(downloadDone: true, downloadInProgress: false);
    } catch (e) {
      debugPrint('Download error: $e');
      return fileState.copyWith(downloadInProgress: false);
    }
  }

  /// Handles file deletion from the POD.

  static Future<FileState> handleDelete(
    FileState fileState,
    String basePath,
  ) async {
    if (fileState.remoteFileName == null || fileState.currentPath == null) {
      return fileState;
    }

    try {
      FileState newState = fileState.copyWith(
        deleteInProgress: true,
        deleteDone: false,
      );

      final baseDir = basePath;
      final filePath = fileState.currentPath == baseDir
          ? '$baseDir/${fileState.remoteFileName}'
          : '${fileState.currentPath}/${fileState.remoteFileName}';

      // Delete the file (this also handles the ACL file automatically).

      try {
        await deleteFile(fileUrl: await getFileUrl(filePath));
        return newState.copyWith(deleteDone: true, deleteInProgress: false);
      } catch (e) {
        debugPrint('Error deleting file: $e');

        // Only rethrow if it's not a 404 error.

        if (!e.toString().contains('404') &&
            !e.toString().contains('NotFoundHttpError')) {
          rethrow;
        }
      }

      return newState.copyWith(deleteDone: false, deleteInProgress: false);
    } catch (e) {
      debugPrint('Delete error: $e');
      return fileState.copyWith(deleteDone: false, deleteInProgress: false);
    }
  }

  /// Helper function to get a user-friendly name from the path.

  static String getFriendlyFolderName(String pathValue, String basePath) {
    final String root = basePath;
    if (pathValue.isEmpty || pathValue == root) {
      return 'Home Folder';
    }

    // Use path.basename to safely get the last component.

    final dirName = path.basename(pathValue);

    switch (dirName) {
      case 'diary':
        return 'Appointments Data';
      case 'blood_pressure':
        return 'Blood Pressure Data';
      case 'medication':
        return 'Medication Data';
      case 'vaccination':
        return 'Vaccination Data';
      case 'profile':
        return 'Profile Data';
      case 'health_plan':
        return 'Health Plan Data';
      case 'pathology':
        return 'Pathology Data';
      case 'tv_shows':
        return 'TV Shows';

      default:
        // Basic formatting for unknown folders:
        // capitalise first letter, replace underscores.

        if (dirName.isEmpty) return 'Folder';
        String formattedName = dirName.replaceAll('_', ' ').trim();
        formattedName = formattedName
            .split(RegExp(r'\s+'))
            .map(
              (w) => w.isEmpty
                  ? w
                  : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
            )
            .join(' ');
        return formattedName;
    }
  }

  /// Shows an alert dialog with the given message.

  static void showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Shows success message.

  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }
}
