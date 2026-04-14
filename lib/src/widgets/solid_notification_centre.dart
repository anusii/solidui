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

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidpod/solidpod.dart';

part 'solid_notification_centre_helpers.dart';
part 'solid_notification_centre_ui.dart';

/// SharedPreferences key for storing read notification timestamps.

const String solidReadNotificationsKey = 'solid_read_notification_timestamps';

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

/// Full-screen notification centre that lists all notifications stored in the
/// user's POD notification folder. Displays notifications as cards with
/// pagination and sorting controls.

class SolidNotificationCentre extends StatefulWidget {
  const SolidNotificationCentre({super.key});

  @override
  State<SolidNotificationCentre> createState() =>
      _SolidNotificationCentreState();
}

class _SolidNotificationCentreState extends State<SolidNotificationCentre> {
  List<PodNotification> _notifications = [];
  Set<int> _readTimestamps = {};
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

  // Read-state persistence.

  Future<void> _loadReadState() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(solidReadNotificationsKey) ?? [];
    _readTimestamps =
        stored.map((s) => int.tryParse(s)).whereType<int>().toSet();
  }

  Future<void> _markAsRead(int timestamp) async {
    _readTimestamps.add(timestamp);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      solidReadNotificationsKey,
      _readTimestamps.map((t) => t.toString()).toList(),
    );
    if (mounted) setState(() {});
  }

  // Data loading.

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _loadReadState();

      if (!await isUserLoggedIn()) {
        throw Exception('Not logged in');
      }

      final notifDirPath = [appDirName, notificationDir].join('/');
      final dirUrl = await getDirUrl(notifDirPath);

      final status = await checkResourceStatus(dirUrl, isFile: false);
      if (status != ResourceStatus.exist) {
        setState(() {
          _notifications = [];
          _isLoading = false;
        });
        return;
      }

      final (:subDirs, :files) = await getResourcesInContainer(dirUrl);

      final notifications = <PodNotification>[];
      for (final fileName in files) {
        if (!fileName.endsWith('.json')) continue;
        try {
          final fileUrl = '$dirUrl$fileName';
          final bytes = await getResource(fileUrl);
          final content = utf8.decode(bytes);
          final json = jsonDecode(content) as Map<String, dynamic>;
          notifications.add(PodNotification.fromJson(json));
        } on Object catch (e) {
          debugPrint('[NOTIF] Failed to parse $fileName: $e');
        }
      }

      setState(() {
        _notifications = notifications;
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
          (a, b) => extractName(a.senderWebId).toLowerCase().compareTo(
                extractName(b.senderWebId).toLowerCase(),
              ),
        );
      case _SortMode.senderDesc:
        sorted.sort(
          (a, b) => extractName(b.senderWebId).toLowerCase().compareTo(
                extractName(a.senderWebId).toLowerCase(),
              ),
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
