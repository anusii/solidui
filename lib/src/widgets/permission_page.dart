/// A page widget for displaying the permissions section.
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
/// Authors: Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/widgets/view_permission.dart';

/// The loaded permission data for a single resource.

typedef PermissionLoadResult = ({
  Map<dynamic, dynamic> permDataMap,
  String permDataFile,
  String ownerWebId,
  String granterWebId,
  List<LogRecord> permHistoryList,
  bool noPermissionHistory,
});

/// Callback type for loading permission data for a resource.

typedef LoadPermissionsCallback = Future<PermissionLoadResult?> Function(
  String name, {
  bool isFile,
  bool isExternalRes,
  bool silent,
});

/// A page that displays the [ViewPermission] for a set of resources.
///
/// Owns all mutable display state (selected resource, permission data,
/// search keywords, view toggle) so that the [ViewPermission] correctly
/// rebuilds when the user selects a resource from the dropdown.
///
/// Parameters:
/// - [resourceNames] - Pre-set list of resource names.
/// - [initialSelectedResourceName] - Initially selected resource.
/// - [initialData] - Initial permission data for the initially selected resource.
/// - [isFile] - Whether the resource is a file.
/// - [isExternalRes] - Whether the resource is externally owned.
/// - [showFullPath] - Whether to show full paths or just filenames.
/// - [showTitle] - Whether to show file titles from [titleData].
/// - [titleData] - Optional map from resource key to display title.
/// - [backgroundColor] - Background colour for the page scaffold.
/// - [loadPermissions] - Loads permission data for a given resource name.
/// - [updatePermissionsFunction] - Called by [PermissionTable] after revoke.

class PermissionPage extends StatefulWidget {
  const PermissionPage({
    super.key,
    required this.resourceNames,
    required this.initialSelectedResourceName,
    required this.initialData,
    required this.isFile,
    required this.isExternalRes,
    required this.showFullPath,
    required this.showTitle,
    required this.titleData,
    required this.backgroundColor,
    required this.loadPermissions,
    required this.updatePermissionsFunction,
    this.embedded = false,
    this.onBack,
  });

  final List<String>? resourceNames;
  final String? initialSelectedResourceName;
  final PermissionLoadResult initialData;
  final bool isFile;
  final bool isExternalRes;
  final bool showFullPath;
  final bool showTitle;
  final Map<String, String>? titleData;
  final Color backgroundColor;
  final LoadPermissionsCallback loadPermissions;
  final Function updatePermissionsFunction;

  /// When true, renders without a [Scaffold] so it can be embedded inside
  /// an existing scaffold. [onBack] is called when the back button is pressed.

  final bool embedded;
  final VoidCallback? onBack;

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  late String? _selectedResourceName;
  late Map<dynamic, dynamic> _permDataMap;
  late String _permDataFile;
  late String _ownerWebId;
  late String _granterWebId;
  late List<LogRecord> _permHistoryList;
  late List<LogRecord> _unFilteredPermHistoryList;
  late bool _noPermissionHistory;

  bool _showCurrentPermOnly = true;
  String _searchCurrPermKeyword = '';
  late bool _showFullPath;
  late bool _showTitle;

  @override
  void initState() {
    super.initState();
    _selectedResourceName = widget.initialSelectedResourceName;
    _applyLoadResult(widget.initialData);
    _showFullPath = widget.showFullPath;
    _showTitle = widget.showTitle;
  }

  void _applyLoadResult(PermissionLoadResult result) {
    _permDataMap = result.permDataMap;
    _permDataFile = result.permDataFile;
    _ownerWebId = result.ownerWebId;
    _granterWebId = result.granterWebId;
    _permHistoryList = result.permHistoryList;
    _unFilteredPermHistoryList = result.permHistoryList;
    _noPermissionHistory = result.noPermissionHistory;
  }

  /// Loads (or reloads) the permission data for [name].
  ///
  /// [silent] is set when this is a refresh triggered by a successful revoke.
  /// In that case the underlying loader suppresses its alert dialogs, and a
  /// null result (the ACL is no longer readable — for example after revoking
  /// our own access to an externally owned resource) clears the table rather
  /// than leaving the just-revoked entry on screen.

  Future<void> _loadPermissions(String name, {bool silent = false}) async {
    final result = await widget.loadPermissions(
      name,
      isFile: widget.isFile,
      isExternalRes: widget.isExternalRes,
      silent: silent,
    );
    if (result == null) {
      if (silent) {
        setState(() {
          _selectedResourceName = name;
          _permDataMap = {};
        });
      }
      return;
    }
    setState(() {
      _selectedResourceName = name;
      _applyLoadResult(result);
    });
  }

  void _searchHistPermissions(String keyword) {
    bool found(String s) => s.toLowerCase().contains(keyword.toLowerCase());
    setState(() {
      _permHistoryList = keyword.isEmpty
          ? _unFilteredPermHistoryList
          : _unFilteredPermHistoryList.where((item) {
              return [
                item.recipientName,
                item.granterName,
                item.permissionType,
                item.permissionList,
              ].map(found).any((r) => r);
            }).toList();
    });
  }

  Widget _buildViewPermission(BuildContext context) => Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints) => ViewPermission(
            resourceNames: widget.resourceNames,
            permDataFile: _permDataFile,
            selectedResourceName: _selectedResourceName,
            noPermissionHistory: _noPermissionHistory,
            isFile: widget.isFile,
            isExternalRes: widget.isExternalRes,
            showFullPath: _showFullPath,
            showTitle: _showTitle,
            titleData: widget.titleData,
            showCurrentPermOnly: _showCurrentPermOnly,
            permDataMap: _permDataMap,
            ownerWebId: _ownerWebId,
            granterWebId: _granterWebId,
            permHistoryList: _permHistoryList,
            constraints: constraints,
            updatePermissionsFunction: (
              name, {
              isFile = true,
              isExternalRes = false,
              silent = false,
            }) async =>
                _loadPermissions(name, silent: silent),
            onSelectedResource: (name) async => _loadPermissions(name),
            onShowCurrentPermOnlyChanged: (value) {
              setState(() {
                _showCurrentPermOnly = value;
                if (!value) {
                  _permHistoryList = _unFilteredPermHistoryList;
                  _searchCurrPermKeyword = '';
                }
              });
            },
            onSearchHistPermissions: _searchHistPermissions,
            onSearchCurrPermissions: (keyword) =>
                setState(() => _searchCurrPermKeyword = keyword),
            searchCurrPermKeyword: _searchCurrPermKeyword,
            onShowFullPathChanged: (v) => setState(() => _showFullPath = v),
            onShowTitleChanged: (v) => setState(() => _showTitle = v),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
            ),
          Expanded(child: _buildViewPermission(context)),
        ],
      );
    }
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: AppBar(title: const Text('Permissions')),
      body: _buildViewPermission(context),
    );
  }
}
