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
/// Authors: Anushka Vidanage, Jess Moore, Ashley Tang, Dawei Chen, Tony Chen

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
  String _searchCurrPermKeyword = '';
  bool isFile = true;

  /// True when [sharedResourcesHistory] returned an empty list, meaning
  /// no sharing history exists for the current resource.
  bool _noPermissionHistory = false;

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
    // Resolve the display resource from the first entry in resourceNames.
    final displayResource = widget.resourceNames?.firstOrNull;
    // For a single resource, pre-select it so the permission table loads
    // immediately. For multiple resources, start with no selection so the
    // user must pick one from the dropdown first.
    _selectedResourceName =
        (widget.resourceNames != null && widget.resourceNames!.length > 1)
            ? null
            : displayResource;
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
      setState(() => _noPermissionHistory = true);
    } else {
      setState(() {
        _noPermissionHistory = false;
        permHistoryList = updatedPermHistoryList;
        unFilteredPermHistoryList = updatedPermHistoryList;
      });
    }
  }

  void _searchHistPermissions(String enteredKeyword) {
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

  void _searchCurrPermissions(String enteredKeyword) {
    setState(() {
      _searchCurrPermKeyword = enteredKeyword;
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
      permDataFile = widget.resourceNames!.first;
      permTableInitialied = true;
    }

    if (initPermHistoryList != null && permHistoryInitialied == false) {
      if (initPermHistoryList.isEmpty) {
        _noPermissionHistory = true;
      } else {
        permHistoryList = initPermHistoryList;
        unFilteredPermHistoryList = initPermHistoryList;
      }
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

    // A resource is resolved if resourceNames is provided.
    final resolvedResourceName = widget.resourceNames?.firstOrNull;
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
        final body = Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              smallGapV,
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  makeSharingTitleStr(
                    resourceNames: widget.resourceNames,
                    isFile: widget.isFile,
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              smallGapV,
              // Show list of resources
              // Resource list: left-aligned text items in a height-capped
              // scrollable section so a long list doesn't overflow.
              if (widget.resourceNames != null) ...[
                GrantPermissionResourceList(
                  resourceNames: widget.resourceNames!,
                  showFullPath: _showFullPath,
                ),
                smallGapV,
              ] else if (resolvedResourceName != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _displayName(resolvedResourceName),
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
                  onResourceTypeChange: (bool v) => setState(() => isFile = v),
                ),
                smallGapV,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 5,
                  children: [
                    retrievePermissionButton,
                  ],
                ),
                smallGapV,
              ],
              if (resolvedResourceName != null) ...[
                // Show hint statement
                Row(
                  children: [
                    // Show info icon on first line of hint message
                    const Icon(Icons.info, color: Colors.grey, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      (widget.resourceNames!.length > 1)
                          ? 'Click \'Share Resources\' button to share access to these files'
                          : 'Click \'Share Resource\' button to share access to this file',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                smallGapV,
              ],
              ShareResourceButton(
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
                onShowFullPathChanged: (v) => setState(() => _showFullPath = v),
                shareButtonColor: widget.shareButtonColor,
              ),
              // Separator between Sharing and Permissions sections
              const Divider(),
              // Permission section of page comprising
              // permission table/history for resource
              // with resource selection if resourceNames not null
              Expanded(
                child: PermissionSection(
                  resourceNames: widget.resourceNames,
                  permDataFile: permDataFile,
                  selectedResourceName: _selectedResourceName,
                  noPermissionHistory: _noPermissionHistory,
                  isFile: getIsFile(),
                  isExternalRes: widget.isExternalRes,
                  showFullPath: _showFullPath,
                  showCurrentPermOnly: showCurrentPermOnly,
                  permDataMap: permDataMap,
                  ownerWebId: _ownerWebId,
                  granterWebId: _granterWebId,
                  permHistoryList: permHistoryList,
                  constraints: constraints,
                  updatePermissionsFunction: _updatePermissions,
                  onSelectedResource: (name) async {
                    setState(() => _selectedResourceName = name);
                    await _updatePermissions(
                      name,
                      isFile: widget.isFile,
                      isExternalRes: widget.isExternalRes,
                    );
                  },
                  onShowCurrentPermOnlyChanged: (value) {
                    setState(() => showCurrentPermOnly = value);
                    if (!showCurrentPermOnly) {
                      setState(() {
                        permHistoryList = unFilteredPermHistoryList;
                        _searchCurrPermKeyword = '';
                      });
                    }
                  },
                  onSearchHistPermissions: _searchHistPermissions,
                  onSearchCurrPermissions: _searchCurrPermissions,
                  searchCurrPermKeyword: _searchCurrPermKeyword,
                ),
              ),
            ],
          ),
        );
        return appBar == null
            ? body
            : Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                appBar: appBar,
                body: body,
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) => (widget.resourceNames == null)
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
