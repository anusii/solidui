/// The Window Size section of the settings dialogue.
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
/// Authors: Graham Williams

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';

import 'package:solidui/src/utils/solid_window_size.dart';

/// Set the size of the desktop window, and choose whether the size the user
/// leaves it at is remembered for next time.
///
/// The enclosing dialogue drives this through a [GlobalKey] on its state:
/// [SolidSettingsWindowSizeSectionState.save] on Save, and
/// [SolidSettingsWindowSizeSectionState.restoreDefault] on Default.

class SolidSettingsWindowSizeSection extends StatefulWidget {
  const SolidSettingsWindowSizeSection({super.key});

  @override
  State<SolidSettingsWindowSizeSection> createState() =>
      SolidSettingsWindowSizeSectionState();
}

class SolidSettingsWindowSizeSectionState
    extends State<SolidSettingsWindowSizeSection> {
  final TextEditingController _width = TextEditingController();
  final TextEditingController _height = TextEditingController();

  bool _remember = true;

  String? _widthError;
  String? _heightError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _width.dispose();
    _height.dispose();
    super.dispose();
  }

  /// Fill the fields from the remembered size, falling back to the size the
  /// window is at now so the fields always show something to edit.

  Future<void> _load() async {
    final size =
        await SolidWindowSize.saved() ?? await SolidWindowSize.current();
    final remember = await SolidWindowSize.remembering();

    if (!mounted) return;

    setState(() {
      if (size != null) {
        _width.text = size.width.toStringAsFixed(0);
        _height.text = size.height.toStringAsFixed(0);
      }
      _remember = remember;
    });
  }

  /// Apply the entered size and save the remembering choice.
  ///
  /// Returns false when either field cannot be used, having marked it, so
  /// the dialogue can stay open on the mistake rather than discarding it.

  Future<bool> save() async {
    final double? width = double.tryParse(_width.text.trim());
    final double? height = double.tryParse(_height.text.trim());

    setState(() {
      _widthError = _errorFor(width);
      _heightError = _errorFor(height);
    });

    if (_widthError != null || _heightError != null) return false;

    await SolidWindowSize.setRemembering(_remember);

    return SolidWindowSize.resize(Size(width!, height!));
  }

  /// Forget the remembered size, so the next start opens at the app's own
  /// default, and turn remembering back on.

  Future<void> restoreDefault() async {
    await SolidWindowSize.forget();
    await SolidWindowSize.setRemembering(true);

    if (!mounted) return;

    setState(() {
      _remember = true;
      _widthError = null;
      _heightError = null;
    });
  }

  String? _errorFor(double? value) {
    if (value == null) return 'A number is needed';
    if (value < SolidWindowSize.minimumDimension) {
      return 'At least ${SolidWindowSize.minimumDimension.toStringAsFixed(0)}';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The size of the app window on the desktop, in pixels.',
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _field('Width', _width, _widthError)),
              const SizedBox(width: 16),
              Expanded(child: _field('Height', _height, _heightError)),
            ],
          ),
          const SizedBox(height: 8),
          MarkdownTooltip(
            message: '''

            **Remember the size**

            When on, the size you leave the window at is remembered and the
            app opens that way next time. When off, the app opens at the size
            set here however you resize it in between.

            ''',
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Remember the size between sessions'),
              value: _remember,
              onChanged: (value) => setState(() => _remember = value),
            ),
          ),
        ],
      );

  Widget _field(
    String label,
    TextEditingController controller,
    String? errorText,
  ) =>
      TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          isDense: true,
          labelText: label,
          errorText: errorText,
        ),
        // Clear the mark as soon as the user starts to fix it.
        onChanged: (_) {
          if (errorText == null) return;
          setState(() {
            if (controller == _width) {
              _widthError = null;
            } else {
              _heightError = null;
            }
          });
        },
      );
}
