// A screen to demonstrate the data sharing capabilities of PODs.
///
// Time-stamp: <Friday 2026-02-06 08:48:15 +1100 Graham Williams>
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

library;

import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:solidpod/solidpod.dart';

import 'package:solidui/solidui.dart';

part 'grant_permission_ui_state.dart';

/// A [StatefulWidget] for showing and editing access permissions to a
/// resource. It displays the permission table of users with access, and
/// allows the user to change access permissions: by granting access
/// to others, changing a recipients access permissions or revoking
/// access permissions.
///
/// Parameters:
/// - [child] - the child widget to return to.
/// - [title] - Page title to show in the app bar.
/// - [backgroundColor] - Background color.
/// - [showAppBar] - Boolean flag describing whether to show app bar.
/// - [isExternalRes] - Boolean flag describing whether the resource
/// is externally owned.
/// - [accessModeList] - List of access mode options to show.
/// - [recipientTypeList] - List of recipient type options to show.
/// - [ownerWebId] - WebId of the owner of the resource. Required if the resource is externally owned.
/// - [granterWebId] - WebId of the granter of the resource. Required if the resource is externall owned.
/// - [resourceName] - The filename or file url of the resource. If [isExternalRes], it should be the url of the resource.
/// - [isFile] - Boolean flag describing whether the resource is a file. If false, the resource is assumed to be a directory.
/// - [customAppBar] - Specify a custom app bar widget.
/// - [onPermissionGranted] - Callback function called when permissions are granted successfully.
/// - [onNavigateBack] - Callback function called when navigating back from the screen.

class GrantPermissionUi extends StatefulWidget {
  const GrantPermissionUi({
    this.child,
    this.title = 'Demonstrating data sharing functionality',
    this.backgroundColor = const Color.fromARGB(255, 210, 210, 210),
    this.showAppBar = true,
    this.isExternalRes = false,
    this.accessModeList = const ['read', 'write', 'append', 'control'],
    this.recipientTypeList = const ['public', 'indi', 'auth', 'group'],
    this.ownerWebId,
    this.granterWebId,
    this.resourceName,
    this.isFile = true,
    this.dataFilesMap = const {},
    this.customAppBar,
    this.onPermissionGranted,
    this.onNavigateBack,
    this.resourceDisplayName,
    super.key,
  })  : assert(
          // Requires ownerWebId if resource
          // is an externally owned.
          isExternalRes == false || ownerWebId != null,
          'ownerWebId must be provided if isExternalRes == true',
        ),
        assert(
          (showAppBar == true && customAppBar != null) ||
              (showAppBar == true && child != null) ||
              showAppBar == false,
          'Either customAppBar, or child and onNavigateBack function, must be provided if showAppBar is selected',
        );

  /// The child widget to return to when back button is pressed and/or when
  /// page is reloaded after a permission is granted or revoked.

  final Widget? child;

  /// The text appearing in the app bar.

  final String title;

  /// The text appearing in the app bar.

  final Color backgroundColor;

  /// The boolean to decide whether to display an app bar or not.

  final bool showAppBar;

  /// The boolean to decide whether the resources is from an external POD or not

  final bool isExternalRes;

  /// String to assign the webId of the resource owner. Must
  /// be set if [isExternalRes] is set to true.

  final String? ownerWebId;

  /// String to assign the external webId of the resource granter. Must
  /// be set if [isExternalRes] is set to true.

  final String? granterWebId;

  /// The list of access modes to be displayed. By default all four types of
  /// access mode are listed.

  final List<String> accessModeList;

  /// The list of types of recipients receiving permission to access the
  /// resource. By default all four types of recipient are listed.

  final List<String> recipientTypeList;

  /// The name of the file or directory permission is being set to. This is a
  /// non required parameter. If not set there will be a text field to define
  /// the file name. If [isExternalRes] is set to true this must be set and the
  /// value should be the url of the resource.

  final String? resourceName;

  /// A flag to determine whether the given resource is a file or not. This is
  /// a parameter with default value true. In the case where [resourceName] is
  /// not set there will be a toggle to define this parameter.
  /// If [isExternalRes] is set to true this must be set and the value should
  /// be the url of the resource. Also if [resourceName] is set this flag must
  /// also be set

  final bool isFile;

  /// Map of data files on a user's POD used to extract the
  /// user's recipient list by the WebIdTextInputScreen.
  /// If not provided, the WebIdTextInputScreen will read the
  /// user's files in their app data folder on their Pod to
  /// fetch the ACLs needed to derive the user's recipient list.

  final Map<String, dynamic> dataFilesMap;

  /// App specific app bar

  final PreferredSizeWidget? customAppBar;

  /// Callback function called when permissions are granted successfully.

  final VoidCallback? onPermissionGranted;

  /// Callback function called when navigating back from the screen.

  final VoidCallback? onNavigateBack;

  /// Optional human-readable name for the resource, used in notification
  /// messages sent to recipients upon successful permission granting.
  /// Falls back to [resourceName] when not provided.

  final String? resourceDisplayName;

  @override
  GrantPermissionUiState createState() => GrantPermissionUiState();
}
