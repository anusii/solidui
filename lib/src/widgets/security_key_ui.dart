/// A unified widget for security key prompts and dialogs with WebID displayed prominently.
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
/// Authors: Ashley Tang

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;

import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:solidui/src/constants/ui.dart';
import 'package:solidui/src/widgets/secret_text_field.dart';
import 'package:solidui/src/widgets/security_key_buttons.dart';
import 'package:solidui/src/widgets/security_key_display_mode.dart';
import 'package:solidui/src/widgets/security_key_header.dart';
import 'package:solidui/src/widgets/solid_login_helper.dart';
import 'package:solidui/src/widgets/solid_theme_notifier.dart';

export 'package:solidui/src/widgets/security_key_display_mode.dart';

/// A flexible [StatefulWidget] for security key operations with improved UI and
/// WebID display.

class SecurityKeyUI extends StatefulWidget {
  /// Constructor for the SecurityKeyUI widget.
  ///
  /// For a simple security key prompt:
  /// - Pass a single input field in [inputFields] list
  /// - Provide a title like "Security Key"
  /// - Use [displayMode] = SecurityKeyDisplayMode.fullscreen
  ///
  /// For a security key dialog with multiple fields:
  /// - Pass multiple input fields in [inputFields]
  /// - Set [displayMode] = SecurityKeyDisplayMode.dialog

  const SecurityKeyUI({
    required this.webId,
    required this.title,
    required this.message,
    required this.inputFields,
    required this.formKey,
    required this.submitFunc,
    required this.child,
    this.displayMode = SecurityKeyDisplayMode.fullscreen,
    this.plainTextFieldKeys = const {},
    super.key,
  });

  /// The WebID to display.

  final String? webId;

  /// Title of the UI component.

  final String title;

  /// Message to display.

  final String message;

  /// The input text fields.
  /// For a simple prompt, provide a list with a single field.
  /// For a dialog with multiple inputs, provide multiple fields.

  final List<
      ({
        String fieldKey,
        String fieldLabel,
        String? Function(String?) validateFunc,
      })> inputFields;

  /// Key of the form for data retrieval.

  final GlobalKey<FormBuilderState> formKey;

  /// The submit function.

  final Future<void> Function(Map<String, dynamic> formDataMap) submitFunc;

  /// The child widget (for navigation after cancel).

  final Widget child;

  /// Display mode (fullscreen prompt or embedded dialog component).

  final SecurityKeyDisplayMode displayMode;

  /// Keys of the input fields whose text should be shown as plain text rather
  /// than masked. Fields not listed here default to a masked secret input.

  final Set<String> plainTextFieldKeys;

  @override
  State<SecurityKeyUI> createState() => _SecurityKeyUIState();
}

class _SecurityKeyUIState extends State<SecurityKeyUI> {
  Map<String, bool> _verifiedMap = {};
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    assert(widget.inputFields.isNotEmpty);
    final fieldKeys = {for (final f in widget.inputFields) f.fieldKey};
    assert(fieldKeys.length == widget.inputFields.length);
    _verifiedMap = {for (final k in fieldKeys) k: false};

    // Listen to theme changes to rebuild the UI.

    solidThemeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    solidThemeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  /// Handles theme changes by rebuilding the widget.

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Toggles the theme mode using the app's theme toggle logic.

  void _toggleTheme() => solidThemeNotifier.toggleTheme();

  Future<void> _submit(BuildContext context) async {
    final formData = widget.formKey.currentState?.value as Map<String, dynamic>;

    if (!_canSubmit) {
      return;
    }

    for (final f in widget.inputFields) {
      if (formData[f.fieldKey] == null) {
        debugPrint('${f.fieldKey} is null');
        return;
      }
    }

    try {
      await widget.submitFunc(formData);
    } on Exception catch (e) {
      debugPrint('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create the card content with the form.

    final cardContent = _buildCardContent(context);

    // Return based on display mode.

    if (widget.displayMode == SecurityKeyDisplayMode.fullscreen) {
      return Scaffold(
        backgroundColor: SecurityThemeColors.background(context),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: cardContent,
          ),
        ),
      );
    } else {
      return cardContent;
    }
  }

  /// Builds the card content including header, form fields, and buttons.

  Widget _buildCardContent(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: SecurityLayout.dialogWidth,
          constraints: const BoxConstraints(
            maxWidth: SecurityLayout.maxDialogWidth,
          ),
          decoration: BoxDecoration(
            color: SecurityThemeColors.cardBackground(context),
            borderRadius: BorderRadius.circular(SecurityLayout.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section.

              SecurityKeyHeader(
                title: widget.title,
                webId: widget.webId,
                message: widget.message,
              ),

              // Separator.

              Container(
                height: SecurityLayout.separatorHeight,
                color: SecurityThemeColors.separator(context),
              ),

              // Form with input fields.

              Padding(
                padding: SecurityLayout.formPadding,
                child: _buildForm(),
              ),

              // Buttons.

              Padding(
                padding: SecurityLayout.buttonsPadding,
                child: SecurityKeyButtons(
                  canSubmit: _canSubmit,
                  onSubmit: () async => _submit(context),
                  onCancel: () {
                    if (widget.displayMode == SecurityKeyDisplayMode.dialog) {
                      Navigator.pop(context);
                    } else {
                      pushReplacement(context, widget.child);
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Theme toggle button in the top-right corner.

        Positioned(
          top: 8,
          right: 8,
          child: getThemeToggleTooltip(
            solidThemeNotifier.themeMode,
            onPressed: _toggleTheme,
          ),
        ),
      ],
    );
  }

  /// Builds the form with input fields.

  Widget _buildForm() {
    // Create the input fields.

    final inputFieldWidgets = <Widget>[];

    for (final f in widget.inputFields) {
      inputFieldWidgets.add(
        Padding(
          padding: SecurityLayout.inputFieldSpacing,
          child: StatefulBuilder(
            builder: (context, setState) => SecretTextField(
              fieldKey: f.fieldKey,
              fieldLabel: f.fieldLabel,
              obscure: !widget.plainTextFieldKeys.contains(f.fieldKey),
              validateFunc: (val) {
                final r = f.validateFunc(val);

                setState(() {
                  _verifiedMap[f.fieldKey] = (r == null);
                });

                this.setState(() {
                  _canSubmit = !_verifiedMap.containsValue(false);
                });

                return r;
              },
            ),
          ),
        ),
      );
    }

    return FormBuilder(
      key: widget.formKey,
      onChanged: () {
        // Save input and validate.

        widget.formKey.currentState!.save();
        widget.formKey.currentState!.validate(
          focusOnInvalid: false,
        );

        // Update state.

        setState(() {
          _canSubmit = !_verifiedMap.containsValue(false);
        });
      },
      autovalidateMode: AutovalidateMode.disabled,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) async {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            await _submit(context);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: inputFieldWidgets,
        ),
      ),
    );
  }
}
