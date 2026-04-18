/// A button for sharing a resource.
///
// Time-stamp: <Saturday 2026-01-17 19:06:10 +1100 Graham Williams>
///
/// Copyright (C) 2024-2025, Software Innovation Institute, ANU.
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
/// Authors: Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart'
    show SharingPageLayout, SolidScaffoldHelpers;
import 'package:solidui/src/constants/ui_colors.dart';
import 'package:solidui/src/utils/solid_alert.dart';
import 'package:solidui/src/widgets/grant_permission_form.dart';

/// A [StatefulWidget] for sharing a resource, by either creating
/// an access permission for a new recipient or updating the access
/// permission of an existing recipient.
///
/// Parameters:
/// - [resourceNames] - Optional list of resource names. When null, the
/// [fileNameController] text is used. When one entry, that resource is
/// pre-set. When multiple entries, granting applies to all.
/// - [fileNameController] - The [TextEditingController] for the filename
/// field.
/// - [isExternalRes] - Boolean flag describing whether the resource
/// is externally owned.
/// - [ownerWebId] - WebId of the owner of the resource. Required if the resource is externally owned.
/// - [granterWebId] - WebId of the granter of the resource. Required if the resource is externally owned.
/// - [accessModeList] - List of access mode options to show.
/// - [recipientTypeList] - List of recipient type options to show.
/// - [isFile] - Boolean flag describing whether the resource is a file. If false, the resource is assumed to be a directory.
/// - [updatePermissionsFunction] is the function to be called to refresh the permission table.
/// - [onPermissionGranted] - Callback function called when permissions are granted successfully.

class ShareResourceButton extends StatefulWidget {
  final TextEditingController fileNameController;

  /// String to assign the webId of the resource owner.

  final String ownerWebId;

  /// String to assign the external webId of the resource granter.

  final String granterWebId;

  /// Optional list of resource names when granting permission. When null, the
  /// [fileNameController] text is used as the resource. When one entry, that
  /// resource is pre-set. When multiple entries, the form grants permission to
  /// all names in the list.

  final List<String>? resourceNames;

  final bool isExternalRes;

  /// A flag to determine whether the given resource is a file or not.

  final bool isFile;

  /// The list of access modes to be displayed. By default all four types of
  /// access mode are listed.

  final List<String> accessModeList;

  /// The list of types of recipients receiving permission to access the resource. By default all four
  /// types of recipient are listed.

  final List<String> recipientTypeList;

  /// Map of data files on a user's POD used to extract the
  /// user's recipient list by the WebIdTextInputScreen.
  /// If not provided, the WebIdTextInputScreen will read the
  /// user's files in their app data folder on their Pod to
  /// fetch the ACLs needed to derive the user's recipient list.

  final Map<String, dynamic> dataFilesMap;

  /// Function run to update permissions table

  final Function updatePermissionsFunction;

  /// Callback function called when permissions are granted successfully.

  final VoidCallback? onPermissionGranted;

  /// Whether to display full resource paths or just the last path segment.
  /// Only relevant when [resourceNames] is provided.

  final bool showFullPath;

  /// Called when the user toggles the Show Full Path slider.

  final ValueChanged<bool>? onShowFullPathChanged;

  /// Whether to display file titles instead of filenames or paths.
  /// Only used when [titleData] is provided. Defaults to false.

  final bool showTitle;

  /// Called when the user toggles the Show Title option.

  final ValueChanged<bool>? onShowTitleChanged;

  /// Optional map from resource key to human-readable file title.
  /// When provided, replaces the Show Full Path switch with a three-option
  /// radio group: 'File Url', 'Filename', and 'File Title'.

  final Map<String, String>? titleData;

  /// Optional background color for the Share Resource button.
  /// When provided, overrides the theme's elevated button background.

  final Color? shareButtonColor;

  const ShareResourceButton({
    super.key,
    required this.fileNameController,
    required this.updatePermissionsFunction,
    this.resourceNames,
    required this.ownerWebId,
    required this.granterWebId,
    this.accessModeList = const ['read', 'write', 'append', 'control'],
    this.recipientTypeList = const ['public', 'indi', 'auth', 'group'],
    required this.isExternalRes,
    required this.isFile,
    this.showFullPath = true,
    this.onShowFullPathChanged,
    this.dataFilesMap = const {},
    this.onPermissionGranted,
    this.shareButtonColor,
    this.showTitle = false,
    this.onShowTitleChanged,
    this.titleData,
  }) : assert(
          !showTitle || titleData != null,
          'titleData must not be null when showTitle is true',
        );

  @override
  State<ShareResourceButton> createState() => _ShareResourceButtonState();
}

class _ShareResourceButtonState extends State<ShareResourceButton> {
  /// Filename text controller

  late final TextEditingController _fileNameController;

  /// Selected resource - assigned on Share Resource button press

  String _resourceName = '';

  /// A flag to identify if the resource is a file or not

  bool isFile = true;

  /// Flag to track if permissions were granted successfully.

  bool permissionsGrantedSuccessfully = false;

  @override
  void initState() {
    super.initState();

    _fileNameController = widget.fileNameController;
  }

  @override
  void dispose() {
    // _fileNameController is owned by the parent widget — do not dispose it here.
    super.dispose();
  }

  /// Mark permissions as granted successfully for callback tracking
  Future<void> _updatePermissionGrantedStatus() async {
    setState(() => permissionsGrantedSuccessfully = true);
  }

  /// Private function to call alert dialog in share resource button
  /// context. This provides an alert dialog over the top of the
  /// grant permission form dialog.
  Future<void> _alert(String msg) async => alert(context, msg);

  // Resource is a file if resource selected in GrantPermissionUi()
  bool _getIsFile() => widget.resourceNames != null ? widget.isFile : isFile;

  /// Returns the currently selected display mode label derived from
  /// [widget.showFullPath] and [widget.showTitle].
  String get _displayMode {
    if (widget.showTitle) return 'File Title';
    if (widget.showFullPath) return 'File Url';
    return 'Filename';
  }

  void _onDisplayModeSelected(String mode) {
    switch (mode) {
      case 'File Url':
        widget.onShowFullPathChanged?.call(true);
        widget.onShowTitleChanged?.call(false);
      case 'Filename':
        widget.onShowFullPathChanged?.call(false);
        widget.onShowTitleChanged?.call(false);
      case 'File Title':
        widget.onShowTitleChanged?.call(true);
    }
  }

  Widget _buildDisplayModeRadioGroup() {
    const modes = ['File Url', 'Filename', 'File Title'];
    final activeColor = Theme.of(context).switchTheme.thumbColor?.resolve(
          {WidgetState.selected},
        ) ??
        ActionColors.success;
    return Theme(
      data: Theme.of(context).copyWith(
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected) ? activeColor : null,
          ),
        ),
      ),
      child: RadioGroup<String>(
        groupValue: _displayMode,
        onChanged: (v) {
          if (v != null) _onDisplayModeSelected(v);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in modes) ...[
              Radio<String>(
                value: mode,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              Text(mode, style: const TextStyle(fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayModeControl = widget.resourceNames != null
        ? widget.titleData != null
            ? _buildDisplayModeRadioGroup()
            : Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [
                  const Text(
                    'Show\nFull Path',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                  Switch(
                    value: widget.showFullPath,
                    activeThumbColor:
                        Theme.of(context).switchTheme.thumbColor?.resolve(
                              {WidgetState.selected},
                            ) ??
                            ActionColors.success,
                    onChanged: widget.onShowFullPathChanged,
                  ),
                ],
              )
        : null;

    final shareButton = ElevatedButton.icon(
      icon: const Icon(Icons.share),
      // Set share button background color to
      // parameter shareButtonColor or
      // theme elevated button color
      // or elevated button default (grey)
      style: widget.shareButtonColor != null
          ? Theme.of(context).elevatedButtonTheme.style?.copyWith(
                backgroundColor: WidgetStateProperty.all<Color>(
                  widget.shareButtonColor!,
                ),
              )
          : Theme.of(context).elevatedButtonTheme.style,
      onPressed: () async {
        // Resolve resource name: use first of resourceNames if set,
        // otherwise fall back to user-entered filename.
        _resourceName =
            widget.resourceNames?.firstOrNull ?? _fileNameController.text;

        if (_resourceName != '') {
          // Display GrantPermissionForm dialog to enter
          // recipient and access modes
          await showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return GrantPermissionForm(
                resourceNames: widget.resourceNames ?? [_resourceName],
                accessModeList: widget.accessModeList,
                recipientTypeList: widget.recipientTypeList,
                updatePermissionsFunction: widget.updatePermissionsFunction,
                ownerWebId: widget.ownerWebId,
                granterWebId: widget.granterWebId,
                isExternalRes: widget.isExternalRes,
                isFile: _getIsFile(),
                dataFilesMap: widget.dataFilesMap,
                updatePermissionGrantedFunction: _updatePermissionGrantedStatus,
                onPermissionGranted: widget.onPermissionGranted,
              );
            },
          );
        } else {
          await _alert('Please select one or more recipients');
        }
      },
      label: Text(
        (widget.resourceNames != null && widget.resourceNames!.length > 1)
            ? 'Share Resources'
            : 'Share Resource',
      ),
    );

    return Padding(
      padding: SharingPageLayout.inputPadding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isVeryNarrow =
              SolidScaffoldHelpers.isVeryNarrowScreen(constraints);
          return isVeryNarrow && displayModeControl != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 5,
                      children: [
                        // Share resources button
                        shareButton,
                        // Switch display options
                        // filename, file url, title
                        displayModeControl,
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 10,
                  children: [
                    // Switch display options
                    // filename, file url, title
                    if (displayModeControl != null) displayModeControl,
                    // Share resources button
                    shareButton,
                  ],
                );
        },
      ),
    );
  }
}
