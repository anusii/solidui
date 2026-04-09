/// Permission section widget for the grant permission UI.
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
/// Authors: Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/constants/ui_colors.dart';
import 'package:solidui/src/constants/ui_common.dart';
import 'package:solidui/src/widgets/permission_dropdown_resource_list.dart';
import 'package:solidui/src/widgets/permission_history.dart';
import 'package:solidui/src/widgets/permission_table.dart';

/// The permissions section of the grant permission UI, displayed below the
/// Divider. Shows the permission table heading, optional resource dropdown
/// (when [resourceNames] is provided), search/switch controls, and the
/// permission table or history.
///
/// Parameters:
/// - [resourceName] - Pre-set single resource name, if provided.
/// - [resourceNames] - Pre-set list of resource names, if provided.
/// - [permDataFile] - The resource name resolved from a user-entered filename.
/// - [selectedResourceName] - Currently selected resource in the dropdown.
/// - [isFile] - Whether the resource is a file (true) or directory (false).
/// - [isExternalRes] - Whether the resource is externally owned.
/// - [showFullPath] - Whether to show full paths or just the last path segment.
/// - [showCurrentPermOnly] - Whether to show current permissions (true) or
/// full permission history (false).
/// - [permDataMap] - The permission data map for the permission table.
/// - [ownerWebId] - WebId of the resource owner.
/// - [granterWebId] - WebId of the resource granter.
/// - [permHistoryList] - The (filtered) permission history log to display.
/// - [constraints] - Layout constraints passed from the parent LayoutBuilder.
/// - [updatePermissionsFunction] - Refreshes the permission table for a given
/// resource.
/// - [onSelectedResource] - Called when user selects a resource from the
/// dropdown.
/// - [onShowCurrentPermOnlyChanged] - Called when the current/history switch
/// is toggled.
/// - [onSearchLogs] - Called when the search field changes.

class PermissionSection extends StatelessWidget {
  const PermissionSection({
    super.key,
    required this.resourceName,
    required this.resourceNames,
    required this.permDataFile,
    required this.selectedResourceName,
    required this.isFile,
    required this.isExternalRes,
    required this.showFullPath,
    required this.showCurrentPermOnly,
    required this.permDataMap,
    required this.ownerWebId,
    required this.granterWebId,
    required this.permHistoryList,
    required this.constraints,
    required this.updatePermissionsFunction,
    required this.onSelectedResource,
    required this.onShowCurrentPermOnlyChanged,
    required this.onSearchLogs,
  });

  final String? resourceName;
  final List<String>? resourceNames;
  final String permDataFile;
  final String? selectedResourceName;
  final bool isFile;
  final bool isExternalRes;
  final bool showFullPath;
  final bool showCurrentPermOnly;
  final Map<dynamic, dynamic> permDataMap;
  final String ownerWebId;
  final String granterWebId;
  final List<LogRecord> permHistoryList;
  final BoxConstraints constraints;
  final Function updatePermissionsFunction;
  final Future<void> Function(String name) onSelectedResource;
  final void Function(bool value) onShowCurrentPermOnlyChanged;
  final void Function(String keyword) onSearchLogs;

  /// Whether to show the heading, search/switch controls, and table.
  bool get _hasResource =>
      resourceNames != null || resourceName != null || permDataFile.isNotEmpty;

  /// The resolved single resource name (from widget params, not user input).
  String? get _resolvedResourceName =>
      resourceName ?? resourceNames?.firstOrNull;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_hasResource) ...[
          smallGapV,
          makeSubHeading(
            showCurrentPermOnly
                ? 'People with current access'
                : 'Permission history',
            addPadding: false,
          ),
          smallGapV,
        ],
        // Dropdown to select which resource's permission table/history to show.
        if (resourceNames != null)
          PermissionDropdownResourceList(
            resourceNames: resourceNames!,
            selectedResourceName: selectedResourceName,
            isFile: isFile,
            showFullPath: showFullPath,
            onSelected: onSelectedResource,
          ),
        if (_hasResource)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 5.0,
            children: [
              Expanded(
                flex: 3,
                child: showCurrentPermOnly
                    ? const Text('')
                    : TextField(
                        onChanged: onSearchLogs,
                        decoration: const InputDecoration(
                          labelText:
                              'Search access level, permission type, recipient or granter name',
                          labelStyle: TextStyle(fontSize: 12),
                          hintText: 'Enter search text',
                          hintStyle: TextStyle(fontSize: 12),
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)),
                          ),
                        ),
                      ),
              ),
              SizedBox(
                width: 170.0,
                child: MarkdownTooltip(
                  message:
                      'Switch between current people with access and permission history log',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 5.0,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          showCurrentPermOnly
                              ? 'Current Permissions'
                              : 'All Permissions',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Switch(
                        value: showCurrentPermOnly,
                        activeThumbColor:
                            Theme.of(context).switchTheme.thumbColor?.resolve(
                                  {WidgetState.selected},
                                ) ??
                                ActionColors.success,
                        onChanged: onShowCurrentPermOnlyChanged,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        vSmallGapV,
        // Show the permission table/history if single resource name or
        // if a resource is selected from a resource list.
        if (resourceNames == null || selectedResourceName != null) ...[
          showCurrentPermOnly
              ? PermissionTable(
                  resourceName: permDataFile,
                  permDataMap: permDataMap,
                  ownerWebId: ownerWebId,
                  granterWebId: granterWebId,
                  updatePermissionsFunction: updatePermissionsFunction,
                  isFile: isFile,
                  isExternalRes: isExternalRes,
                  constraints: constraints,
                )
              : PermissionHistory(
                  key: ValueKey(permHistoryList),
                  resourceName: _resolvedResourceName ?? permDataFile,
                  permHistory: permHistoryList,
                  constraints: constraints,
                ),
        ],
      ],
    );
  }
}
