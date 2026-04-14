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
    final senderName = extractName(notification.senderWebId);
    final structured = _parseStructuredContent(notification.content);

    final fileTitle = structured?['fileTitle'] ?? notification.title;
    final permissions = structured?['permissions'];

    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);

        return AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('h:mm a EEEE d MMMM yyyy').format(dateTime),
                ),
              ),
              if (priorityIcon(notification.priority) != null)
                priorityIcon(notification.priority)!,
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: theme.textTheme.bodyLarge,
                        children: [
                          TextSpan(
                            text: (permissions != null)
                                ? '$senderName shared this file with you. You have ${permissions?.toLowerCase()} permission. \n\n'
                                : '$senderName shared this file with you. \n\n',
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: '$fileTitle\n\n',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    _buildDetailsExpansionTile(
                      notification,
                      dateTime,
                      structured,
                      theme,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                confirmAndDelete(notification);
              },
              child: const Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Attempts to parse JSON-structured content from a notification.
  /// Returns null for legacy plain-text content.

  Map<String, dynamic>? _parseStructuredContent(String? content) {
    if (content == null) return null;
    try {
      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException catch (_) {
      // Legacy plain-text content; not JSON.
    }
    return null;
  }

  Widget _buildDetailsExpansionTile(
    PodNotification notification,
    DateTime dateTime,
    Map<String, dynamic>? structured,
    ThemeData theme,
  ) {
    final smallStyle = theme.textTheme.bodySmall;

    final fileUrl = structured?['fileUrl'] ?? notification.title;
    final fileTitle = structured?['fileTitle'] ?? notification.title;
    final sharedBy = structured?['sharedBy'] ?? notification.senderWebId;
    final owner = structured?['owner'] ?? notification.senderWebId;
    final permissions = structured?['permissions'] ?? '';

    return ExpansionTile(
      title: const Text('Details'),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      children: [
        _detailLine('Date', formatDateTime(dateTime), smallStyle),
        _detailLine('File', fileUrl, smallStyle),
        _detailLine('Title', fileTitle, smallStyle),
        _detailLine('Shared by', sharedBy, smallStyle),
        _detailLine('Owner', owner, smallStyle),
        _detailLine('Permissions', permissions, smallStyle),
      ],
    );
  }

  Widget _detailLine(String label, String value, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: style?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(value, style: style),
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

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

  String formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _dateFormat.format(dt);
  }

  String formatDateTime(DateTime dt) => _dateTimeFormat.format(dt);
}
