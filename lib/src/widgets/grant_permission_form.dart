/// A button for sharing a resource.
///
// Time-stamp: <Sunday 2026-01-18 17:06:10 +1100 Graham Williams>
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
/// Authors: Jess Moore, Anushka Vidanage

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

import 'package:solidui/solidui.dart'
    show
        ActionColors,
        GrantPermFormLayout,
        SolidInviteOthersConfig,
        debugPrintException,
        debugPrintFailure,
        failureMsg,
        getPermissionCheckBoxes,
        isPhone,
        makeSubHeading,
        smallGapV,
        successMsg,
        updatePermissionMsg;
import 'package:solidui/src/utils/snack_bar.dart';
import 'package:solidui/src/utils/solid_alert.dart';
import 'package:solidui/src/utils/webid_message.dart' show webIdCheckMessage;
import 'package:solidui/src/widgets/grant_permission_dialogs.dart';
import 'package:solidui/src/widgets/grant_permission_helpers_ui.dart';
import 'package:solidui/src/widgets/group_webid_input.dart';
import 'package:solidui/src/widgets/ind_webid_input.dart'
    show indWebIdFormatError;
import 'package:solidui/src/widgets/ind_webid_input_screen.dart';
import 'package:solidui/src/widgets/select_recipients.dart';

/// Sharing (grant permission) form dialog function
///
/// A [StatefulWidget] for creating a grant permission form
/// dialog to get recipient and access modes to grant for the
/// provided [resourceName]
///
/// Parameters:
/// - [resourceNames] - List of resource names. The first entry is used for
/// display in the dialog title and ACL table refresh. All entries receive
/// the same permission grant.
/// - [isExternalRes] - Boolean flag describing whether the resource
/// is externally owned.
/// - [ownerWebId] - WebId of the owner of the resource. Required if the resource is externally owned.
/// - [granterWebId] - WebId of the granter of the resource. Required if the resource is externally owned.
/// - [accessModeList] - List of access mode options to show.
/// - [recipientTypeList] - List of recipient type options to show.
/// - [isFile] - Boolean flag describing whether the resource is a file. If false, the resource is assumed to be a directory.
/// - [updatePermissionsFunction] is the function to be called to refresh the permission table.
/// - [updatePermissionGrantedFunction] - is the function to be called
/// when permissions are granted successfully
/// - [onPermissionGranted] - Callback function called when permissions are granted successfully.

class GrantPermissionForm extends StatefulWidget {
  /// String to assign the webId of the resource owner.

  final String ownerWebId;

  /// String to assign the external webId of the resource granter.

  final String granterWebId;

  /// List of resource names to grant permission to. The first entry is used
  /// for display in the dialog title and ACL table refresh after granting.
  /// All entries receive the same permission grant sequentially.

  final List<String> resourceNames;

  final bool isExternalRes;

  /// A flag to determine whether the given resource is a file or not.

  final bool isFile;

  /// The list of access modes to show in form. By default
  /// all four types of access mode are listed.

  final List<String> accessModeList;

  /// The list of types of recipients to show in form. By default
  /// all four types of recipient are listed.

  final List<String> recipientTypeList;

  /// Map of data files on a user's POD used to extract the
  /// user's recipient list by the WebIdTextInputScreen.
  /// If not provided, the WebIdTextInputScreen will read the
  /// user's files in their app data folder on their Pod to
  /// fetch the ACLs needed to derive the user's recipient list.

  final Map<String, dynamic> dataFilesMap;

  /// Function run to update permissions table

  final Function updatePermissionsFunction;

  /// Function when permissions are granted successfully

  final Function updatePermissionGrantedFunction;

  /// Callback function called when permissions are granted successfully.

  final VoidCallback? onPermissionGranted;

  /// Optional Invite Others configuration. When provided, the
  /// "POD not initialised" error path offers the user a follow-up
  /// option to invite the recipient(s) to set up their own POD and
  /// try the application.

  final SolidInviteOthersConfig? inviteConfig;

  const GrantPermissionForm({
    super.key,
    required this.updatePermissionsFunction,
    required this.resourceNames,
    required this.ownerWebId,
    required this.granterWebId,
    this.accessModeList = const ['read', 'write', 'append', 'control'],
    this.recipientTypeList = const ['public', 'indi', 'auth', 'group'],
    required this.isExternalRes,
    required this.isFile,
    required this.updatePermissionGrantedFunction,
    this.dataFilesMap = const {},
    this.onPermissionGranted,
    this.inviteConfig,
  });

  @override
  State<GrantPermissionForm> createState() => _GrantPermissionFormState();
}

class _GrantPermissionFormState extends State<GrantPermissionForm> {
  /// Selected recipient

  RecipientType selectedRecipientType = RecipientType.none;

  /// List of webIds for group permission. Populated for public and
  /// authenticated recipients on type-selection; for individual and group
  /// recipients it is populated after Grant Permission is pressed and the
  /// typed WebID(s) have been validated.

  List<dynamic> finalWebIdList = [];

  /// Selected group name

  String selectedGroupName = '';

  /// Selected list of permissions

  List<String> selectedPermList = [];

  /// Flag to track if permissions were granted successfully.

  bool permissionsGrantedSuccessfully = false;

  /// Current text typed into the individual WebID field. Validated on
  /// Grant Permission rather than via a dedicated "Select" button.

  String _pendingIndWebId = '';

  /// Current text typed into the group name field. Validated on Grant
  /// Permission rather than via a dedicated "Select" button.

  String _pendingGroupName = '';

  /// Current text typed into the group "List of WebIDs" field. Validated
  /// on Grant Permission rather than via a dedicated "Select" button.

  String _pendingGroupWebIds = '';

  /// read permission checked flag

  bool readChecked = false;

  /// write permission checked flag

  bool writeChecked = false;

  /// control permission checked flag

  bool controlChecked = false;

  /// append permission checked flag

  bool appendChecked = false;

  /// Public permission check flag

  bool publicChecked = false;

  /// Define access mode list

  List<AccessMode> accessModeList = [];

  @override
  void initState() {
    super.initState();

    // Load access mode list to be displayed
    for (final accessModeStr in widget.accessModeList) {
      accessModeList.add(getAccessMode(accessModeStr));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Private function to call alert dialog in share resource button
  /// context. This provides an alert dialog over the top of the
  /// grant permission form dialog.
  Future<void> _alert(String msg) async => alert(context, msg);

  /// Private function to show snackbar in share resource button context
  Future<void> _showSnackBar(
    String msg,
    Color bgColor, {
    Duration duration = const Duration(seconds: 4),
  }) async =>
      showSnackBar(context, msg, bgColor, duration: duration);

  /// Drop any individual WebID text typed by the user. Invoked by the
  /// Clear button on the individual WebID input widget.
  void clearIndWebIdInput() => setState(() {
        finalWebIdList = [];
        _pendingIndWebId = '';
      });

  /// Drop any group text typed by the user. Invoked by the Clear button
  /// on the group WebID input widget.
  void clearGroupWebIdInput() => setState(() {
        finalWebIdList = [];
        selectedGroupName = '';
        _pendingGroupName = '';
        _pendingGroupWebIds = '';
      });

  /// Validate the individual WebID typed by the user and, when valid,
  /// populate [finalWebIdList]. Returns true when the value is acceptable
  /// and Grant Permission may proceed; otherwise an alert has been shown
  /// and the caller should stop.
  Future<bool> _validateAndApplyIndWebId() async {
    final webId = _pendingIndWebId.trim();
    if (webId.isEmpty) {
      await _alert('Please enter a recipient WebID');
      return false;
    }
    final formatError = indWebIdFormatError(webId);
    if (formatError != null) {
      await _alert(formatError);
      return false;
    }
    final result = await validateWebId(webId);
    if (!mounted) return false;
    if (!result.isValid) {
      final msg = webIdCheckMessage(result, webId: webId) ??
          'This WebID does not exist. Please enter the correct WebID.';
      await _alert(msg);
      return false;
    }
    setState(() {
      finalWebIdList = [webId];
    });
    return true;
  }

  /// Validate the group fields typed by the user and, when valid,
  /// populate [finalWebIdList] and [selectedGroupName]. Returns true when
  /// the value is acceptable and Grant Permission may proceed; otherwise
  /// an alert has been shown and the caller should stop.
  Future<bool> _validateAndApplyGroupWebIds() async {
    final groupName = _pendingGroupName.trim();
    final groupWebIds = _pendingGroupWebIds.trim();
    if (groupName.isEmpty || groupWebIds.isEmpty) {
      await _alert('Please enter a group name and a list of Web IDs');
      return false;
    }
    final webIdList = groupWebIds
        .split(';')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (webIdList.isEmpty) {
      await _alert('Please enter a group name and a list of Web IDs');
      return false;
    }

    // Validate every WebID and collect any failures.
    final failures = <(String, WebIdCheckResult)>[];
    for (final webId in webIdList) {
      final result = await validateWebId(webId);
      if (!mounted) return false;
      if (!result.isValid) {
        failures.add((webId, result));
      }
    }

    if (failures.isNotEmpty) {
      // Surface the most informative failure to the user.
      final (failedWebId, failedResult) = pickGroupFailureToReport(failures);
      final msg = webIdCheckMessage(failedResult, webId: failedWebId) ??
          'At least one of the Web IDs you entered is not valid';
      await _alert(msg);
      return false;
    }

    setState(() {
      finalWebIdList = webIdList;
      selectedGroupName = groupName;
    });
    return true;
  }

  /// Update checked status of access mode boxes to show
  /// selected access modes.
  void updateCheckbox(bool newValue, AccessMode accessMode) => setState(() {
        switch (accessMode) {
          case AccessMode.read:
            readChecked = newValue;
          case AccessMode.write:
            writeChecked = newValue;
          case AccessMode.control:
            controlChecked = newValue;
          case AccessMode.append:
            appendChecked = newValue;
        }
        if (newValue) {
          selectedPermList.add(accessMode.mode);
        } else {
          selectedPermList.remove(accessMode.mode);
        }
      });

  /// Define button click actions for each recipient type button

  /// Set recipients to public
  void _setRecipientsToPublic() => setState(() {
        selectedRecipientType = RecipientType.public;
        finalWebIdList = [publicAgent.value];
      });

  /// Set recipients to authorised users
  void _setRecipientsToAuthUsers() => setState(() {
        selectedRecipientType = RecipientType.authUser;
        finalWebIdList = [authenticatedAgent.value];
      });

  /// Select individual recipient
  void _setRecipientsToIndividual() => setState(() {
        selectedRecipientType = RecipientType.individual;
      });

  /// Select a group of recipients
  void _setRecipientsToGroup() => setState(() {
        selectedRecipientType = RecipientType.group;
      });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: GrantPermFormLayout.contentPadding,
      title: Text(
        makeSharingTitleStr(
          resourceNames: widget.resourceNames,
          isFile: widget.isFile,
        ),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          primary: true,
          child: SizedBox(
            // Use full width on phones, else use a preset narrower width
            width: (!isPhone())
                ? GrantPermFormLayout.dialogWidth
                : double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                makeSubHeading('Select the recipient/s of file access'),

                // Show Select Recipient Buttons
                SelectRecipients(
                  isExternalRes: widget.isExternalRes,
                  recipientTypeList: widget.recipientTypeList,
                  setPublicFunction: _setRecipientsToPublic,
                  setAuthUsersFunction: _setRecipientsToAuthUsers,
                  setIndividualFunction: _setRecipientsToIndividual,
                  setGroupFunction: _setRecipientsToGroup,
                ),

                // Select Individual recipient if required
                if (selectedRecipientType == RecipientType.individual) ...[
                  IndWebIdInputScreen(
                    dataFilesMap: widget.dataFilesMap,
                    onTextChanged: (text) =>
                        setState(() => _pendingIndWebId = text.trim()),
                    onClearFunction: clearIndWebIdInput,
                  ),
                ] else if (selectedRecipientType == RecipientType.group) ...[
                  // Select group of recipients if required
                  GroupWebIdTextInput(
                    onGroupNameChanged: (value) =>
                        setState(() => _pendingGroupName = value),
                    onGroupWebIdsChanged: (value) =>
                        setState(() => _pendingGroupWebIds = value),
                    onClearFunction: clearGroupWebIdInput,
                  ),
                ],
                smallGapV,
                makeSubHeading('Select one or more file access permissions'),
                // Show access mode checkboxes and update
                // selection status on click
                ...getPermissionCheckBoxes(
                  accessModeList,
                  modeSwitches: {
                    AccessMode.read: readChecked,
                    AccessMode.write: writeChecked,
                    AccessMode.control: controlChecked,
                    AccessMode.append: appendChecked,
                  },
                  onUpdate: updateCheckbox,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            // Bail out early when no recipient type has been chosen yet.
            if (selectedRecipientType.type.isEmpty) {
              await _alert('Please select a type of recipient');
              return;
            }

            // Validate the typed WebID(s). On failure the helper has already
            // shown an alert; stop here so we do not attempt to grant.
            if (selectedRecipientType == RecipientType.individual) {
              if (!await _validateAndApplyIndWebId()) return;
            } else if (selectedRecipientType == RecipientType.group) {
              if (!await _validateAndApplyGroupWebIds()) return;
            }

            // Grant Permission and update permission map
            // used by permission table.

            if (selectedPermList.isEmpty) {
              await _alert(
                'Please select one or more file access permissions',
              );
              return;
            }

            // For Public or Authenticated User sharing we need to warn
            // the user that the file will be decrypted in their POD as
            // part of granting access (see `decryptFileInPlace` in
            // solidpod). The helper is a no-op and returns true for
            // other recipient types so we can always await it here.
            if (!context.mounted) return;
            if (!await confirmPublicSharingDecryption(
              context,
              selectedRecipientType,
            )) {
              return;
            }
            if (!context.mounted) return;

            // Grant permission for each resource sequentially. When
            // resourceNames is provided all resources share the same
            // recipient and permission selections.
            final resourcesToGrant = widget.resourceNames;
            SolidFunctionCallStatus result = SolidFunctionCallStatus.success;
            try {
              for (final name in resourcesToGrant) {
                final r = await grantPermission(
                  fileName: name,
                  isFile: widget.isFile,
                  permissionList: selectedPermList,
                  recipientType: selectedRecipientType,
                  recipientWebIdList: finalWebIdList,
                  ownerWebId: widget.ownerWebId,
                  granterWebId: widget.granterWebId,
                  isExternalRes: widget.isExternalRes,
                  groupName: selectedGroupName,
                );
                if (r != SolidFunctionCallStatus.success) {
                  result = r;
                  break;
                }
              }

              // Close grant permission dialog
              if (!context.mounted) return;
              Navigator.of(context).pop();
            } on Object catch (e, stackTrace) {
              result = SolidFunctionCallStatus.fail;
              debugPrintException(e, stackTrace);
            }

            if (result == SolidFunctionCallStatus.success) {
              _showSnackBar(successMsg, ActionColors.success);
              // Update permissions table for the primary resource.
              await widget.updatePermissionsFunction(
                widget.resourceNames.first,
                isFile: widget.isFile,
                isExternalRes: widget.isExternalRes,
              );

              // Mark permissions as granted successfully for callback tracking
              await widget.updatePermissionGrantedFunction();

              // Trigger the onPermissionGranted callback if provided
              widget.onPermissionGranted?.call();
            } else if (result == SolidFunctionCallStatus.fail) {
              if (!context.mounted) return;
              await showGrantPermissionErrorDialog(
                context,
                'Permission granting failed',
                failureMsg,
              );

              // Also log to console for debugging
              debugPrintFailure(
                widget.resourceNames.first,
                finalWebIdList,
                selectedPermList,
              );
            } else if (result == SolidFunctionCallStatus.notInitialised) {
              if (!context.mounted) return;
              await handleNotInitialisedRecipients(
                context,
                widget.inviteConfig,
              );
            } else {
              await _alert(updatePermissionMsg);
            }
          },
          child: const Text('Grant Permission'),
        ),
        TextButton(
          onPressed: () {
            // Close dialog
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
