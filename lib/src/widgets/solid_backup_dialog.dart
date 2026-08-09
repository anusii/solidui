/// A dialog for backing up and restoring the current app's POD data folder.
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

import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;

import 'package:file_picker/file_picker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:gap/gap.dart';
import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:solidpod/solidpod.dart'
    show SecurityKeyVerificationException, isUserLoggedIn;
import 'package:universal_io/io.dart' show File, Platform, exit;

import 'package:solidui/src/services/solid_backup_service.dart';
import 'package:solidui/src/widgets/secret_text_field.dart';

/// A dialog offering two actions for the current application's data folder:
///
///   * **Export** — read and decrypt every file in the data folder, then save
///     it as a single compressed, encrypted backup file on this device.
///   * **Import** — restore a previously exported backup (from this POD or
///     another), re-encrypting the data with this POD's current security key.
///     The user is warned beforehand, and afterwards the app is closed, so
///     that reopening it reloads the restored data in full.
///
/// The dialog mirrors the layout and wording of the TodoPod Backup feature but
/// works at the level of the whole app data folder rather than a single model.

class SolidBackupDialog extends StatefulWidget {
  /// Constructor.

  const SolidBackupDialog({super.key});

  /// Show the backup dialog.

  static Future<void> show(BuildContext context) => showDialog<void>(
        context: context,
        builder: (_) => const SolidBackupDialog(),
      );

  @override
  State<SolidBackupDialog> createState() => _SolidBackupDialogState();
}

class _SolidBackupDialogState extends State<SolidBackupDialog> {
  bool _busy = false;

  String? _exportMessage;
  bool _exportError = false;

  String? _importMessage;
  bool _importError = false;

  void _setExportMessage(String message, {bool error = false}) {
    if (!mounted) return;
    setState(() {
      _exportMessage = message;
      _exportError = error;
    });
  }

  void _setImportMessage(String message, {bool error = false}) {
    if (!mounted) return;
    setState(() {
      _importMessage = message;
      _importError = error;
    });
  }

  // Export.

  Future<void> _handleExport() async {
    if (!await isUserLoggedIn()) {
      _setExportMessage(
        'You must be logged in to create a backup.',
        error: true,
      );
      return;
    }

    // Ask for the current security key. This is the key the backup will be
    // encrypted with, and whose fingerprint is stored in the file so it can be
    // matched again on import.

    final keys = await _promptForKeys(
      title: 'Export Backup',
      message: 'Please verify your current security key. The backup will be '
          'encrypted with this key, and you will need it again when '
          'restoring.',
      fields: const [
        (key: 'securityKey', label: 'Security Key'),
      ],
    );
    if (keys == null) return;

    setState(() {
      _busy = true;
      _exportMessage = null;
    });

    try {
      final result = await SolidBackupService.instance.export(
        securityKey: keys['securityKey']!,
      );

      final savedPath = await _saveFile(
        bytes: result.bytes,
        fileName: result.suggestedFileName,
      );

      if (savedPath == null) {
        // The user cancelled the save dialog.

        _setExportMessage('Backup cancelled.');
        return;
      }

      _setExportMessage(
        'Backed up ${result.fileCount} '
        'file${result.fileCount == 1 ? '' : 's'} to "$savedPath".',
      );
    } on SecurityKeyVerificationException {
      _setExportMessage('Incorrect security key.', error: true);
    } on Object catch (e) {
      _setExportMessage('Backup failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // Save [bytes] to a user-chosen location. On web the picker triggers a
  // download; on other platforms it returns a path we write to explicitly
  // (the desktop picker does not persist bytes itself).

  Future<String?> _saveFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final path = await FilePicker.saveFile(
      dialogTitle: 'Save backup',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const [kBackupFileExtension],
      bytes: bytes,
    );
    if (path == null) return null;
    if (!kIsWeb) {
      await File(path).writeAsBytes(bytes);
    }
    return path;
  }

  // Import.

  Future<void> _handleImport() async {
    if (!await isUserLoggedIn()) {
      _setImportMessage(
        'You must be logged in to restore a backup.',
        error: true,
      );
      return;
    }

    // Warn about the restart before the user picks a file or types any keys.
    // The app keeps the data it loaded at start-up in memory, so it must be
    // restarted once the restore has finished.

    if (!mounted) return;
    if (!await _confirmRestore()) {
      _setImportMessage('Import cancelled.');
      return;
    }

    setState(() {
      _busy = true;
      _importMessage = null;
    });

    try {
      // Pick and read the backup file.

      final picked = await FilePicker.pickFiles(
        dialogTitle: 'Select a backup file',
        type: FileType.custom,
        allowedExtensions: const [kBackupFileExtension],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) {
        _setImportMessage('Import cancelled.');
        return;
      }

      final bytes = picked.files.first.bytes;
      if (bytes == null) {
        _setImportMessage('Could not read the selected file.', error: true);
        return;
      }

      // Read the header and confirm the backup belongs to this application
      // before asking the user for any keys.

      final header = SolidBackupService.instance.inspect(bytes);
      if (!await SolidBackupService.instance.isSameApplication(header)) {
        _setImportMessage(
          'This backup was created by a different application '
          '("${header.appId}") and cannot be restored here.',
          error: true,
        );
        return;
      }

      // Same application: ask for the original key (to decrypt the backup) and
      // the current key (to re-encrypt for this POD). They may differ when the
      // backup came from another POD or the key has since been changed.

      if (!mounted) return;
      final keys = await _promptForKeys(
        title: 'Import Backup',
        message: 'This backup holds ${header.fileCount} '
            'file${header.fileCount == 1 ? '' : 's'}. Enter the original '
            'security key it was created with, and the current security key '
            'for this POD. Restoring overwrites the contents of this app\'s '
            'data folder, after which the app closes and you open it again.',
        fields: const [
          (key: 'originalKey', label: 'Original Security Key'),
          (key: 'currentKey', label: 'Current Security Key'),
        ],
      );
      if (keys == null) {
        _setImportMessage('Import cancelled.');
        return;
      }

      final result = await SolidBackupService.instance.import(
        header: header,
        originalKey: keys['originalKey']!,
        currentKey: keys['currentKey']!,
      );

      final skippedNote =
          result.skipped.isEmpty ? '' : ' (${result.skipped.length} skipped)';
      final summary = 'Restored ${result.restoredCount} '
          'file${result.restoredCount == 1 ? '' : 's'}$skippedNote.';
      _setImportMessage(summary, error: result.skipped.isNotEmpty);

      // The POD now holds the restored data, but this app is still running
      // with whatever it loaded beforehand. Insist on a restart so that the
      // data is reloaded in full and nothing stale is written back.

      if (!mounted) return;
      await _showRestartRequiredDialog(summary);
      if (mounted) Navigator.of(context).pop();
    } on BackupAppMismatchException catch (e) {
      _setImportMessage(
        'This backup was created by a different application '
        '("${e.backupAppId}") and cannot be restored here.',
        error: true,
      );
    } on SecurityKeyVerificationException catch (e) {
      _setImportMessage(e.message, error: true);
    } on InvalidBackupFileException catch (e) {
      _setImportMessage(e.message, error: true);
    } on Object catch (e) {
      _setImportMessage('Restore failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // Restart prompts.

  // Ask the user to acknowledge, before anything is written, that the app has
  // to be started again once the restore has finished. Returns true to go
  // ahead.

  Future<bool> _confirmRestore() async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_outlined),
            SizedBox(width: 12),
            Expanded(child: Text('Restart Required')),
          ],
        ),
        content: const SizedBox(
          width: 420,
          child: Text(
            'Restoring a backup replaces the contents of this app\'s data '
            'folder on your POD.\n\n'
            '${kIsWeb ? 'You will need to reload the page yourself' : 'The '
                'app will close and you will need to open it again yourself'} '
            'once the restore is done.\n\n'
            'Do you want to continue?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return proceed ?? false;
  }

  // Tell the user that the restore is done and the app has to be started
  // again, and close it for them. The dialog offers the single action, and
  // cannot be dismissed by tapping outside it or by the system back gesture,
  // so the app is never left running on top of freshly restored data.
  //
  // An app cannot reliably start itself again, so the user is told plainly to
  // open it again by hand once it has closed.

  Future<void> _showRestartRequiredDialog(String summary) => showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Row(
              children: [
                Icon(kIsWeb ? Icons.refresh : Icons.exit_to_app),
                SizedBox(width: 12),
                Expanded(
                  child: Text(kIsWeb ? 'Reload Required' : 'Close and Reopen'),
                ),
              ],
            ),
            content: SizedBox(
              width: 420,
              child: Text(
                '$summary\n\n'
                '${kIsWeb ? 'Please reload this page now to see the restored '
                    'data.' : 'The app will close now. Please open it again '
                    'manually to load the restored data.'}',
              ),
            ),
            actions: [
              FilledButton.icon(
                icon: const Icon(kIsWeb ? Icons.refresh : Icons.exit_to_app),
                label: const Text(kIsWeb ? 'OK' : 'Close App'),
                onPressed: () {
                  // Close the dialogs first. If the platform declines to close
                  // the app, the user is at least left with it usable and the
                  // banner still explaining that a restart is needed.

                  Navigator.of(dialogContext).pop();
                  _closeApp();
                },
              ),
            ],
          ),
        ),
      );

  // Close the app as firmly as the platform allows.
  //
  // On desktop the process is ended outright. That is deliberate: the data
  // underneath the app has just been replaced, and nothing the app still holds
  // in memory should get the chance to be written back. On Android the system
  // is asked to close the app, which finishes the activity in the ordinary
  // way; Apple does not let an iOS app close itself, so there this is
  // best-effort. A browser tab cannot close itself either, so on the web
  // nothing happens here and the dialog asks the user to reload the page.

  void _closeApp() {
    if (kIsWeb) return;

    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      exit(0);
    }

    SystemNavigator.pop();
  }

  // Key prompt.

  // Show a modal form of one or more masked security-key fields. Returns a map
  // of field key to entered value, or null if the user cancelled.

  Future<Map<String, String>?> _promptForKeys({
    required String title,
    required String message,
    required List<({String key, String label})> fields,
  }) {
    final formKey = GlobalKey<FormBuilderState>();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        // Accept the entered keys. Shared by the Continue button and by ENTER
        // pressed in the last field, so the keyboard and the mouse do the same
        // thing.

        void submit() {
          if (formKey.currentState?.saveAndValidate() ?? false) {
            final values = formKey.currentState!.value;
            Navigator.of(dialogContext).pop({
              for (final field in fields)
                field.key: values[field.key].toString(),
            });
          }
        }

        return AlertDialog(
          title: Text(title),

          // Cap the key fields at a readable width. Without this the dialog
          // grows with the window and the fields end up far wider than any
          // security key needs.

          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: FormBuilder(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message),
                    const Gap(16),
                    for (final (index, field) in fields.indexed) ...[
                      SecretTextField(
                        fieldKey: field.key,
                        fieldLabel: field.label,
                        validateFunc: (value) => value.isEmpty
                            ? 'Please enter ${field.label}.'
                            : null,

                        // The dialog opens ready to type into the first field.

                        autofocus: index == 0,

                        // ENTER on the last field is Continue; on an earlier
                        // field it moves to the next field.

                        onSubmitted: index == fields.length - 1
                            ? submit
                            : () => FocusScope.of(dialogContext).nextFocus(),
                      ),
                      const Gap(8),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: submit,
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  // Build.

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.backup_outlined),
          SizedBox(width: 12),
          Text('Backup'),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Save a complete, encrypted backup of this app\'s data folder, '
                'or restore one previously created on this or another POD.',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const Gap(20),

              // Export.

              _sectionTitle(context, 'Export'),
              const Gap(8),
              if (_exportMessage != null) ...[
                _MessageBanner(
                  message: _exportMessage!,
                  isError: _exportError,
                  colorScheme: cs,
                ),
                const Gap(12),
              ],
              MarkdownTooltip(
                message: '**Export Backup**\n\n'
                    'Save all files in this app\'s data folder to a single, '
                    'compressed and encrypted backup file on this device.',
                child: FilledButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Export Backup'),
                  onPressed: _busy ? null : _handleExport,
                ),
              ),
              const Gap(24),

              // Import.

              _sectionTitle(context, 'Import'),
              const Gap(8),
              if (_importMessage != null) ...[
                _MessageBanner(
                  message: _importMessage!,
                  isError: _importError,
                  colorScheme: cs,
                ),
                const Gap(12),
              ],
              MarkdownTooltip(
                message: '**Import Backup**\n\n'
                    'Restore a backup created by this application. The backup '
                    'is decrypted with its original security key and '
                    're-encrypted with this POD\'s current security key, '
                    'overwriting the data folder\'s contents.\n\n'
                    'The app closes once the restore has finished, and you '
                    'then open it again manually.',
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.upload),
                  label: const Text('Import Backup'),
                  onPressed: _busy ? null : _handleImport,
                ),
              ),

              if (_busy) ...[
                const Gap(20),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context).textTheme.titleMedium,
      );
}

// A compact status banner mirroring the TodoPod import screen's message style.

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.message,
    required this.isError,
    required this.colorScheme,
  });

  final String message;
  final bool isError;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final background =
        isError ? colorScheme.errorContainer : colorScheme.secondaryContainer;
    final foreground = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onSecondaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: 20,
            color: foreground,
          ),
          const Gap(8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
