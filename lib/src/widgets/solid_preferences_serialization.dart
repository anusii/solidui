/// Serialization helpers for SolidPreferencesNotifier.
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

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:solidui/src/widgets/solid_preferences_models.dart';

/// Helper class for serializing and deserializing preferences data.

class SolidPreferencesSerialization {
  /// Converts an AppBarActionItem to JSON.

  static Map<String, dynamic> appBarActionItemToJson(
    SolidAppBarActionItem item,
  ) {
    return {
      'id': item.id,
      'label': item.label,
      'showInOverflow': item.showInOverflow,
      'isVisible': item.isVisible,
      'order': item.order,
    };
  }

  /// Creates an AppBarActionItem from JSON.

  static SolidAppBarActionItem? appBarActionItemFromJson(
    Map<String, dynamic> json,
    List<SolidAppBarActionItem> defaultActions,
  ) {
    final id = json['id'] as String;
    final defaultAction =
        defaultActions.where((action) => action.id == id).firstOrNull;

    if (defaultAction == null) {
      return null;
    }

    return SolidAppBarActionItem(
      id: id,
      label: json['label'] as String? ?? defaultAction.label,
      icon: defaultAction.icon,
      showInOverflow: json['showInOverflow'] as bool? ?? false,
      isVisible: json['isVisible'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
    );
  }

  /// Parses stored actions JSON into a list of action items.

  static List<SolidAppBarActionItem> parseActionsJson(
    String actionsJson,
    List<SolidAppBarActionItem> defaultActions,
  ) {
    try {
      final List<dynamic> actionsList = jsonDecode(actionsJson);
      return actionsList
          .map(
            (json) => appBarActionItemFromJson(
              json as Map<String, dynamic>,
              defaultActions,
            ),
          )
          .whereType<SolidAppBarActionItem>()
          .toList();
    } catch (e) {
      debugPrint('Error parsing stored AppBar actions: $e');
      return [];
    }
  }

  /// Merges restored actions with new actions.

  static List<SolidAppBarActionItem> mergeRestoredActions(
    List<SolidAppBarActionItem> restored,
    List<SolidAppBarActionItem> newActions,
  ) {
    final restoredById = {for (var a in restored) a.id: a};
    final result = <SolidAppBarActionItem>[];

    for (final action in newActions) {
      final restoredAction = restoredById[action.id];
      if (restoredAction != null) {
        result.add(
          action.copyWith(
            showInOverflow: restoredAction.showInOverflow,
            isVisible: restoredAction.isVisible,
            order: restoredAction.order,
          ),
        );
      } else {
        result.add(action);
      }
    }

    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }
}
