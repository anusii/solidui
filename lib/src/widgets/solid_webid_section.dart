/// Read-only WebID viewer and Pod-linking entry point for the Settings
/// dialog.
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

import 'package:solidpod/solidpod.dart' show getWebId;

import 'package:solidui/src/services/solid_webid_service.dart';
import 'package:solidui/src/widgets/solid_link_pod_dialog.dart';

/// Shows the logged-in user's WebID and the raw turtle content of their
/// WebID document, with a "Link another Pod" action that opens
/// [SolidLinkPodDialog] to add proof-of-ownership and OIDC-issuer triples
/// needed to register the WebID as a login on another Solid Pod server.

class SolidWebIdSection extends StatefulWidget {
  const SolidWebIdSection({super.key});

  @override
  State<SolidWebIdSection> createState() => _SolidWebIdSectionState();
}

class _SolidWebIdSectionState extends State<SolidWebIdSection> {
  bool _loading = true;
  String? _webId;
  String? _turtle;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final webId = await getWebId();
      final turtle = await SolidWebIdService.instance.fetchWebIdTurtle();
      if (!mounted) return;
      setState(() {
        _webId = webId;
        _turtle = turtle;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load your WebID: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openLinkPodDialog() async {
    await SolidLinkPodDialog.show(context);

    // Refresh so the displayed turtle reflects any triples the dialog added
    // or removed.

    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.badge_outlined,
                size: 18,
                color: theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(
                'Your WebID',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (_webId != null) ...[
            const SizedBox(height: 4),
            Text(
              _webId!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 8),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: theme.colorScheme.error),
            )
          else
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 160),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _turtle ?? '',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _loading ? null : _openLinkPodDialog,
              icon: const Icon(Icons.link, size: 18),
              label: const Text('Link another Pod'),
            ),
          ),
        ],
      ),
    );
  }
}
