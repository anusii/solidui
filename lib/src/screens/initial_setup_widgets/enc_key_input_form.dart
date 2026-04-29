/// Contains functions for generating bodies of different ttl files.
///
// Time-stamp: <Thursday 2026-01-22 11:22:23 +1100 Graham Williams>
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
/// Authors: Anushka Vidanage, Kevin Wang

library;

import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:markdown_tooltip/markdown_tooltip.dart';

import 'package:solidui/src/constants/initial_setup.dart';

/// EncKeyInputForm is a [StatefulWidget] that represents the form for entering
/// the encryption key.

class EncKeyInputForm extends StatefulWidget {
  /// Initialising the [StatefulWidget] with the [formKey] and optional
  /// [onSubmit] callback.

  const EncKeyInputForm({
    required this.formKey,
    this.onSubmit,
    this.requireRetype = true,
    super.key,
  });

  /// The key for the form.

  final GlobalKey<FormBuilderState> formKey;

  /// Optional callback triggered when user presses Enter to submit.

  final VoidCallback? onSubmit;

  /// Whether the user must retype their security key in a second field.
  ///
  /// Retype protection is necessary when the user is choosing a new key
  /// (first-time POD setup) so a typo does not lock them out of their
  /// data. It is redundant when the user is simply supplying an
  /// existing key to authorise an update, so set this to `false` in
  /// that case.

  final bool requireRetype;

  @override
  // ignore: library_private_types_in_public_api
  _EncKeyInputFormState createState() => _EncKeyInputFormState();
}

class _EncKeyInputFormState extends State<EncKeyInputForm> {
  bool _showSecurityKey = false;
  bool _showRetypedSecurityKey = false;

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: widget.formKey,
      onChanged: () {
        widget.formKey.currentState!.save();
      },
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 10),
          FractionallySizedBox(
            widthFactor: 0.9,
            alignment: Alignment.center,
            child: MarkdownTooltip(
              message: securityKeyTooltip,
              child: FormBuilderTextField(
                name: securityKeyStr,
                obscureText: !_showSecurityKey,
                autocorrect: false,
                autofocus: true,

                // When retyping is not required this is the last field in
                // the form, so pressing Enter should submit rather than
                // move focus to a non-existent retype field.

                textInputAction: widget.requireRetype
                    ? TextInputAction.next
                    : TextInputAction.done,
                onSubmitted: widget.requireRetype
                    ? null
                    : (_) => widget.onSubmit?.call(),
                decoration: InputDecoration(
                  labelText: 'SECURITY KEY',
                  labelStyle: const TextStyle(
                    color: Colors.blue,
                    letterSpacing: 1.5,
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                  ),
                  suffixIcon: FocusTraversalOrder(
                    order: const NumericFocusOrder(5),
                    child: IconButton(
                      icon: Icon(
                        _showSecurityKey
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _showSecurityKey = !_showSecurityKey;
                        });
                      },
                    ),
                  ),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
            ),
          ),
          if (widget.requireRetype) ...[
            const SizedBox(height: 16),
            FractionallySizedBox(
              widthFactor: 0.9,
              alignment: Alignment.center,
              child: MarkdownTooltip(
                message: securityKeyRetypeTooltip,
                child: FormBuilderTextField(
                  name: securityKeyStrReType,
                  obscureText: !_showRetypedSecurityKey,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => widget.onSubmit?.call(),
                  decoration: InputDecoration(
                    labelText: 'RETYPE SECURITY KEY',
                    labelStyle: const TextStyle(
                      color: Colors.blue,
                      letterSpacing: 1.5,
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    ),
                    suffixIcon: FocusTraversalOrder(
                      order: const NumericFocusOrder(6),
                      child: IconButton(
                        icon: Icon(
                          _showRetypedSecurityKey
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _showRetypedSecurityKey = !_showRetypedSecurityKey;
                          });
                        },
                      ),
                    ),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    (val) {
                      if (val !=
                          widget.formKey.currentState!.fields[securityKeyStr]
                              ?.value) {
                        return 'Security keys do not match';
                      }
                      return null;
                    },
                  ]),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
