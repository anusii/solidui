/// Notification Centre - Lists and manages POD notifications.
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

// ignore_for_file: use_build_context_synchronously

library;

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidpod/solidpod.dart';

part 'solid_notification_centre_helpers.dart';
part 'solid_notification_centre_ui.dart';

/// SharedPreferences key for tracking which notification ids the user
/// has already viewed.

const String solidReadNotificationsKey = 'solid_read_notification_ids';

/// SharedPreferences key for tracking which notification ids the user
/// has chosen to delete from the centre. The underlying file in the
/// sender's POD is left untouched (the recipient holds no write
/// permission on it) so "delete" is a purely local hide. The storage
/// key string is kept as the legacy "dismissed" value so users who had
/// already hidden notifications under the previous wording do not see
/// them resurface after the rename.

const String _solidDeletedNotificationsKey = 'solid_dismissed_notification_ids';

/// Page-size options for the notification list pagination.

const List<int> _pageSizeOptions = [10, 20, 50, 100];

/// Available sort modes for the notification list.

enum _SortMode {
  timeDesc('Newest first'),
  timeAsc('Oldest first'),
  senderAsc('Sender A–Z'),
  senderDesc('Sender Z–A');

  const _SortMode(this.label);
  final String label;
}

/// Full-screen notification centre that lists every notification the
/// user has received across all sender pairs, fetched via the per-pair
/// pull model in `solidpod`. Notifications are displayed as cards with
/// pagination and sorting controls.

class SolidNotificationCentre extends StatefulWidget {
  const SolidNotificationCentre({super.key});

  @override
  State<SolidNotificationCentre> createState() =>
      _SolidNotificationCentreState();
}

class _SolidNotificationCentreState extends State<SolidNotificationCentre> {
  List<PodNotification> _notifications = [];
  Set<String> _readIds = {};
  Set<String> _deletedIds = {};
  bool _isLoading = true;
  String? _error;

  int _itemsPerPage = 10;
  int _currentPage = 0;

  _SortMode _sortMode = _SortMode.timeDesc;

  final ScrollController _scrollController = ScrollController();

  /// Public wrapper around [setState].
  /// [setState] is `@protected` and cannot be called directly from extensions.

  // ignore: use_setters_to_change_properties
  void updateState(VoidCallback fn) => setState(fn);

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Read/deleted-state persistence.

  Future<void> _loadLocalState() async {
    final prefs = await SharedPreferences.getInstance();
    _readIds = (prefs.getStringList(solidReadNotificationsKey) ?? []).toSet();
    _deletedIds =
        (prefs.getStringList(_solidDeletedNotificationsKey) ?? []).toSet();
  }

  Future<void> _markAsRead(String id) async {
    if (_readIds.contains(id)) return;
    _readIds.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(solidReadNotificationsKey, _readIds.toList());
    if (mounted) setState(() {});
  }

  /// Record [id] as deleted in the local preferences store. This is
  /// only a hide because the underlying notification still lives in the
  /// sender's outbox file (the recipient has Read-only access on it).

  Future<void> _markAsDeleted(String id) async {
    _deletedIds.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _solidDeletedNotificationsKey,
      _deletedIds.toList(),
    );
  }

  // Data loading.

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _loadLocalState();

      if (!await isUserLoggedIn()) {
        throw Exception('Not logged in');
      }

      final fetched = await fetchNotifications();

      // De-duplicate by id (the per-pair file can contain repeats only
      // if a buggy sender ever wrote the same id twice; keep the last).

      final byId = <String, PodNotification>{};
      for (final n in fetched) {
        byId[n.id] = n;
      }

      // Filter out anything the user has deleted locally.

      final filtered =
          byId.values.where((n) => !_deletedIds.contains(n.id)).toList();

      setState(() {
        _notifications = filtered;
        _currentPage = 0;
        _isLoading = false;
      });
    } on Object catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Sorting.

  List<PodNotification> get _sortedNotifications {
    final sorted = List<PodNotification>.from(_notifications);
    switch (_sortMode) {
      case _SortMode.timeDesc:
        sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      case _SortMode.timeAsc:
        sorted.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      case _SortMode.senderAsc:
        sorted.sort(
          (a, b) => extractName(
            a.senderWebId,
          ).toLowerCase().compareTo(extractName(b.senderWebId).toLowerCase()),
        );
      case _SortMode.senderDesc:
        sorted.sort(
          (a, b) => extractName(
            b.senderWebId,
          ).toLowerCase().compareTo(extractName(a.senderWebId).toLowerCase()),
        );
    }
    return sorted;
  }

  // Pagination helpers.

  int get _totalPages =>
      (_sortedNotifications.length / _itemsPerPage).ceil().clamp(1, 1 << 30);

  List<PodNotification> get _pageItems {
    final sorted = _sortedNotifications;
    final start = _currentPage * _itemsPerPage;
    if (start >= sorted.length) return [];
    final end = (start + _itemsPerPage).clamp(0, sorted.length);
    return sorted.sublist(start, end);
  }

  void _clampCurrentPage() {
    if (_currentPage >= _totalPages) {
      _currentPage = (_totalPages - 1).clamp(0, _totalPages);
    }
  }

  // Build.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Centre'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
            tooltip: 'Refresh notifications',
          ),
        ],
      ),
      body: buildBody(),
    );
  }
}
