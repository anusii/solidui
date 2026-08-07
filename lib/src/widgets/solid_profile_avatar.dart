/// Circular profile avatar widget with optional edit affordance.
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

import 'package:solidui/src/services/solid_profile_notifier.dart';

/// Displays a circular profile avatar sourced from [solidProfileNotifier].
///
/// When [onTap] is provided, the widget becomes tappable (e.g. to open a
/// profile editor). Set [showEditBadge] to overlay a small camera icon.

class SolidProfileAvatar extends StatelessWidget {
  /// Diameter of the avatar circle.

  final double size;

  /// Optional tap callback (typically opens the profile editor).

  final VoidCallback? onTap;

  /// Whether to show a small edit/camera badge on the avatar.

  final bool showEditBadge;

  /// Fallback icon displayed when no avatar image is available.

  final IconData placeholderIcon;

  const SolidProfileAvatar({
    super.key,
    this.size = 40,
    this.onTap,
    this.showEditBadge = false,
    this.placeholderIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: solidProfileNotifier,
      builder: (context, _) {
        final bytes = solidProfileNotifier.avatarBytes;
        return _buildAvatar(context, bytes);
      },
    );
  }

  Widget _buildAvatar(BuildContext context, Uint8List? bytes) {
    final theme = Theme.of(context);
    final hasImage = bytes != null && bytes.isNotEmpty;

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primaryContainer,
        image: hasImage
            ? DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover)
            : null,
      ),
      child: hasImage
          ? null
          : Icon(
              placeholderIcon,
              size: size * 0.55,
              color: theme.colorScheme.onPrimaryContainer,
            ),
    );

    if (showEditBadge) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.camera_alt,
                size: size * 0.22,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }
}
