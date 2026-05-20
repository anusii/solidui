/// A dialog to input Group of WebIDs.
///
// Time-stamp: <Tuesday 2025-07-22 13:59:21 +1000 Graham Williams>
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
/// Authors: Anushka Vidanage, Jess Moore, Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:solidpod/solidpod.dart'
    show validateWebId, whatIsWebID, demoWebID;

import 'package:solidui/solidui.dart'
    show
        smallGapV,
        makeSubHeading,
        GrantPermFormLayout,
        WebIdLayout,
        DropdownColors;
import 'package:solidui/src/utils/solid_alert.dart';
import 'package:solidui/src/utils/webid_message.dart' show webIdCheckMessage;

/// Returns a human-readable error describing why [text] is not a valid WebID,
/// or `null` if [text] is well-formed.
///
/// This is shared between the inline field validation in
/// [IndWebIdTextInput] and the deferred validation performed when the user
/// presses "Grant Permission" on the parent dialog.
String? indWebIdFormatError(String text) {
  final trimmed = text.trim();
  final uri = Uri.parse(trimmed);

  // Check for https scheme and ://
  if (!uri.isScheme('HTTPS') || !uri.toString().contains('://')) {
    return 'Must start with https://';
  }
  // Check WebID contains host followed by '/'
  if (!uri.path.contains('/')) {
    return 'Must have form https://[POD server host]/[their username]/profile/card#me';
  }
  // Check for WebID path with profile suffix
  if (!uri.path.toLowerCase().contains('/profile/card')) {
    return 'Must end with \'/[their username]/profile/card#me\'';
  }
  // Check ends in #me
  if (uri.fragment.toLowerCase() != 'me') {
    return 'Must end with URL fragment #me after /profile/card';
  }
  // Check fully qualified web address
  // 20250721 jm Retaining this check, may not be needed
  if (!Uri.parse(trimmed.replaceAll('#me', '')).isAbsolute) {
    return 'Must be a fully qualified web address';
  }
  return null;
}

/// A [StatefulWidget] dialog for entering an individual WebID.
///
/// The widget no longer confirms a selection on its own; instead the parent
/// form reads the typed text via [onTextChanged] and validates it when the
/// user presses Grant Permission. [uniqRecipWebIdList] is a list of the
/// webIds of unique recipients of the owner's data, used to populate
/// suggestions.
///
class IndWebIdTextInput extends StatefulWidget {
  /// Initialise widget variables.

  const IndWebIdTextInput({
    this.uniqRecipWebIdList,
    this.onTextChanged,
    this.onClearFunction,
    super.key,
  });

  /// List of unique recipient webIds
  final List<String>? uniqRecipWebIdList;

  /// Optional callback fired on every keystroke with the current raw text.
  /// The parent form uses this to capture the field value so it can be
  /// validated when Grant Permission is pressed.
  final void Function(String)? onTextChanged;

  /// Optional callback fired when the user presses the Clear button. The
  /// parent form uses this to drop any cached state so the dialog returns
  /// to a clean state.
  final VoidCallback? onClearFunction;

  @override
  State<IndWebIdTextInput> createState() => _IndWebIdTextInputState();
}

class _IndWebIdTextInputState extends State<IndWebIdTextInput> {
  /// Text controller for WebId field
  final formControllerWebId = TextEditingController();

  /// Capture whether user has started to enter text
  bool _textEntered = false;

  /// WebId list
  List<String> webIdList = [];

  /// Initialise the matching suggestions list
  List<String> suggestionList = [];
  String hint = '';

  // Dispose text controller when the widget is unmounted
  @override
  void dispose() {
    formControllerWebId.dispose();
    super.dispose();
  }

  @override
  void initState() {
    webIdList = widget.uniqRecipWebIdList ?? [];
    super.initState();
  }

  /// Generate advice to help user enter valid WebID.
  String? get _helpText =>
      indWebIdFormatError(formControllerWebId.value.text);

  /// Generate suggestions for users based on input matches to
  /// current complete recipient list of user
  void filterSuggestions(String value) {
    suggestionList.clear();

    if (value.isEmpty) {
      setState(() {});
      return;
    }
    suggestionList = webIdList
        .where((e) => e.toLowerCase().contains(value.toLowerCase()))
        .toList();

    setState(() {});
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
          child: makeSubHeading('Enter or select recipient\'s WebId'),
        ),
        // Add padding to webid textformfield and suggestion drop down
        Container(
          padding: GrantPermFormLayout.inputPadding,
          child: Column(
            children: [
              // Web ID text field
              TextFormField(
                controller: formControllerWebId,
                decoration: InputDecoration(
                  labelText: 'Individual\'s webID',
                  // Once user has started entering text, use formfield
                  // error message to advise user how to specify
                  // valid webId
                  errorText: _textEntered ? _helpText : null,
                ),
                onFieldSubmitted: (value) {},
                onChanged: (value) => setState(() {
                  // User has started entering text
                  _textEntered = true;
                  // Filter suggestions
                  filterSuggestions(value);
                  // Notify parent of current raw text
                  widget.onTextChanged?.call(value);
                }),
              ),
              smallGapV,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (webIdList.isNotEmpty) ...[
                    if (suggestionList.isNotEmpty ||
                        formControllerWebId.text.isNotEmpty) ...[
                      // 20250729 jm: Wrap ListView() in fixed SizeBox() to avoid render problems in AlertDialog()
                      boxedSuggestionList(context, suggestionList),
                    ] else ...[
                      boxedSuggestionList(context, webIdList),
                    ],
                  ],
                  TextButton(
                    onPressed: () {
                      // Wipe the WebID field and any cached state so the
                      // user can start over. The actual recipient is
                      // confirmed later when Grant Permission is pressed.
                      setState(() {
                        formControllerWebId.clear();
                        _textEntered = false;
                        suggestionList.clear();
                      });
                      widget.onTextChanged?.call('');
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

  Flexible boxedSuggestionList(BuildContext context, List<String> idList) {
    return Flexible(
      child: SizedBox(
        height: WebIdLayout.dropdownHeight,
        child: ListView.builder(
          padding: WebIdLayout.listPadding,
          itemCount: idList.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: WebIdLayout.dropdownElevation,
              child: ListTile(
                title: Text(idList[index]),
                focusColor: DropdownColors.primary,
                hoverColor: DropdownColors.accent,
                splashColor: DropdownColors.primary,
                onTap: () {
                  setState(() {
                    // User has started entering text
                    _textEntered = true;
                    formControllerWebId.text = idList[index];
                  });
                  // Notify parent so it picks up the chosen value.
                  widget.onTextChanged?.call(idList[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
