/// UI helper functions for the grant permission workflow.
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

import 'package:solidpod/src/solid/constants/web_acl.dart';

import 'package:solidui/src/constants/ui_layout.dart' show SharingPageLayout;
import 'package:solidui/src/widgets/permission_checkbox.dart';

/// Build a list of permission check-box widgets for the given [accessModes].

List<Widget> getPermissionCheckBoxes(
  List<AccessMode> accessModes, {
  required Map<AccessMode, bool> modeSwitches,
  required Function onUpdate,
}) =>
    [
      for (final mode in AccessMode.getAllModes())
        if (accessModes.contains(mode))
          permissionCheckbox(mode, modeSwitches[mode]!, onUpdate),
    ];

/// Build a resource form widget with a text field and a file/directory toggle.

Widget getResourceForm({
  required TextEditingController formController,
  required bool isFile,
  required void Function(bool) onResourceTypeChange,
}) =>
    Padding(
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
          SwitchListTile(
            title: const Text(
              'Is a File?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(isFile ? 'Yes' : 'No'),
            value: isFile,
            onChanged: onResourceTypeChange,
            thumbColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) =>
                  states.contains(WidgetState.selected) ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
