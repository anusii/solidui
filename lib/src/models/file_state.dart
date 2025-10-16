/// File state model for managing file operation states.
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
/// Authors: Tony Chen (migrated from MovieStar)

library;

/// A model class to manage the state of file operations in the file service.

class FileState {
  /// The currently selected file for upload.

  String? uploadFile;

  /// The currently selected file for download.

  String? downloadFile;

  /// The name of the file on the remote server.

  String? remoteFileName;

  /// The clean name of the file (without encryption extension).

  String? cleanFileName;

  /// The URL of the remote file.

  String? remoteFileUrl;

  /// The preview content of the selected file.

  String? filePreview;

  /// The current directory path.

  String? currentPath;

  /// Operation status flags.

  bool uploadInProgress = false;
  bool downloadInProgress = false;
  bool deleteInProgress = false;
  bool importInProgress = false;
  bool exportInProgress = false;
  bool uploadDone = false;
  bool downloadDone = false;
  bool deleteDone = false;
  bool showPreview = false;

  /// Creates a new [FileState] with default values.

  FileState({
    this.uploadFile,
    this.downloadFile,
    this.remoteFileName = 'remoteFileName',
    this.cleanFileName = 'remoteFileName',
    this.remoteFileUrl,
    this.filePreview,
    this.currentPath,
    this.uploadInProgress = false,
    this.downloadInProgress = false,
    this.deleteInProgress = false,
    this.importInProgress = false,
    this.exportInProgress = false,
    this.uploadDone = false,
    this.downloadDone = false,
    this.deleteDone = false,
    this.showPreview = false,
  });

  /// Creates a copy of this [FileState] with the given fields replaced with
  /// new values.

  FileState copyWith({
    String? uploadFile,
    String? downloadFile,
    String? remoteFileName,
    String? cleanFileName,
    String? remoteFileUrl,
    String? filePreview,
    String? currentPath,
    bool? uploadInProgress,
    bool? downloadInProgress,
    bool? deleteInProgress,
    bool? importInProgress,
    bool? exportInProgress,
    bool? uploadDone,
    bool? downloadDone,
    bool? deleteDone,
    bool? showPreview,
  }) {
    return FileState(
      uploadFile: uploadFile ?? this.uploadFile,
      downloadFile: downloadFile ?? this.downloadFile,
      remoteFileName: remoteFileName ?? this.remoteFileName,
      cleanFileName: cleanFileName ?? this.cleanFileName,
      remoteFileUrl: remoteFileUrl ?? this.remoteFileUrl,
      filePreview: filePreview ?? this.filePreview,
      currentPath: currentPath ?? this.currentPath,
      uploadInProgress: uploadInProgress ?? this.uploadInProgress,
      downloadInProgress: downloadInProgress ?? this.downloadInProgress,
      deleteInProgress: deleteInProgress ?? this.deleteInProgress,
      importInProgress: importInProgress ?? this.importInProgress,
      exportInProgress: exportInProgress ?? this.exportInProgress,
      uploadDone: uploadDone ?? this.uploadDone,
      downloadDone: downloadDone ?? this.downloadDone,
      deleteDone: deleteDone ?? this.deleteDone,
      showPreview: showPreview ?? this.showPreview,
    );
  }
}
