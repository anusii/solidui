/// Grant Permission UI State - State class for GrantPermissionUi.
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
/// Authors: Anushka Vidanage, Jess Moore, Ashley Tang, Dawei Chen

part of 'grant_permission_ui.dart';

/// State class that manages permission data loading, searching and filtering, and permission granting and revoking.

class GrantPermissionUiState extends State<GrantPermissionUi>
    with SingleTickerProviderStateMixin {
  bool permTableInitialied = false;
  bool permHistoryInitialied = false;

  List<AccessMode> accessModeList = [];
  List<RecipientType> recipientTypeList = [];

  final fileNameController = TextEditingController();

  Map<dynamic, dynamic> permDataMap = {};

  String _ownerWebId = '';
  String _granterWebId = '';
  String permDataFile = '';
  bool permissionsGrantedSuccessfully = false;

  late Future<PermissionDetails?> getACLPerm;
  late Future<List<LogRecord>> getPermHistoryList;

  List<LogRecord> permHistoryList = [];
  List<LogRecord> unFilteredPermHistoryList = [];
  bool showCurrentPermOnly = true;
  bool isFile = true;

  /// The resource currently selected for the permission table/history display.
  /// Defaults to the first (or only) resource; updated when the user picks a
  /// different entry from the resource selector dropdown.

  String? _selectedResourceName;

  /// Whether to show full resource paths or just the last path segment.

  bool _showFullPath = true;

  /// Returns the display label for a resource name, respecting [_showFullPath].

  String _displayName(String name) =>
      _showFullPath ? name : name.split('/').last;

  /// Loads permission details data from the ACL on the POD server.

  Future<PermissionDetails?> loadACLData(
    String resName, {
    bool isFile = true,
    bool isExternalRes = false,
  }) async {
    final SolidFunctionCallStatus response = await chkExistsAndHasAcl(
      fileName: resName,
      isFile: isFile,
      isExternalRes: isExternalRes,
    );

    switch (response) {
      case SolidFunctionCallStatus.aclFound:
        final Map<dynamic, dynamic> result = await readPermission(
          fileName: resName,
          isFile: isFile,
          isExternalRes: isExternalRes,
        );

        final permissionDetails = PermissionDetails(
          permissionMap: result,
          ownerWebId: await getAuthoriser(
            isExternalRes: isExternalRes,
            webId: widget.ownerWebId,
          ),
          granterWebId: await getAuthoriser(
            isExternalRes: isExternalRes,
            isGranter: true,
          ),
        );

        return permissionDetails;

      case SolidFunctionCallStatus.notLoggedIn:
        await _alert('Please login first to retrieve permission');

      case SolidFunctionCallStatus.noAclFound:
        await _alert(noAclMsg);

      default:
        await _alert('Unknown error');
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    // Resolve the display resource: explicit resourceName takes priority,
    // otherwise use the first entry from resourceNames.
    final displayResource =
        widget.resourceName ?? widget.resourceNames?.firstOrNull;
    _selectedResourceName = displayResource;
    if (displayResource != null) {
      getACLPerm = loadACLData(
        displayResource,
        isFile: widget.isFile,
        isExternalRes: widget.isExternalRes,
      );
      getPermHistoryList =
          sharedResourcesHistory(resourceName: displayResource);
    }
  }

  Future<void> _updatePermissions(
    String fileName, {
    bool isFile = true,
    bool isExternalRes = false,
  }) async {
    final pdata = await loadACLData(
      fileName,
      isFile: isFile,
      isExternalRes: isExternalRes,
    );
    final updatedPermHistoryList =
        await sharedResourcesHistory(resourceName: fileName);

    assert(pdata != null);

    if (pdata!.permissionMap.isEmpty) {
      await _alert('We could not find a resource by the name $fileName');
    } else {
      setState(() {
        permDataMap = pdata.permissionMap;
        permDataFile = fileName;
        _ownerWebId = pdata.ownerWebId;
        _granterWebId = pdata.granterWebId;
      });
    }

    if (updatedPermHistoryList.isEmpty) {
      await _alert(
        'We could not find permission log entries for resource by the name $fileName',
      );
    } else {
      setState(() {
        permHistoryList = updatedPermHistoryList;
        unFilteredPermHistoryList = updatedPermHistoryList;
      });
    }
  }

  void _searchLogs(String enteredKeyword) {
    bool found(it) => it.toLowerCase().contains(enteredKeyword.toLowerCase());

    List<LogRecord> results = [];
    if (enteredKeyword.isEmpty) {
      results = unFilteredPermHistoryList;
    } else {
      results = unFilteredPermHistoryList.where((item) {
        return [
          item.recipientName,
          item.granterName,
          item.permissionType,
          item.permissionList,
        ].map(found).any((result) => result);
      }).toList();
    }

    setState(() {
      permHistoryList = results;
    });
  }

  void getLatestLogRecords() {
    List<LogRecord> currentLogRecords = [];
    List<String> currentRecipients = [];

    for (final record in permHistoryList) {
      if ((record.permissionType).contains('grant')) {
        final recipientWebId = record.recipientWebId;

        currentRecipients =
            currentLogRecords.map((item) => item.recipientWebId).toList();

        if (currentRecipients.contains(recipientWebId)) {
          final int prevMatchIndex = currentLogRecords
              .indexWhere((item) => item.recipientWebId == recipientWebId);
          final String prevDateTime =
              currentLogRecords[prevMatchIndex].dateTimeStr;
          if ([0, 1].contains(
            DateTime.parse(record.dateTimeStr)
                .compareTo(DateTime.parse(prevDateTime)),
          )) {
            currentLogRecords[prevMatchIndex] = record;
          }
        } else {
          currentLogRecords.add(record);
        }
      } else {
        continue;
      }
    }

    setState(() {
      permHistoryList = currentLogRecords;
    });
  }

  Future<void> _alert(String msg) async => alert(context, msg);

  Widget _buildPermPage(
    BuildContext context, [
    PermissionDetails? initPermDetails,
    List<LogRecord>? initPermHistoryList,
  ]) {
    if (initPermDetails != null && permTableInitialied == false) {
      permDataMap = initPermDetails.permissionMap;
      _ownerWebId = initPermDetails.ownerWebId;
      _granterWebId = initPermDetails.granterWebId;
      permDataFile = widget.resourceName ?? widget.resourceNames!.first;
      permTableInitialied = true;
    }

    if (initPermHistoryList != null && permHistoryInitialied == false) {
      permHistoryList = initPermHistoryList;
      unFilteredPermHistoryList = initPermHistoryList;
      permHistoryInitialied = true;
    }

    final retrievePermissionButton = ElevatedButton(
      child: const Text('Retrieve permissions'),
      onPressed: () async {
        final fileName = fileNameController.text;
        if (fileName.isEmpty) {
          await _alert('Please enter a file name');
        } else {
          await _updatePermissions(fileName, isFile: isFile);
        }
      },
    );

    // A resource is resolved if resourceName or resourceNames is provided.
    final resolvedResourceName =
        widget.resourceName ?? widget.resourceNames?.firstOrNull;
    bool getIsFile() => resolvedResourceName != null ? widget.isFile : isFile;

    final PreferredSizeWidget? appBar;
    if (widget.showAppBar) {
      appBar = widget.customAppBar ??
          defaultAppBar(
            context,
            widget.title,
            widget.backgroundColor,
            widget.child as Widget,
            onNavigateBack: () => widget.onNavigateBack?.call(),
            getResult: () => permissionsGrantedSuccessfully,
          );
    } else {
      appBar = null;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: appBar,
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                smallGapV,
                makeHeading(
                  widget.resourceNames != null
                      ? widget.isFile
                          ? 'Sharing multiple files'
                          : 'Sharing multiple folders'
                      : makeSharingTitleStr(
                          fileName: resolvedResourceName,
                          isFile: widget.isFile,
                        ),
                  bold: false,
                  addColor: false,
                  addPadding: false,
                ),
                smallGapV,
                // Resource list: left-aligned text items, styled to match
                // the dropdown items.
                if (widget.resourceNames != null) ...[
                  for (final name in widget.resourceNames!)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          _displayName(name),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 12),
                        ),
                      ),
                    ),
                  smallGapV,
                ] else if (resolvedResourceName != null) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      resolvedResourceName,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 12),
                    ),
                  ),
                  smallGapV,
                ],
                if (resolvedResourceName == null) ...[
                  getResourceForm(
                    formController: fileNameController,
                    isFile: isFile,
                    onResourceTypeChange: (bool v) =>
                        setState(() => isFile = v),
                  ),
                  smallGapV,
                  retrievePermissionButton,
                  smallGapV,
                ],
                ShareResourceButton(
                  resourceName: resolvedResourceName,
                  resourceNames: widget.resourceNames,
                  fileNameController: fileNameController,
                  accessModeList: widget.accessModeList,
                  recipientTypeList: widget.recipientTypeList,
                  updatePermissionsFunction: _updatePermissions,
                  ownerWebId: _ownerWebId,
                  granterWebId: _granterWebId,
                  isExternalRes: widget.isExternalRes,
                  isFile: widget.isFile,
                  dataFilesMap: widget.dataFilesMap,
                  onPermissionGranted: widget.onPermissionGranted,
                  showFullPath: _showFullPath,
                  onShowFullPathChanged: (v) =>
                      setState(() => _showFullPath = v),
                ),
                // Separator between Sharing and Permissions sections
                const Divider(),
                smallGapV,
                makeSubHeading(
                  showCurrentPermOnly
                      ? 'People with current access'
                      : 'Permission history',
                  addPadding: false,
                ),
                smallGapV,
                // Dropdown to select which resource's permission table/history to show.
                if (widget.resourceNames != null) ...[
                  // TODO: fix width and alignment of drop down relative to layout
                  DropdownButton<String>(
                    value: _selectedResourceName,
                    focusColor: DropdownColors.primary,
                    dropdownColor: DropdownColors.accent,
                    isExpanded: true,
                    padding: const EdgeInsets.all(10),
                    // menuWidth: 600,
                    alignment: AlignmentGeometry.centerRight,
                    style: const TextStyle(fontSize: 12),
                    items: widget.resourceNames!
                        .map(
                          (name) => DropdownMenuItem(
                            value: name,
                            child: Text(
                              _displayName(name),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (name) async {
                      if (name != null && name != _selectedResourceName) {
                        setState(() => _selectedResourceName = name);
                        await _updatePermissions(
                          name,
                          isFile: widget.isFile,
                          isExternalRes: widget.isExternalRes,
                        );
                      }
                    },
                  ),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 5.0,
                  children: [
                    Expanded(
                      flex: 3,
                      child: showCurrentPermOnly
                          ? const Text('')
                          : TextField(
                              onChanged: (value) => _searchLogs(value),
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
                              activeThumbColor: ActionColors.success,
                              onChanged: (bool value) {
                                setState(() {
                                  showCurrentPermOnly = value;
                                });
                                if (!showCurrentPermOnly) {
                                  setState(() {
                                    permHistoryList = unFilteredPermHistoryList;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                vSmallGapV,
                showCurrentPermOnly
                    ? PermissionTable(
                        resourceName: permDataFile,
                        permDataMap: permDataMap,
                        ownerWebId: _ownerWebId,
                        granterWebId: _granterWebId,
                        updatePermissionsFunction: _updatePermissions,
                        isFile: getIsFile(),
                        isExternalRes: widget.isExternalRes,
                        constraints: constraints,
                      )
                    : PermissionHistory(
                        key: ValueKey(permHistoryList),
                        resourceName: resolvedResourceName!,
                        permHistory: permHistoryList,
                        constraints: constraints,
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => (widget.resourceName == null &&
          widget.resourceNames == null)
      ? _buildPermPage(context)
      : FutureBuilder(
          future: Future.wait([
            getACLPerm,
            getPermHistoryList,
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Scaffold(body: loadingScreen(normalLoadingScreenHeight));
            }
            final PermissionDetails initCurrentPerm =
                snapshot.data![0] as PermissionDetails;
            final List<LogRecord> initPermHistoryList =
                snapshot.data![1] as List<LogRecord>;
            return initCurrentPerm.permissionMap.isEmpty
                ? _buildPermPage(context)
                : _buildPermPage(context, initCurrentPerm, initPermHistoryList);
          },
        );
}
