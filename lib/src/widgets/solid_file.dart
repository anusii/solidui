/// File service widget.
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

import 'package:flutter/material.dart';

import 'package:path/path.dart' as path;
import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/constants/navigation.dart';
import 'package:solidui/src/models/file_state.dart';
import 'package:solidui/src/widgets/solid_file_browser.dart';
import 'package:solidui/src/widgets/solid_file_operations.dart';
import 'package:solidui/src/widgets/solid_file_ui_builder.dart';

/// The main file service widget that provides file upload, download, and
/// preview functionality.

class SolidFile extends StatefulWidget {
  final String basePath;
  final Function(String, String)? onFileSelected;
  final VoidCallback? onOperationComplete;
  const SolidFile({
    super.key,
    required this.basePath,
    this.onFileSelected,
    this.onOperationComplete,
  });
  @override
  State<SolidFile> createState() => _SolidFileState();
}

class _SolidFileState extends State<SolidFile> {
  final _browserKey = GlobalKey<SolidFileBrowserState>();
  late FileState _fileState;
  @override
  void initState() {
    super.initState();
    _fileState = FileState(currentPath: widget.basePath);
  }

  String _getFriendlyFolderName(String pathValue) {
    return SolidFileOperations.getFriendlyFolderName(
      pathValue,
      widget.basePath,
    );
  }

  /// Updates the file state and triggers a rebuild.

  void _updateFileState(FileState newState) {
    setState(() {
      _fileState = newState;
    });
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    SolidFileOperations.showSuccessMessage(context, message);
  }

  void _showAlert(String message) {
    if (!mounted) return;
    SolidFileOperations.showAlert(context, message);
  }

  /// Handles file upload by reading its contents and encrypting it for upload.

  Future<void> _handleUpload() async {
    if (_fileState.uploadFile == null) return;
    if (!context.mounted) return;
    final newState = await SolidFileOperations.handleUpload(
      _fileState,
      widget.basePath,
      (uploadPath, fileContent) async {
        if (!mounted) return SolidFunctionCallStatus.fail;
        return await writePod(
          uploadPath,
          fileContent,
          context,
          const Text('Upload'),
          encrypted: true,
        );
      },
    );
    if (!context.mounted) return;
    _updateFileState(newState);
    if (newState.uploadDone) {
      _showSuccessMessage('File uploaded successfully');
      _browserKey.currentState?.refreshFiles();
      widget.onOperationComplete?.call();
    } else if (!newState.uploadInProgress) {
      _showAlert(
        'Upload failed - please check your connection and permissions.',
      );
    }
  }

  /// Handles the download and decryption of files from the POD.

  Future<void> _handleDownload() async {
    if (_fileState.remoteFileName == null || _fileState.currentPath == null) {
      return;
    }
    if (!context.mounted) return;
    final newState = await SolidFileOperations.handleDownload(
      _fileState,
      widget.basePath,
      () async {
        if (!mounted) return;
        await getKeyFromUserIfRequired(
          context,
          const Text('Please enter your security key to download the file'),
        );
      },
      (relativePath) async {
        if (!mounted) return '';
        return await readPod(
          relativePath,
          context,
          const Text('Downloading'),
        );
      },
    );
    if (!context.mounted) return;
    _updateFileState(newState);
    if (newState.downloadDone) {
      _showSuccessMessage('File downloaded successfully');
      widget.onOperationComplete?.call();
    } else if (!newState.downloadInProgress && !newState.downloadDone) {
      _showAlert('Download failed');
    }
  }

  Future<void> _handleDelete() async {
    if (_fileState.remoteFileName == null || _fileState.currentPath == null) {
      return;
    }
    if (!context.mounted) return;
    final newState = await SolidFileOperations.handleDelete(
      _fileState,
      widget.basePath,
    );
    if (!context.mounted) return;
    _updateFileState(newState);
    if (newState.deleteDone) {
      _showSuccessMessage('File deleted successfully');
      _browserKey.currentState?.refreshFiles();
      widget.onOperationComplete?.call();
    } else if (!newState.deleteInProgress && !newState.deleteDone) {
      _showAlert('Delete failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = _fileState.currentPath ?? widget.basePath;
    final friendlyFolderName = _getFriendlyFolderName(currentPath);
    final isWideScreen = MediaQuery.of(context).size.width >
        NavigationConstants.narrowScreenThreshold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: isWideScreen
              ? SolidFileUIBuilder.buildWideScreenLayout(
                  context,
                  _browserKey,
                  friendlyFolderName,
                  widget.basePath,
                  _fileState,
                  _updateFileState,
                  _handleFileSelection,
                  _handleFileDownload,
                  _handleFileDelete,
                  _handleImportCsv,
                  _handleDirectoryChanged,
                  () async => await _handleUpload(),
                  (filePath) => _updateFileState(
                    _fileState.copyWith(uploadFile: filePath),
                  ),
                  (preview) => _updateFileState(
                    _fileState.copyWith(filePreview: preview),
                  ),
                )
              : SolidFileUIBuilder.buildNarrowScreenLayout(
                  context,
                  _browserKey,
                  friendlyFolderName,
                  widget.basePath,
                  _fileState,
                  _updateFileState,
                  _handleFileSelection,
                  _handleFileDownload,
                  _handleFileDelete,
                  _handleImportCsv,
                  _handleDirectoryChanged,
                  () async => await _handleUpload(),
                  (filePath) => _updateFileState(
                    _fileState.copyWith(uploadFile: filePath),
                  ),
                  (preview) => _updateFileState(
                    _fileState.copyWith(filePreview: preview),
                  ),
                ),
        ),
      ],
    );
  }

  /// Handles file selection with preview.

  Future<void> _handleFileSelection(String name, String filePath) async {
    setState(() {});
    await SolidFileUIBuilder.handleFileSelection(
      name,
      filePath,
      context,
      _fileState,
      _updateFileState,
      widget.onFileSelected,
    );
  }

  Future<void> _handleFileDownload(String name, String filePath) async {
    _updateFileState(
      _fileState.copyWith(
        downloadFile: filePath,
        remoteFileName: path.basename(name),
      ),
    );
    await _handleDownload();
  }

  /// Handles file deletion with confirmation.

  Future<void> _handleFileDelete(String name, String filePath) async {
    final confirm =
        await SolidFileUIBuilder.showDeleteConfirmation(context, name);
    if (!context.mounted) return;
    if (confirm) {
      _updateFileState(
        _fileState.copyWith(
          remoteFileName: path.basename(name),
        ),
      );
      await _handleDelete();
    }
  }

  void _handleImportCsv(String name, String filePath) {
    if (mounted) {
      _updateFileState(_fileState.copyWith(currentPath: filePath));
      _browserKey.currentState?.refreshFiles();
    }
  }

  void _handleDirectoryChanged(String pathValue) {
    if (mounted) {
      _updateFileState(_fileState.copyWith(currentPath: pathValue));
    }
  }
}
