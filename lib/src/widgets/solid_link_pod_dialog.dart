/// A dialog for linking the user's WebID to another Solid Pod server.
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

library;

import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';

import 'package:solidui/src/services/solid_webid_service.dart';
import 'package:solidui/src/utils/snack_bar.dart';

/// Which step of the Pod-linking flow the dialog is currently showing.

enum _LinkStage {
  /// Collect the target Pod's server URL and registration token, then add
  /// the `solid:oidcIssuerRegistrationToken` proof-of-ownership triple.

  addToken,

  /// A registration token is already present on the WebID (just added, or
  /// found on reopen) — collect/confirm the Pod URL and finish the link by
  /// removing the token and adding the `solid:oidcIssuer` triple.

  finish,
}

/// Guides the user through linking their WebID to another Solid Pod server:
///
/// 1. **Add Token** — writes the `oidcIssuerRegistrationToken` triple the
///    other Pod's account page asked for, so the user can go verify it
///    there.
/// 2. **Finish Linking** — once verified externally, removes the token
///    triple and adds a `solid:oidcIssuer` triple pointing at that Pod, so
///    Solid-OIDC-aware apps can discover it from the WebID.
///
/// Reopening the dialog re-detects a pending token already on the WebID and
/// jumps straight to the finish step.

class SolidLinkPodDialog extends StatefulWidget {
  const SolidLinkPodDialog({super.key});

  /// Opens the dialog.

  static Future<void> show(BuildContext context) => showDialog<void>(
        context: context,
        builder: (_) => const SolidLinkPodDialog(),
      );

  @override
  State<SolidLinkPodDialog> createState() => _SolidLinkPodDialogState();
}

class _SolidLinkPodDialogState extends State<SolidLinkPodDialog> {
  static const _podUrlField = 'pod_url';
  static const _tokenField = 'registration_token';

  final _formKey = GlobalKey<FormBuilderState>();

  bool _initialising = true;
  bool _busy = false;
  String? _message;
  bool _messageIsError = false;

  _LinkStage _stage = _LinkStage.addToken;
  String? _podUrl;

  @override
  void initState() {
    super.initState();
    _detectStage();
  }

  Future<void> _detectStage() async {
    try {
      final turtle = await SolidWebIdService.instance.fetchWebIdTurtle();
      final pending =
          SolidWebIdService.instance.findPendingRegistrationToken(turtle);
      if (mounted && pending != null) {
        setState(() => _stage = _LinkStage.finish);
      }
    } catch (_) {
      // Fall back to the add-token stage; the form itself will surface any
      // real error on submit.
    } finally {
      if (mounted) setState(() => _initialising = false);
    }
  }

  void _setMessage(String message, {bool error = false}) {
    if (!mounted) return;
    setState(() {
      _message = message;
      _messageIsError = error;
    });
  }

  // Stage 1: add the registration token proving WebID ownership.

  Future<void> _handleAddToken() async {
    final valid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!valid) return;

    final values = _formKey.currentState!.value;
    final podUrl = values[_podUrlField].toString().trim();
    final token = values[_tokenField].toString().trim();

    setState(() {
      _busy = true;
      _message = null;
    });

    try {
      await SolidWebIdService.instance.addRegistrationToken(token);
      setState(() {
        _podUrl = podUrl;
        _stage = _LinkStage.finish;
      });
      _setMessage(
        'Verification token added. Now go back to "$podUrl" and click '
        '"Link WebID" again there to verify. Once verified, click '
        '"Finish Linking" below.',
      );
    } on Object catch (e) {
      _setMessage('Failed to add the verification token: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // Stage 2: remove the token and register the Pod as an OIDC issuer.

  Future<void> _handleFinishLinking() async {
    final podUrl = _podUrl ?? _formKey.currentState?.value[_podUrlField];
    if (podUrl == null || podUrl.toString().trim().isEmpty) {
      final valid = _formKey.currentState?.saveAndValidate() ?? false;
      if (!valid) return;
    }
    final resolvedPodUrl =
        (_podUrl ?? _formKey.currentState!.value[_podUrlField].toString())
            .trim();

    setState(() {
      _busy = true;
      _message = null;
    });

    try {
      await SolidWebIdService.instance.completeLink(resolvedPodUrl);
      if (mounted) {
        Navigator.of(context).pop();
        showSnackBar(
          context,
          'Linked your WebID to "$resolvedPodUrl".',
          Colors.green,
        );
      }
    } on Object catch (e) {
      _setMessage('Failed to finish linking: $e', error: true);
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.link),
          SizedBox(width: 12),
          Text('Link another Pod'),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: _initialising
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              : FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _stage == _LinkStage.addToken
                            ? 'Enter the Pod server you want to link and the '
                                'verification token it gave you. This adds a '
                                'temporary triple to your WebID proving you '
                                'own it.'
                            : 'Enter the Pod server you are linking (if not '
                                'already filled in). This removes the '
                                'temporary verification token and registers '
                                'the Pod server as a login issuer on your WebID.',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      const Gap(16),
                      if (_message != null) ...[
                        _MessageBanner(
                          message: _message!,
                          isError: _messageIsError,
                          colorScheme: cs,
                        ),
                        const Gap(12),
                      ],
                      FormBuilderTextField(
                        name: _podUrlField,
                        initialValue: _podUrl,
                        enabled: !_busy,
                        decoration: const InputDecoration(
                          labelText: 'Pod Server URL',
                          hintText: 'https://pods.example.org',
                          border: OutlineInputBorder(),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'Please enter the Pod server URL.',
                          ),
                          FormBuilderValidators.url(
                            errorText: 'Please enter a valid URL.',
                          ),
                        ]),
                      ),
                      if (_stage == _LinkStage.addToken) ...[
                        const Gap(12),
                        FormBuilderTextField(
                          name: _tokenField,
                          enabled: !_busy,
                          decoration: const InputDecoration(
                            labelText: 'Registration Token',
                            border: OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.required(
                            errorText: 'Please enter the registration token.',
                          ),
                        ),
                      ],
                      if (_busy) ...[
                        const Gap(20),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    ],
                  ),
                ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (!_initialising)
          FilledButton(
            onPressed: _busy
                ? null
                : (_stage == _LinkStage.addToken
                    ? _handleAddToken
                    : _handleFinishLinking),
            child: Text(
              _stage == _LinkStage.addToken ? 'Add Token' : 'Finish Linking',
            ),
          ),
      ],
    );
  }
}

// A compact status banner mirroring solid_backup_dialog.dart's message
// style.

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.message,
    required this.isError,
    required this.colorScheme,
  });

  final String message;
  final bool isError;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final background =
        isError ? colorScheme.errorContainer : colorScheme.secondaryContainer;
    final foreground = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onSecondaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: 20,
            color: foreground,
          ),
          const Gap(8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
