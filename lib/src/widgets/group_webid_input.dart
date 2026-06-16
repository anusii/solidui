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
import 'package:solidpod/solidpod.dart'
    show SharedGroup, whatIsWebID, demoWebID;

import 'package:solidui/solidui.dart'
    show smallGapV, makeSubHeading, GrantPermFormLayout;

/// A [StatefulWidget] dialog for entering a group of WebIDs.
///
/// The widget no longer confirms a selection on its own; the parent form
/// reads the typed values via [onGroupNameChanged] and
/// [onGroupWebIdsChanged] and validates them when the user presses
/// Grant Permission.
///
/// Previously used groups (supplied via [savedGroups]) are listed below the
/// input fields. Tapping one fills the name and WebID fields automatically,
/// and each entry can be removed via [onDeleteGroup].
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

  /// Previously used recipient groups offered to the user for quick reuse.
  final List<SharedGroup> savedGroups;

  /// Optional callback fired when the user removes a saved group from the
  /// list. The parent form is responsible for deleting it from the POD and
  /// refreshing [savedGroups].
  final void Function(SharedGroup)? onDeleteGroup;

  const GroupWebIdTextInput({
    super.key,
    this.onGroupNameChanged,
    this.onGroupWebIdsChanged,
    this.onClearFunction,
    this.savedGroups = const [],
    this.onDeleteGroup,
  });

  @override
  State<GroupWebIdTextInput> createState() => _GroupWebIdTextInputState();
}

class _GroupWebIdTextInputState extends State<GroupWebIdTextInput> {
  /// Text controller for webId list field
  final formControllerGroupWebIds = TextEditingController();

  /// Text controller for group name for webId list

  final formControllerGroupName = TextEditingController();

  /// Focus node for the group name field. Used to pop up the saved-groups
  /// dropdown while the field is focused.

  final _groupNameFocusNode = FocusNode();

  /// Links the dropdown overlay to the group name field so it follows it
  /// when the dialog scrolls or resizes.

  final _layerLink = LayerLink();

  /// Groups taps on the field and its dropdown together so a tap on either
  /// is not treated as a tap "outside" that would dismiss the dropdown.

  final _tapGroupId = Object();

  /// The live dropdown overlay, or null when it is not shown.

  OverlayEntry? _overlayEntry;

  /// Current text in the group name field, used to filter the saved groups.

  String _query = '';

  @override
  void initState() {
    super.initState();
    // Show the dropdown when the field gains focus.
    _groupNameFocusNode.addListener(_onFocusChange);
  }

  // dispose text controller when the widget is unmounted
  @override
  void dispose() {
    _removeOverlay();
    _groupNameFocusNode.removeListener(_onFocusChange);
    _groupNameFocusNode.dispose();
    formControllerGroupWebIds.dispose();
    formControllerGroupName.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GroupWebIdTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.savedGroups, widget.savedGroups)) return;
    // The saved groups changed (e.g. after a deletion). Refresh the dropdown
    // so removed entries disappear and an emptied list closes it. Defer to
    // after this frame because inserting/removing an overlay entry during a
    // build is not allowed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshOverlay();
    });
  }

  /// Saved groups whose name contains the current query (case-insensitive).
  /// When the query is empty every saved group is offered.
  List<SharedGroup> get _filteredGroups {
    if (widget.savedGroups.isEmpty) return const [];
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.savedGroups;
    return widget.savedGroups
        .where((g) => g.name.toLowerCase().contains(q))
        .toList();
  }

  void _onFocusChange() {
    if (_groupNameFocusNode.hasFocus) {
      _showOverlay();
    }
  }

  /// Fill both input fields from a previously saved [group] and notify the
  /// parent form so the typed values are picked up for validation.
  void _applySavedGroup(SharedGroup group) {
    final webIds = group.webIds.join('; ');
    setState(() {
      formControllerGroupName.text = group.name;
      formControllerGroupWebIds.text = webIds;
      _query = group.name;
    });
    widget.onGroupNameChanged?.call(group.name);
    widget.onGroupWebIdsChanged?.call(webIds);
    _removeOverlay();
    _groupNameFocusNode.unfocus();
  }

  /// Insert the dropdown overlay, or rebuild it if already shown. Does
  /// nothing when there are no groups to offer.
  void _showOverlay() {
    if (_filteredGroups.isEmpty) {
      _removeOverlay();
      return;
    }
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Reconcile the dropdown with the latest state: rebuild it when shown,
  /// open it when the field is focused with matches, close it otherwise.
  void _refreshOverlay() {
    if (_overlayEntry != null) {
      if (_filteredGroups.isEmpty) {
        _removeOverlay();
      } else {
        _overlayEntry!.markNeedsBuild();
      }
    } else if (_groupNameFocusNode.hasFocus && _filteredGroups.isNotEmpty) {
      _showOverlay();
    }
  }

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        final groups = _filteredGroups;
        return CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 4),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              // Match the width of the group name field.
              width: _layerLink.leaderSize?.width,
              child: TapRegion(
                groupId: _tapGroupId,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(4),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    // Cap the height so a long history stays scrollable.
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: Scrollbar(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          final memberCount = group.webIds.length;
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.group_outlined),
                            title: Text(group.name),
                            subtitle: Text(
                              '$memberCount '
                              '${memberCount == 1 ? 'member' : 'members'}',
                            ),
                            trailing: MarkdownTooltip(
                              message: 'Remove this group from the saved list.',
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    widget.onDeleteGroup?.call(group),
                              ),
                            ),
                            onTap: () => _applySavedGroup(group),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
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
              // Group name. Should be a single string. The saved-groups
              // dropdown is anchored to this field and pops up while typing.
              CompositedTransformTarget(
                link: _layerLink,
                child: TapRegion(
                  groupId: _tapGroupId,
                  onTapOutside: (_) {
                    // A tap elsewhere (outside both field and dropdown)
                    // dismisses the dropdown.
                    _removeOverlay();
                    _groupNameFocusNode.unfocus();
                  },
                  child: TextFormField(
                    controller: formControllerGroupName,
                    focusNode: _groupNameFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Group name',
                      hintText:
                          'Multiple words will be combined using the symbol -',
                    ),
                    onChanged: (value) {
                      setState(() => _query = value);
                      widget.onGroupNameChanged?.call(value);
                      _refreshOverlay();
                    },
                  ),
                ),
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
                        _query = '';
                      });
                      widget.onGroupNameChanged?.call('');
                      widget.onGroupWebIdsChanged?.call('');
                      widget.onClearFunction?.call();
                      _removeOverlay();
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
