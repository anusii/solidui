/// UI building methods for the Notification Centre.
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

part of 'solid_notification_centre.dart';

/// Extension grouping UI building methods on the notification centre state.

extension _NotificationCentreUI on _SolidNotificationCentreState {
  // Body.

  Widget buildBody() {
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
              updateState(() {
                _sortMode = mode;
                _currentPage = 0;
              });
            },
          ),
          const Spacer(),
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
              updateState(() {
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
                      'From: ${extractName(n.senderWebId)}'
                      '  ·  ${formatRelativeTime(dateTime)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => confirmAndDelete(n),
                    tooltip: 'Delete notification',
                  ),
                  onTap: () => showNotificationDetail(n),
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
            if (priorityIcon(priority) != null)
              Positioned(
                right: -6,
                bottom: -4,
                child: priorityIcon(priority)!,
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
          Text(
            '$rangeStart–$rangeEnd of $totalItems',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.first_page, size: 20),
                onPressed: _currentPage > 0
                    ? () => updateState(() => _currentPage = 0)
                    : null,
                tooltip: 'First page',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: _currentPage > 0
                    ? () => updateState(() => _currentPage--)
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
                    ? () => updateState(() => _currentPage++)
                    : null,
                tooltip: 'Next page',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: const Icon(Icons.last_page, size: 20),
                onPressed: _currentPage < totalPages - 1
                    ? () => updateState(() => _currentPage = totalPages - 1)
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
