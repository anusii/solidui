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
  bool _viewingPermissions = false;

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

  /// Whether to show file titles from [widget.titleData] instead of paths.

  bool _showTitle = false;

  /// Returns the display label for a resource name, respecting [_showTitle]
  /// and [_showFullPath].

  String _displayName(String name) => PathUtils.resourceDisplayName(
        name,
        showFullPath: _showFullPath,
        showTitle: _showTitle,
        titleData: widget.titleData,
      );

  /// Loads permission details data from the ACL on the POD server.
  ///
  /// When [silent] is true the informational alert dialogs are suppressed.
  /// This is used by the post-revoke table refresh: once a recipient (or the
  /// current user's own access to an externally owned resource) has been
  /// revoked, the resource's ACL may no longer be readable, and surfacing a
  /// "no ACL file" dialog at that point is confusing rather than helpful.

  Future<PermissionDetails?> loadACLData(
    String resName, {
    bool isFile = true,
    bool isExternalRes = false,
    bool silent = false,
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
        if (!silent) await _alert('Please login first to retrieve permission');

      case SolidFunctionCallStatus.noAclFound:
        if (!silent) await _alert(noAclMsg);

      case SolidFunctionCallStatus.fileNotExists:
        if (!silent) {
          await _alert(
            'The resource "$resName" does not exist on your pod. '
            'Please create it first.',
          );
        }

      default:
        if (!silent) await _alert('Unknown error');
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    // Default to show title if titleData provided
    _showTitle = widget.titleData?.isNotEmpty ?? false;
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

  /// Loads permission data for [fileName] and returns it as a
  /// [PermissionLoadResult]. Returns null if the resource could not be found.

  Future<PermissionLoadResult?> _loadPermissionData(
    String fileName, {
    bool isFile = true,
    bool isExternalRes = false,
    bool silent = false,
  }) async {
    final pdata = await loadACLData(
      fileName,
      isFile: isFile,
      isExternalRes: isExternalRes,
      silent: silent,
    );

    if (pdata == null || pdata.permissionMap.isEmpty) {
      return null;
    }

    final history = await sharedResourcesHistory(resourceName: fileName);

    return (
      permDataMap: pdata.permissionMap,
      permDataFile: fileName,
      ownerWebId: pdata.ownerWebId,
      granterWebId: pdata.granterWebId,
      permHistoryList: history,
      noPermissionHistory: history.isEmpty,
    );
  }

  Future<void> _updatePermissions(
    String fileName, {
    bool isFile = true,
    bool isExternalRes = false,
  }) async {
    final result = await _loadPermissionData(
      fileName,
      isFile: isFile,
      isExternalRes: isExternalRes,
    );
    if (result == null) return;

    setState(() {
      permDataMap = result.permDataMap;
      permDataFile = result.permDataFile;
      _ownerWebId = result.ownerWebId;
      _granterWebId = result.granterWebId;
    });

    if (result.noPermissionHistory) {
      setState(() => _noPermissionHistory = true);
    } else {
      setState(() {
        _noPermissionHistory = false;
        permHistoryList = result.permHistoryList;
        unFilteredPermHistoryList = result.permHistoryList;
      });
    }
  }

  @override
  void dispose() {
    fileNameController.dispose();
    super.dispose();
  }

  Future<void> _alert(String msg) async => alert(context, msg);

  void _initFromSnapshot(
    PermissionDetails? initPermDetails,
    List<LogRecord>? initPermHistoryList,
  ) {
    if (initPermDetails != null && !permTableInitialied) {
      permDataMap = initPermDetails.permissionMap;
      _ownerWebId = initPermDetails.ownerWebId;
      _granterWebId = initPermDetails.granterWebId;
      permDataFile = widget.resourceNames!.first;
      permTableInitialied = true;
    }
    if (initPermHistoryList != null && !permHistoryInitialied) {
      if (initPermHistoryList.isEmpty) {
        _noPermissionHistory = true;
      } else {
        permHistoryList = initPermHistoryList;
        unFilteredPermHistoryList = initPermHistoryList;
      }
      permHistoryInitialied = true;
    }
  }

  /// Builds a [PermissionPage] populated with the current state.
  PermissionPage _buildPermissionPage({
    bool embedded = false,
    VoidCallback? onBack,
    required bool Function() getIsFile,
  }) =>
      PermissionPage(
        resourceNames: widget.resourceNames,
        initialSelectedResourceName: _selectedResourceName,
        initialData: (
          permDataMap: permDataMap,
          permDataFile: permDataFile,
          ownerWebId: _ownerWebId,
          granterWebId: _granterWebId,
          permHistoryList: permHistoryList,
          noPermissionHistory: _noPermissionHistory,
        ),
        isFile: getIsFile(),
        isExternalRes: widget.isExternalRes,
        showFullPath: _showFullPath,
        showTitle: _showTitle,
        titleData: widget.titleData,
        backgroundColor: widget.backgroundColor,
        loadPermissions: (
          name, {
          isFile = true,
          isExternalRes = false,
          silent = false,
        }) =>
            _loadPermissionData(
          name,
          isFile: isFile,
          isExternalRes: isExternalRes,
          silent: silent,
        ),
        updatePermissionsFunction: _updatePermissions,
        embedded: embedded,
        onBack: onBack,
      );

  Widget _buildPermPage(
    BuildContext context, [
    PermissionDetails? initPermDetails,
    List<LogRecord>? initPermHistoryList,
  ]) {
    _initFromSnapshot(initPermDetails, initPermHistoryList);

    // A resource is resolved if resourceNames is provided.
    final resolvedResourceName = widget.resourceNames?.firstOrNull;
    bool getIsFile() => resolvedResourceName != null ? widget.isFile : isFile;

    // When embedded (no app bar), show PermissionPage inline on demand.
    if (!widget.showAppBar && _viewingPermissions) {
      return _buildPermissionPage(
        embedded: true,
        onBack: () => setState(() => _viewingPermissions = false),
        getIsFile: getIsFile,
      );
    }

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
              if (widget.resourceNames != null) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: ResourceDisplayModeControl(
                    showFullPath: _showFullPath,
                    showTitle: _showTitle,
                    titleData: widget.titleData,
                    onShowFullPathChanged: (v) =>
                        setState(() => _showFullPath = v),
                    onShowTitleChanged: (v) => setState(() => _showTitle = v),
                  ),
                ),
                smallGapV,
                GrantPermissionResourceList(
                  resourceNames: widget.resourceNames!,
                  showFullPath: _showFullPath,
                  showTitle: _showTitle,
                  titleData: widget.titleData,
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
              ],
              if (resolvedResourceName != null) ...[
                // Show hint statement
                Row(
                  children: [
                    // Show info icon on first line of hint message
                    const Icon(Icons.info, color: Colors.grey, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        (widget.resourceNames!.length > 1)
                            ? 'Click \'Share Resources\' button to share access to these files'
                            : 'Click \'Share Resource\' button to share access to this file',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                smallGapV,
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 10,
                children: [
                  if (resolvedResourceName == null)
                    ElevatedButton(
                      onPressed: () async {
                        final fileName = fileNameController.text;
                        if (fileName.isEmpty) {
                          await _alert('Please enter a file name');
                        } else {
                          await _updatePermissions(fileName, isFile: isFile);
                        }
                      },
                      child: const Text('Retrieve permissions'),
                    ),
                  if (resolvedResourceName != null ||
                      permDataFile.isNotEmpty) ...[
                    ViewPermissionButton(
                      buttonColor: widget.buttonColor,
                      onPressed: () {
                        if (!widget.showAppBar) {
                          setState(() => _viewingPermissions = true);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => _buildPermissionPage(
                              getIsFile: getIsFile,
                            ),
                          ),
                        );
                      },
                    ),
                    ShareResourceButton(
                      resourceNames: widget.resourceNames,
                      fileNameController: fileNameController,
                      accessModeList: widget.accessModeList,
                      recipientTypeList: widget.recipientTypeList,
                      updatePermissionsFunction: _updatePermissions,
                      ownerWebId: _ownerWebId,
                      granterWebId: _granterWebId,
                      isExternalRes: widget.isExternalRes,
                      isFile: getIsFile(),
                      dataFilesMap: widget.dataFilesMap,
                      onPermissionGranted: widget.onPermissionGranted,
                      onRecipientTypeGranted: widget.onRecipientTypeGranted,
                      resourceDisplayName: widget.resourceDisplayName,
                      buttonColor:
                          widget.shareButtonColor ?? widget.buttonColor,
                      inviteConfig: widget.inviteConfig,
                    ),
                  ], // end of resolvedResourceName != null || permDataFile.isNotEmpty
                ],
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
            final PermissionDetails? initCurrentPerm =
                snapshot.data![0] as PermissionDetails?;
            // final PermissionDetails initCurrentPerm =
            //     snapshot.data![0] as PermissionDetails;
            final List<LogRecord> initPermHistoryList =
                snapshot.data![1] as List<LogRecord>;
            return (initCurrentPerm == null ||
                    initCurrentPerm.permissionMap.isEmpty)
                // return initCurrentPerm.permissionMap.isEmpty
                ? _buildPermPage(context)
                : _buildPermPage(context, initCurrentPerm, initPermHistoryList);
          },
        );
}
