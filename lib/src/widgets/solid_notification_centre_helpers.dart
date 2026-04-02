/// Dialog and helper methods for the Notification Centre.
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

/// Extension grouping dialog and helper methods on the notification centre
/// state.

extension _NotificationCentreHelpers on _SolidNotificationCentreState {
  // Delete.

  Future<void> confirmAndDelete(PodNotification notification) async {
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

      updateState(() {
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

  // Detail dialog.

  void showNotificationDetail(PodNotification notification) {
    _markAsRead(notification.timestamp);

    final dateTime =
        DateTime.fromMillisecondsSinceEpoch(notification.timestamp);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(notification.title)),
            if (priorityIcon(notification.priority) != null)
              priorityIcon(notification.priority)!,
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatDateTime(dateTime),
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              detailRow('From', notification.senderWebId),
              const SizedBox(height: 8),
              detailRow('To', notification.recipientWebId),
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
              confirmAndDelete(notification);
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

  Widget? priorityIcon(int priority) {
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

  Widget detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: SelectableText(value)),
      ],
    );
  }

  String extractName(String webId) {
    try {
      final uri = Uri.parse(webId);
      return uri.pathSegments.firstWhere(
        (s) =>
            s.isNotEmpty && s != 'profile' && s != 'card' && !s.startsWith('#'),
        orElse: () => webId,
      );
    } catch (_) {
      return webId;
    }
  }

  String formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String formatDateTime(DateTime dt) {
    final date = '${dt.day}/${dt.month}/${dt.year}';
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$date $hour:$minute:$second';
  }
}
