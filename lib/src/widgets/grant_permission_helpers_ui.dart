/// UI helper functions and constants for the grant permission workflow.
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
/// Authors: Anushka Vidanage, Jess Moore, Ashley Tang, Dawei Chen

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart' show AccessMode, RecipientType;

import 'package:solidui/src/constants/ui_colors.dart' show ActionColors;
import 'package:solidui/src/constants/ui_layout.dart' show SharingPageLayout;
import 'package:solidui/src/widgets/permission_checkbox.dart';

// Constants

/// Tooltip strings for each recipient type shown in the sharing UI.

const recipientToolTips = <RecipientType, String>{
  RecipientType.public: '''
 **Public**

 This file will be publicly accessible so that even users without a
 Data Vault can access the file.
 ''',
  RecipientType.authUser: '''
**Users**

The file will be available to any user who has registered a Data
Vault. When they have logged into their Data Vault they will be able
to access the file.
''',
  RecipientType.individual: '''
**Individual**

The file will be available only to the identified individual user. A
WebID is required to identify the individual who is granted access to
the file.
''',
  RecipientType.group: '''
**Group**

A collection of WebIDs can be provided so that as a group they can
access the file.
''',
};

const updatePermissionMsg =
    'Please login first to update file access permission';
const podNotInitMsg =
    'The owner of one or more WebIds you entered have not initialised their PODs yet! They need to login and setup their POD first.';
const noAclMsg =
    'Resource does not have a corresponding ACL file.\n'
    'If the ACL is inherited, provide parent directory as the resource name!';
const successMsg = 'File access permissions granted successfully!';
const failureMsg =
    'Permission granting failed. Check console logs for details. Common issues: resource not found, invalid WebID format, or network connectivity.';

// Debug helpers

String getFailureMsg(String fileName) =>
    '❌ [GrantPermissionUI] Permission granting failed for file: $fileName';

String getRecipientMsg(List<dynamic>? finalWebIdList) =>
    '🎯 [GrantPermissionUI] Recipients: $finalWebIdList';

String getPermissionMsg(List<String> permissionList) =>
    '🔐 [GrantPermissionUI] Permissions: $permissionList';

String getExceptionMsg(Object e) =>
    '💥 [GrantPermissionUI] Exception in grantPermission: $e';

String getStackTraceMsg(StackTrace stackTrace) =>
    '📚 [GrantPermissionUI] Stack trace: $stackTrace';

void debugPrintException(Object e, StackTrace stackTrace) {
  debugPrint(getExceptionMsg(e));
  debugPrint(getStackTraceMsg(stackTrace));
}

void debugPrintFailure(
  String fileName,
  List<dynamic>? finalWebIdList,
  List<String> permissionList,
) {
  debugPrint(getFailureMsg(fileName));
  debugPrint(getRecipientMsg(finalWebIdList));
  debugPrint(getPermissionMsg(permissionList));
}

// Recipient type lists

/// Relevant recipients types for resource sharing by the resource owner.
const ownerRecipientTypes = [
  RecipientType.public,
  RecipientType.authUser,
  RecipientType.individual,
  RecipientType.group,
];

/// Relevant recipient types for resource sharing by the resource granter
/// (i.e. an entity with control access).
const granterRecipientTypes = [RecipientType.individual, RecipientType.group];

/// Get title of sharing page.
String makeSharingTitleStr({List<String>? resourceNames, bool isFile = false}) {
  if (resourceNames != null && resourceNames.length > 1) {
    return isFile ? 'Sharing multiple files' : 'Sharing multiple folders';
  } else if (resourceNames != null) {
    return isFile ? 'Sharing file' : 'Sharing folder';
  }
  return 'Share your data with other user\'s PODs';
}

// Widget builders

/// Build a list of permission check-box widgets for the given [accessModes].

List<Widget> getPermissionCheckBoxes(
  List<AccessMode> accessModes, {
  required Map<AccessMode, bool> modeSwitches,
  required Function onUpdate,
}) => [
  for (final mode in AccessMode.getAllModes())
    if (accessModes.contains(mode))
      permissionCheckbox(mode, modeSwitches[mode]!, onUpdate),
];

/// Build a resource form widget with a text field and a file/directory toggle.

Widget getResourceForm({
  required TextEditingController formController,
  required bool isFile,
  required void Function(bool) onResourceTypeChange,
}) => Padding(
  padding: SharingPageLayout.inputPadding,
  child: Column(
    children: [
      TextFormField(
        controller: formController,
        decoration: const InputDecoration(
          hintText:
              'Data file path (inside your data folder, Eg: personal/about.ttl)',
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Empty field' : null,
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Is a File?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(isFile ? 'Yes' : 'No'),
            ],
          ),
          Builder(
            builder: (context) => Switch(
              value: isFile,
              activeThumbColor:
                  Theme.of(
                    context,
                  ).switchTheme.thumbColor?.resolve({WidgetState.selected}) ??
                  ActionColors.success,
              onChanged: onResourceTypeChange,
            ),
          ),
        ],
      ),
    ],
  ),
);
