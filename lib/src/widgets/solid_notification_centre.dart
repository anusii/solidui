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

import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidpod/solidpod.dart';

/// SharedPreferences key for storing read notification timestamps.

const String solidReadNotificationsKey = 'solid_read_notification_timestamps';

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

  // Pagination state.

  static const List<int> _pageSizeOptions = [10, 20, 50, 100];
  int _itemsPerPage = 10;
  int _currentPage = 0;

  // Sort state — newest first by default.

  _SortMode _sortMode = _SortMode.timeDesc;

  final ScrollController _scrollController = ScrollController();

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

  // Delete.

  Future<void> _confirmAndDelete(PodNotification notification) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text(
          'Are you sure you want to delete this notification?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final notifDirPath = [appDirName, notificationDir].join('/');
      final dirUrl = await getDirUrl(notifDirPath);
      final fileUrl = '$dirUrl${notification.timestamp}.json';

      await deleteFile(fileUrl: fileUrl);

      _readTimestamps.remove(notification.timestamp);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        solidReadNotificationsKey,
        _readTimestamps.map((t) => t.toString()).toList(),
      );

      setState(() {
        _notifications.remove(notification);
        _clampCurrentPage();
      });
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete notification: $e')),
        );
      }
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
          (a, b) => _extractName(a.senderWebId).toLowerCase().compareTo(
                _extractName(b.senderWebId).toLowerCase(),
              ),
        );
      case _SortMode.senderDesc:
        sorted.sort(
          (a, b) => _extractName(b.senderWebId).toLowerCase().compareTo(
                _extractName(a.senderWebId).toLowerCase(),
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

  // Detail dialog.

  void _showNotificationDetail(PodNotification notification) {
    _markAsRead(notification.timestamp);

    final dateTime =
        DateTime.fromMillisecondsSinceEpoch(notification.timestamp);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(notification.title)),
            if (_priorityIcon(notification.priority) != null)
              _priorityIcon(notification.priority)!,
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatDateTime(dateTime),
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              _detailRow('From', notification.senderWebId),
              const SizedBox(height: 8),
              _detailRow('To', notification.recipientWebId),
              if (notification.content != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                SelectableText(notification.content!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(ctx);
              _confirmAndDelete(notification);
            },
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Small helpers.

  Widget? _priorityIcon(int priority) {
    switch (priority) {
      case 2:
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(1),
          child: const Icon(Icons.error, color: Colors.red, size: 20),
        );
      case 0:
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(1),
          child: const Icon(
            Icons.arrow_downward,
            color: Colors.blue,
            size: 20,
          ),
        );
      default:
        return null;
    }
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: SelectableText(value)),
      ],
    );
  }

  String _extractName(String webId) {
    try {
      final uri = Uri.parse(webId);
      return uri.pathSegments.firstWhere(
        (s) =>
            s.isNotEmpty &&
            s != 'profile' &&
            s != 'card' &&
            !s.startsWith('#'),
        orElse: () => webId,
      );
    } catch (_) {
      return webId;
    }
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatDateTime(DateTime dt) {
    final date = '${dt.day}/${dt.month}/${dt.year}';
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$date $hour:$minute:$second';
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Error: $_error', textAlign: TextAlign.center),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            _buildToolbar(),
            Expanded(child: _buildCardList()),
            _buildPaginationBar(),
          ],
        ),
      ),
    );
  }

  // Toolbar.

  Widget _buildToolbar() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Sort dropdown.

          Icon(Icons.sort, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          DropdownButton<_SortMode>(
            value: _sortMode,
            underline: const SizedBox.shrink(),
            isDense: true,
            style: theme.textTheme.bodyMedium,
            items: [
              for (final mode in _SortMode.values)
                DropdownMenuItem(value: mode, child: Text(mode.label)),
            ],
            onChanged: (mode) {
              if (mode == null) return;
              setState(() {
                _sortMode = mode;
                _currentPage = 0;
              });
            },
          ),

          const Spacer(),

          // Items-per-page selector.

          Text(
            'Per page:',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 6),
          DropdownButton<int>(
            value: _itemsPerPage,
            underline: const SizedBox.shrink(),
            isDense: true,
            style: theme.textTheme.bodyMedium,
            items: [
              for (final size in _pageSizeOptions)
                DropdownMenuItem(value: size, child: Text('$size')),
            ],
            onChanged: (size) {
              if (size == null) return;
              setState(() {
                _itemsPerPage = size;
                _currentPage = 0;
              });
            },
          ),
        ],
      ),
    );
  }

  // Card list.

  Widget _buildCardList() {
    final theme = Theme.of(context);
    final items = _pageItems;

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final n = items[index];
            final isRead = _readTimestamps.contains(n.timestamp);
            final dateTime = DateTime.fromMillisecondsSinceEpoch(n.timestamp);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: isRead ? null : theme.colorScheme.onInverseSurface,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: _buildLeadingIcon(isRead, n.priority),
                  title: Text(
                    n.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'From: ${_extractName(n.senderWebId)}'
                      '  ·  ${_formatRelativeTime(dateTime)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmAndDelete(n),
                    tooltip: 'Delete notification',
                  ),
                  onTap: () => _showNotificationDetail(n),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Leading icon with an unread indicator dot and optional priority badge.

  Widget _buildLeadingIcon(bool isRead, int priority) {
    return SizedBox(
      width: 36,
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              isRead ? Icons.mail_outline : Icons.mail,
              size: 28,
            ),
            if (!isRead)
              Positioned(
                right: -3,
                top: -3,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (_priorityIcon(priority) != null)
              Positioned(
                right: -6,
                bottom: -4,
                child: _priorityIcon(priority)!,
              ),
          ],
        ),
      ),
    );
  }

  // Pagination bar.

  Widget _buildPaginationBar() {
    final theme = Theme.of(context);
    final totalPages = _totalPages;
    final totalItems = _sortedNotifications.length;
    final rangeStart = _currentPage * _itemsPerPage + 1;
    final rangeEnd =
        (rangeStart + _itemsPerPage - 1).clamp(rangeStart, totalItems);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Item range summary.

          Text(
            '$rangeStart–$rangeEnd of $totalItems',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),

          // Page navigation.

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.first_page, size: 20),
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage = 0)
                    : null,
                tooltip: 'First page',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
                tooltip: 'Previous page',
                visualDensity: VisualDensity.compact,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Page ${_currentPage + 1} of $totalPages',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: _currentPage < totalPages - 1
                    ? () => setState(() => _currentPage++)
                    : null,
                tooltip: 'Next page',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: const Icon(Icons.last_page, size: 20),
                onPressed: _currentPage < totalPages - 1
                    ? () => setState(() => _currentPage = totalPages - 1)
                    : null,
                tooltip: 'Last page',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
