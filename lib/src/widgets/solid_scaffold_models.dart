/// Solid Scaffold Models - Simplified scaffold component data models.
///
// Time-stamp: <Monday 2025-08-18 14:30:00 +1000 Tony Chen>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';

/// Simplified menu item configuration.

class SolidMenuItem {
  /// Menu title.

  final String title;

  /// Menu icon.

  final IconData icon;

  /// Optional icon colour.

  final Color? color;

  /// Optional child widget (displayed when menu is selected).

  final Widget? child;

  /// Optional tooltip.

  final String? tooltip;

  /// Optional message dialogue content.

  final String? message;

  /// Optional dialogue title.

  final String? dialogTitle;

  /// Optional tap callback.

  final void Function(BuildContext)? onTap;

  const SolidMenuItem({
    required this.title,
    required this.icon,
    this.color,
    this.child,
    this.tooltip,
    this.message,
    this.dialogTitle,
    this.onTap,
  });
}
