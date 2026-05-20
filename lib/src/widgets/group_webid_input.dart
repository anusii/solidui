/// A dialog to input individual WebID.
///
// Time-stamp: <Sunday 2024-07-11 12:23:00 +1000 Anushka Vidange>
///
/// Copyright (C) 2024-2026, Software Innovation Institute, ANU.
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
/// Authors: Anushka Vidanage, Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:solidpod/solidpod.dart' show whatIsWebID, demoWebID;

import 'package:solidui/solidui.dart'
    show smallGapV, makeSubHeading, GrantPermFormLayout;

/// A [StatefulWidget] dialog for entering a group of WebIDs.
///
/// The widget no longer confirms a selection on its own; the parent form
/// reads the typed values via [onGroupNameChanged] and
/// [onGroupWebIdsChanged] and validates them when the user presses
/// Grant Permission.
class GroupWebIdTextInput extends StatefulWidget {
  /// Optional callback fired on every keystroke in the group name field.
  final void Function(String)? onGroupNameChanged;

  /// Optional callback fired on every keystroke in the list of WebIDs
  /// field. The raw text is passed through; splitting on ';' is performed
  /// by the parent at validation time.
  final void Function(String)? onGroupWebIdsChanged;

  /// Optional callback fired when the user presses the Clear button. The
  /// parent form uses this to drop any cached state so the dialog returns
  /// to a clean state.
  final VoidCallback? onClearFunction;

  const GroupWebIdTextInput({
    super.key,
    this.onGroupNameChanged,
    this.onGroupWebIdsChanged,
    this.onClearFunction,
  });

  @override
  State<GroupWebIdTextInput> createState() => _GroupWebIdTextInputState();
}

class _GroupWebIdTextInputState extends State<GroupWebIdTextInput> {
  /// Text controller for webId list field
  final formControllerGroupWebIds = TextEditingController();

  /// Text controller for group name for webId list

  final formControllerGroupName = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  // dispose text controller when the widget is unmounted
  @override
  void dispose() {
    formControllerGroupWebIds.dispose();
    formControllerGroupName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        smallGapV,
        // Explain webId with example
        MarkdownTooltip(
          message: '$whatIsWebID Eg: $demoWebID',
          child: makeSubHeading('Enter recipient group WebIds'),
        ),
        // Add padding to webid textformfield and suggestion drop down
        Container(
          padding: GrantPermFormLayout.inputPadding,
          child: Column(
            children: [
              // Group name. Should be a single string
              TextFormField(
                controller: formControllerGroupName,
                decoration: const InputDecoration(
                  labelText: 'Group name',
                  hintText:
                      'Multiple words will be combined using the symbol -',
                ),
                onChanged: (value) => widget.onGroupNameChanged?.call(value),
              ),
              smallGapV,
              // List of Web IDs divided by semicolon
              TextFormField(
                controller: formControllerGroupWebIds,
                decoration: const InputDecoration(
                  labelText: 'List of WebIDs',
                  hintText: 'Divide multiple WebIDs using the semicolon (;)',
                ),
                onChanged: (value) => widget.onGroupWebIdsChanged?.call(value),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Wipe both group fields and any cached state so the
                      // user can start over. The actual recipient list is
                      // confirmed later when Grant Permission is pressed.
                      setState(() {
                        formControllerGroupName.clear();
                        formControllerGroupWebIds.clear();
                      });
                      widget.onGroupNameChanged?.call('');
                      widget.onGroupWebIdsChanged?.call('');
                      widget.onClearFunction?.call();
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
