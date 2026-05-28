/// Avatar widget that visually distinguishes between POD owners by showing
/// (in priority order) their profile picture, name initials, WebID initials,
/// or a placeholder icon.
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
/// Authors: Tony Chen

library;

import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart' show getWebId;

import 'package:solidui/src/services/solid_owner_profile_service.dart';
import 'package:solidui/src/services/solid_profile_notifier.dart';

/// Displays a small circular avatar identifying the owner of a resource
/// (typically the leading icon of a list item).
///
/// The widget resolves what to show in the following priority order:
///   1. The owner's profile picture, if one is available.
///   2. Initials derived from the owner's display name (first + last
///      word initials, or first two letters of a single-word name).
///   3. Initials taken from the first two letters of the WebID's username.
///   4. [placeholderIcon] (defaults to a generic document icon) when none of
///      the above resolve.
///
/// When [webId] matches the currently authenticated user the widget listens
/// to [solidProfileNotifier] so local edits (e.g. uploading a new avatar)
/// update the list view immediately. For other WebIDs the data is fetched
/// once via [SolidOwnerProfileService] and cached for the lifetime of the
/// process.

class SolidOwnerAvatar extends StatefulWidget {
  /// The WebID of the resource owner whose avatar should be displayed.
  /// When `null` or empty the widget short-circuits to [placeholderIcon].

  final String? webId;

  /// Diameter of the avatar circle.

  final double size;

  /// Icon used when no avatar or initials can be derived. Defaults to a
  /// document glyph so the widget remains a drop-in replacement for the
  /// previous static note icon used by NotePod's list views.

  final IconData placeholderIcon;

  const SolidOwnerAvatar({
    super.key,
    required this.webId,
    this.size = 40,
    this.placeholderIcon = Icons.edit_document,
  });

  @override
  State<SolidOwnerAvatar> createState() => _SolidOwnerAvatarState();
}

class _SolidOwnerAvatarState extends State<SolidOwnerAvatar> {
  // The WebID of the currently authenticated user, resolved once when this
  // widget is first built. Used to decide whether to listen to the local
  // [solidProfileNotifier] or fetch a remote owner profile.

  String? _currentWebId;
  bool _currentWebIdResolved = false;

  // Remote owner profile, populated only when [widget.webId] does not match
  // the current user.

  SolidOwnerProfile? _remoteProfile;

  @override
  void initState() {
    super.initState();
    _resolveOwner();
  }

  @override
  void didUpdateWidget(covariant SolidOwnerAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.webId != widget.webId) {
      _remoteProfile = null;
      _resolveOwner();
    }
  }

  // Resolution.
  //
  // Determine whether the owner WebID is the current user (so we can use
  // the live local profile notifier) or some other user (so we kick off a
  // one-shot fetch via [SolidOwnerProfileService]).

  Future<void> _resolveOwner() async {
    final ownerWebId = widget.webId?.trim() ?? '';
    if (ownerWebId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _currentWebIdResolved = true;
        _remoteProfile = SolidOwnerProfile.empty;
      });
      return;
    }

    if (!_currentWebIdResolved) {
      try {
        _currentWebId = await getWebId();
      } catch (_) {
        _currentWebId = null;
      }
      if (!mounted) return;
      setState(() => _currentWebIdResolved = true);
    }

    // Owner is the current user: no remote fetch needed; we will read from
    // [solidProfileNotifier] inside [build].

    if (_currentWebId != null && _currentWebId == ownerWebId) {
      return;
    }

    // Owner is a different user: serve from cache when possible, otherwise
    // kick off a single fetch via the shared service.

    final cached = SolidOwnerProfileService.instance.cachedProfile(ownerWebId);
    if (cached != null) {
      if (!mounted) return;
      setState(() => _remoteProfile = cached);
      return;
    }

    try {
      final profile =
          await SolidOwnerProfileService.instance.fetchProfile(ownerWebId);
      if (!mounted || widget.webId != ownerWebId) return;
      setState(() => _remoteProfile = profile);
    } catch (_) {
      if (!mounted || widget.webId != ownerWebId) return;
      setState(() => _remoteProfile = SolidOwnerProfile.empty);
    }
  }

  // Build.

  @override
  Widget build(BuildContext context) {
    final ownerWebId = widget.webId?.trim();
    if (ownerWebId == null || ownerWebId.isEmpty) {
      return _buildPlaceholder(context);
    }

    final isCurrentUser = _currentWebIdResolved && _currentWebId == ownerWebId;
    if (isCurrentUser) {
      return ListenableBuilder(
        listenable: solidProfileNotifier,
        builder: (context, _) {
          return _buildContent(
            context,
            avatarBytes: solidProfileNotifier.avatarBytes,
            displayName: solidProfileNotifier.displayName,
            webId: ownerWebId,
          );
        },
      );
    }

    // External owner: render from the resolved remote profile (possibly the
    // shared service cache if a sibling widget has already fetched it).

    final cached =
        SolidOwnerProfileService.instance.cachedProfile(ownerWebId) ??
            _remoteProfile;
    return _buildContent(
      context,
      avatarBytes: cached?.avatarBytes,
      displayName: cached?.displayName,
      webId: ownerWebId,
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required Uint8List? avatarBytes,
    required String? displayName,
    required String webId,
  }) {
    // Pick a stable accent colour for this owner so that two owners sharing
    // the same initials (or WebID first letters) still appear visually
    // different. The palette is curated for accessibility (WCAG AA contrast
    // and colour-vision-deficiency friendly hues).

    final accent = ownerColourPairFor(webId);

    if (avatarBytes != null && avatarBytes.isNotEmpty) {
      return _buildAvatarImage(context, avatarBytes, accent);
    }
    final initials = computeOwnerInitials(
      displayName: displayName,
      webId: webId,
    );
    if (initials.isNotEmpty) {
      return _buildInitials(context, initials, accent);
    }
    return _buildPlaceholder(context, accent);
  }

  // The colour pair fed into each branch is `null` when no WebID is
  // available, in which case the helpers fall back to the neutral theme
  // colours used before owner-distinguishing colours were introduced.

  Widget _buildAvatarImage(
    BuildContext context,
    Uint8List bytes,
    SolidOwnerColourPair? accent,
  ) {
    final theme = Theme.of(context);
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent?.background ?? theme.colorScheme.primaryContainer,
        image: DecorationImage(
          image: MemoryImage(bytes),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInitials(
    BuildContext context,
    String initials,
    SolidOwnerColourPair? accent,
  ) {
    final theme = Theme.of(context);
    final background = accent?.background ?? theme.colorScheme.primaryContainer;
    final foreground =
        accent?.foreground ?? theme.colorScheme.onPrimaryContainer;
    return Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: foreground,
          fontSize: widget.size * 0.4,
          fontWeight: FontWeight.w600,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildPlaceholder(
    BuildContext context, [
    SolidOwnerColourPair? accent,
  ]) {
    final theme = Theme.of(context);
    final background = accent?.background ?? theme.colorScheme.primaryContainer;
    final foreground =
        accent?.foreground ?? theme.colorScheme.onPrimaryContainer;
    return Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
      ),
      child: Icon(
        widget.placeholderIcon,
        size: widget.size * 0.55,
        color: foreground,
      ),
    );
  }
}
