/// The default AppBar button order the settings dialogue resets to.
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

import 'package:solidui/src/widgets/solid_preferences_models.dart';

/// [actions] back at their defaults: all visible, none in the overflow menu,
/// and in the default order.

List<SolidAppBarActionItem> solidDefaultAppBarActions(
  List<SolidAppBarActionItem> actions,
) {
  final reset = <SolidAppBarActionItem>[];

  for (final action in actions) {
    reset.add(
      action.copyWith(
        showInOverflow: false,
        isVisible: true,
        order: solidDefaultOrderForAction(action.id),
      ),
    );
  }

  // Sort by the default order.

  reset.sort((a, b) => a.order.compareTo(b.order));

  // Reassign sequential order values after sorting.

  for (int i = 0; i < reset.length; i++) {
    reset[i] = reset[i].copyWith(order: i);
  }

  return reset;
}

/// Returns the default order index for an action based on its ID.
/// This mirrors the initialIndex values in SolidAppBarActionsManager.

int solidDefaultOrderForAction(String actionId) {
  // Theme toggle: 0.

  if (actionId == SolidAppBarActionIds.themeToggle) return 0;

  // Custom actions: 100+.

  if (actionId.startsWith('action_')) {
    final index = int.tryParse(actionId.replaceFirst('action_', '')) ?? 0;

    return 100 + index;
  }

  // Logout: 800 — second-to-last, just left of About.

  if (actionId == SolidAppBarActionIds.logout) return 800;

  // About: 900.

  if (actionId == SolidAppBarActionIds.about) return 900;

  // Other items (overflow items): 200+.

  return 200;
}
