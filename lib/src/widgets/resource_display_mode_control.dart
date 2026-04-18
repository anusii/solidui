/// A control widget for switching between resource display modes.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
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
/// Authors: Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:solidui/src/constants/ui_colors.dart';

/// A widget for switching between resource display modes.
///
/// When [titleData] is provided, shows a three-option radio group:
/// 'File Url', 'Filename', and 'File Title'.
/// Otherwise shows a 'Show Full Path' switch.
///
/// Parameters:
/// - [showFullPath] - Whether full paths are currently shown.
/// - [showTitle] - Whether file titles are currently shown.
/// - [titleData] - Optional map from resource key to display title. When
///   provided, a radio group is shown instead of a switch.
/// - [onShowFullPathChanged] - Called when the full-path setting changes.
/// - [onShowTitleChanged] - Called when the show-title setting changes.

class ResourceDisplayModeControl extends StatelessWidget {
  const ResourceDisplayModeControl({
    super.key,
    required this.showFullPath,
    required this.showTitle,
    this.titleData,
    this.onShowFullPathChanged,
    this.onShowTitleChanged,
  });

  final bool showFullPath;
  final bool showTitle;
  final Map<String, String>? titleData;
  final ValueChanged<bool>? onShowFullPathChanged;
  final ValueChanged<bool>? onShowTitleChanged;

  String get _displayMode {
    if (showTitle) return 'File Title';
    if (showFullPath) return 'File Url';
    return 'Filename';
  }

  void _onDisplayModeSelected(String mode) {
    switch (mode) {
      case 'File Url':
        onShowFullPathChanged?.call(true);
        onShowTitleChanged?.call(false);
      case 'Filename':
        onShowFullPathChanged?.call(false);
        onShowTitleChanged?.call(false);
      case 'File Title':
        onShowTitleChanged?.call(true);
    }
  }

  Widget _buildRadioGroup(BuildContext context) {
    const modes = ['File Url', 'Filename', 'File Title'];
    final activeColor = Theme.of(context).switchTheme.thumbColor?.resolve(
          {WidgetState.selected},
        ) ??
        ActionColors.success;
    return Theme(
      data: Theme.of(context).copyWith(
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected) ? activeColor : null,
          ),
        ),
      ),
      child: RadioGroup<String>(
        groupValue: _displayMode,
        onChanged: (v) {
          if (v != null) _onDisplayModeSelected(v);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in modes) ...[
              Radio<String>(
                value: mode,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              Text(mode, style: const TextStyle(fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (titleData != null) {
      return _buildRadioGroup(context);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        const Text(
          'Show\nFull Path',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end,
        ),
        Switch(
          value: showFullPath,
          activeThumbColor: Theme.of(context).switchTheme.thumbColor?.resolve(
                {WidgetState.selected},
              ) ??
              ActionColors.success,
          onChanged: onShowFullPathChanged,
        ),
      ],
    );
  }
}
