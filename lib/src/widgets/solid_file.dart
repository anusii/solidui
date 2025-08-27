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

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/models/file_state.dart';
import 'package:solidui/src/utils/is_text_file.dart';
import 'package:solidui/src/widgets/solid_file_browser.dart';
import 'package:solidui/src/widgets/solid_file_uploader.dart';

/// The main file service widget that provides file upload, download, and
/// preview functionality.

class SolidFile extends StatefulWidget {
  /// The base path for file operations.

  final String basePath;

  /// Callback when a file is selected in the browser.

  final Function(String, String)? onFileSelected;

  /// Callback when an operation is completed.

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

  /// Helper function to get a user-friendly name from the path.

  String _getFriendlyFolderName(String pathValue) {
    final String root = widget.basePath;
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

      default:
        // Basic formatting for unknown folders: capitalise first letter, replace underscores.

        if (dirName.isEmpty) return 'Folder';
        String formattedName = dirName.replaceAll('_', ' ');
        formattedName =
            formattedName[0].toUpperCase() + formattedName.substring(1);
        return '$formattedName Data';
    }
  }

  /// Updates the file state and triggers a rebuild.

  void _updateFileState(FileState newState) {
    setState(() {
      _fileState = newState;
    });
  }

  /// Handles file upload by reading its contents and encrypting it for upload.

  Future<void> _handleUpload() async {
    if (_fileState.uploadFile == null) return;

    try {
      _updateFileState(
          _fileState.copyWith(uploadInProgress: true, uploadDone: false));

      final file = File(_fileState.uploadFile!);
      String fileContent;

      // For text files, we directly read the content.
      // For binary files, we encode them into base64 format.

      if (isTextFile(_fileState.uploadFile!)) {
        fileContent = await file.readAsString();
      } else {
        final bytes = await file.readAsBytes();
        fileContent = base64Encode(bytes);
      }

      // Sanitise file name and append encryption extension.

      String sanitizedFileName = path
          .basename(_fileState.uploadFile!)
          .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')
          .replaceAll(RegExp(r'\.enc\.ttl$'), '');

      final remoteFileName = '$sanitizedFileName.enc.ttl';
      final cleanFileName = sanitizedFileName;

      // Extract the subdirectory path.

      String? subPath =
          _fileState.currentPath?.replaceFirst(widget.basePath, '').trim();
      String uploadPath = subPath == null || subPath.isEmpty
          ? remoteFileName
          : '${subPath.startsWith("/") ? subPath.substring(1) : subPath}/$remoteFileName';

      if (!context.mounted) return;

      // Upload file with encryption.

      final result = await writePod(
        uploadPath,
        fileContent,
        context,
        Text('Upload'),
        encrypted: true,
      );

      _updateFileState(_fileState.copyWith(
        uploadDone: result == SolidFunctionCallStatus.success,
        uploadInProgress: false,
        remoteFileName: remoteFileName,
        cleanFileName: cleanFileName,
      ));

      if (result == SolidFunctionCallStatus.success) {
        // Show success message.

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('File uploaded successfully'),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
          );
          // Refresh the browser.
          _browserKey.currentState?.refreshFiles();
          widget.onOperationComplete?.call();
        }
      } else if (context.mounted) {
        _showAlert(
            'Upload failed - please check your connection and permissions.');
      }
    } catch (e) {
      if (context.mounted) {
        _showAlert('Upload error: ${e.toString()}');
        debugPrint('Upload error: $e');
      }
      _updateFileState(_fileState.copyWith(uploadInProgress: false));
    }
  }

  /// Handles the download and decryption of files from the POD.

  Future<void> _handleDownload() async {
    if (_fileState.remoteFileName == null || _fileState.currentPath == null) {
      return;
    }

    try {
      _updateFileState(
          _fileState.copyWith(downloadInProgress: true, downloadDone: false));

      // Let user choose where to save the file.

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save file as:',
        fileName: _fileState.cleanFileName ??
            _fileState.remoteFileName?.replaceAll('.enc.ttl', ''),
      );

      if (outputFile == null) {
        _updateFileState(_fileState.copyWith(downloadInProgress: false));
        return;
      }

      final baseDir = widget.basePath;
      final relativePath = _fileState.currentPath == baseDir
          ? '$baseDir/${_fileState.remoteFileName}'
          : '${_fileState.currentPath}/${_fileState.remoteFileName}';

      if (!context.mounted) return;

      await getKeyFromUserIfRequired(
        context,
        Text('Please enter your security key to download the file'),
      );

      if (!context.mounted) return;

      final fileContent = await readPod(
        relativePath,
        context,
        Text('Downloading'),
      );

      if (!context.mounted) return;

      if (fileContent == SolidFunctionCallStatus.fail.toString() ||
          fileContent == SolidFunctionCallStatus.notLoggedIn.toString()) {
        throw Exception(
          'Download failed - please check your connection and permissions',
        );
      }

      // Save the decrypted content to file
      final outputFileHandle = File(outputFile);
      await outputFileHandle.writeAsString(fileContent);

      _updateFileState(
          _fileState.copyWith(downloadDone: true, downloadInProgress: false));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('File downloaded successfully'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
        widget.onOperationComplete?.call();
      }
    } catch (e) {
      if (context.mounted) {
        _showAlert('Download error: ${e.toString()}');
        debugPrint('Download error: $e');
      }
      _updateFileState(_fileState.copyWith(downloadInProgress: false));
    }
  }

  /// Handles file deletion from the POD.

  Future<void> _handleDelete() async {
    if (_fileState.remoteFileName == null || _fileState.currentPath == null) {
      return;
    }

    try {
      _updateFileState(
          _fileState.copyWith(deleteInProgress: true, deleteDone: false));

      final baseDir = widget.basePath;
      final filePath = _fileState.currentPath == baseDir
          ? '$baseDir/${_fileState.remoteFileName}'
          : '${_fileState.currentPath}/${_fileState.remoteFileName}';

      if (!context.mounted) return;

      // First try to delete the main file.

      bool mainFileDeleted = false;
      try {
        await deleteFile(filePath);
        mainFileDeleted = true;
      } catch (e) {
        debugPrint('Error deleting main file: $e');
        // Only rethrow if it's not a 404 error.

        if (!e.toString().contains('404') &&
            !e.toString().contains('NotFoundHttpError')) {
          rethrow;
        }
      }

      if (!context.mounted) return;

      // If main file deletion succeeded, try to delete the ACL file.

      if (mainFileDeleted) {
        try {
          await deleteFile('$filePath.acl');
        } catch (e) {
          // ACL files are optional and may not exist.

          if (e.toString().contains('404') ||
              e.toString().contains('NotFoundHttpError')) {
            debugPrint('ACL file not found (safe to ignore)');
          } else {
            debugPrint('Error deleting ACL file: ${e.toString()}');
          }
        }

        if (!context.mounted) return;
        _updateFileState(_fileState.copyWith(deleteDone: true));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('File deleted successfully'),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
          );

          // Refresh the browser.
          _browserKey.currentState?.refreshFiles();
          widget.onOperationComplete?.call();
        }
      }
    } catch (e) {
      if (!context.mounted) return;

      _updateFileState(_fileState.copyWith(deleteDone: false));

      // Provide user-friendly error messages.

      final message = e.toString().contains('404') ||
              e.toString().contains('NotFoundHttpError')
          ? 'File not found or already deleted'
          : 'Delete failed: ${e.toString()}';

      _showAlert(message);
      debugPrint('Delete error: $e');
    } finally {
      if (context.mounted) {
        _updateFileState(_fileState.copyWith(deleteInProgress: false));
      }
    }
  }

  /// Shows an alert dialog with the given message.

  void _showAlert(String message) {
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

  @override
  Widget build(BuildContext context) {
    // Get current path and friendly name.

    final currentPath = _fileState.currentPath ?? widget.basePath;
    final String friendlyFolderName = _getFriendlyFolderName(currentPath);

    // Determine if we're on a wide screen.

    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button to root folder.

        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: TextButton.icon(
            onPressed: () {
              final rootPath = widget.basePath;
              if (_fileState.currentPath != rootPath) {
                _updateFileState(_fileState.copyWith(currentPath: rootPath));
                _browserKey.currentState?.navigateToPath(rootPath);
              }
            },
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: Text(
              'Back to Home Folder',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),

        // Main content area.

        Expanded(
          child: isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // File browser on the left.

                    Expanded(
                      flex: 2,
                      child: Card(
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.only(right: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SolidFileBrowser(
                            key: _browserKey,
                            browserKey: _browserKey,
                            friendlyFolderName: friendlyFolderName,
                            basePath: widget.basePath,
                            onFileSelected: (name, filePath) async {
                              setState(() {});

                              try {
                                // Read file content for preview.

                                final content = await readPod(
                                  filePath,
                                  context,
                                  Container(),
                                );
                                String preview;

                                if (isTextFile(name)) {
                                  // For text files, show the first 500 characters.

                                  preview = content.length > 500
                                      ? '${content.substring(0, 500)}...'
                                      : content;
                                } else {
                                  // For binary files, show basic info.

                                  preview =
                                      'Binary file\nSize: ${(content.length / 1024).toStringAsFixed(2)} KB\nType: ${path.extension(name)}';
                                }

                                _updateFileState(_fileState.copyWith(
                                  downloadFile: filePath,
                                  filePreview: preview,
                                  remoteFileName: path.basename(name),
                                ));

                                widget.onFileSelected?.call(name, filePath);
                              } catch (e) {
                                debugPrint('Preview error: $e');
                                _updateFileState(_fileState.copyWith(
                                  downloadFile: filePath,
                                  filePreview: 'Error loading preview',
                                  remoteFileName: path.basename(name),
                                ));
                              }
                            },
                            onFileDownload: (name, filePath) async {
                              _updateFileState(_fileState.copyWith(
                                downloadFile: filePath,
                                remoteFileName: path.basename(name),
                              ));
                              await _handleDownload();
                            },
                            onFileDelete: (name, filePath) async {
                              // Show confirmation dialog before deleting.

                              final bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).dialogTheme.backgroundColor,
                                    title: Text(
                                      'Confirm Delete',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete "$name"?',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(
                                          context,
                                        ).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(
                                          context,
                                        ).pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (!context.mounted) return;

                              if (confirm == true) {
                                _updateFileState(_fileState.copyWith(
                                  remoteFileName: path.basename(name),
                                ));
                                await _handleDelete();
                              }
                            },
                            onImportCsv: (name, filePath) {
                              if (mounted) {
                                _updateFileState(
                                    _fileState.copyWith(currentPath: filePath));
                                _browserKey.currentState?.refreshFiles();
                              }
                            },
                            onDirectoryChanged: (path) {
                              if (mounted) {
                                _updateFileState(
                                    _fileState.copyWith(currentPath: path));
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                    // Upload section on the right.

                    Expanded(
                      flex: 1,
                      child: Card(
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.only(left: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SolidFileUploader(
                            fileState: _fileState,
                            basePath: widget.basePath,
                            onUpload: _handleUpload,
                            onFileSelected: (filePath) {
                              _updateFileState(
                                  _fileState.copyWith(uploadFile: filePath));
                            },
                            onPreviewRequested: (preview) {
                              _updateFileState(
                                  _fileState.copyWith(filePreview: preview));
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // File browser for narrow screen.

                    SizedBox(
                      height: 300,
                      child: Card(
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.all(16.0),
                        child: SolidFileBrowser(
                          key: _browserKey,
                          browserKey: _browserKey,
                          friendlyFolderName: friendlyFolderName,
                          basePath: widget.basePath,
                          onFileSelected: (name, filePath) async {
                            setState(() {});

                            try {
                              final content = await readPod(
                                filePath,
                                context,
                                Container(),
                              );
                              String preview;

                              if (isTextFile(name)) {
                                preview = content.length > 500
                                    ? '${content.substring(0, 500)}...'
                                    : content;
                              } else {
                                preview =
                                    'Binary file\nSize: ${(content.length / 1024).toStringAsFixed(2)} KB\nType: ${path.extension(name)}';
                              }

                              _updateFileState(_fileState.copyWith(
                                downloadFile: filePath,
                                filePreview: preview,
                                remoteFileName: path.basename(name),
                              ));

                              widget.onFileSelected?.call(name, filePath);
                            } catch (e) {
                              debugPrint('Preview error: $e');
                              _updateFileState(_fileState.copyWith(
                                downloadFile: filePath,
                                filePreview: 'Error loading preview',
                                remoteFileName: path.basename(name),
                              ));
                            }
                          },
                          onFileDownload: (name, filePath) async {
                            _updateFileState(_fileState.copyWith(
                              downloadFile: filePath,
                              remoteFileName: path.basename(name),
                            ));
                            await _handleDownload();
                          },
                          onFileDelete: (name, filePath) async {
                            final bool? confirm = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).dialogTheme.backgroundColor,
                                  title: Text(
                                    'Confirm Delete',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  content: Text(
                                    'Are you sure you want to delete "$name"?',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(
                                        context,
                                      ).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(
                                        context,
                                      ).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (!context.mounted) return;

                            if (confirm == true) {
                              _updateFileState(_fileState.copyWith(
                                remoteFileName: path.basename(name),
                              ));
                              await _handleDelete();
                            }
                          },
                          onImportCsv: (name, filePath) {
                            if (mounted) {
                              _updateFileState(
                                  _fileState.copyWith(currentPath: filePath));
                              _browserKey.currentState?.refreshFiles();
                            }
                          },
                          onDirectoryChanged: (path) {
                            if (mounted) {
                              _updateFileState(
                                  _fileState.copyWith(currentPath: path));
                            }
                          },
                        ),
                      ),
                    ),

                    // Upload section for narrow screen.

                    Expanded(
                      child: Card(
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.all(16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SolidFileUploader(
                            fileState: _fileState,
                            basePath: widget.basePath,
                            onUpload: _handleUpload,
                            onFileSelected: (filePath) {
                              _updateFileState(
                                  _fileState.copyWith(uploadFile: filePath));
                            },
                            onPreviewRequested: (preview) {
                              _updateFileState(
                                  _fileState.copyWith(filePreview: preview));
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
