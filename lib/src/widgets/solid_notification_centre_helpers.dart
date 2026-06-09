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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _markAsDeleted(notification.id);
    updateState(() {
      _notifications.removeWhere((n) => n.id == notification.id);
      _clampCurrentPage();
    });
  }

  // Detail dialog.

  void showNotificationDetail(PodNotification notification) {
    _markAsRead(notification.id);

    final dateTime =
        DateTime.fromMillisecondsSinceEpoch(notification.timestamp);
    final structured = _parseStructuredContent(notification.content);

    final fileTitle =
        (structured?['fileTitle'] as String?) ?? notification.title;
    final permissions = structured?['permissions'] as String?;

    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final maxContentWidth = _detailDialogMaxWidth(theme);

        return AlertDialog(
          title: Row(
            children: [
              Expanded(child: Text(notification.title)),
              if (priorityIcon(notification.priority) != null)
                priorityIcon(notification.priority)!,
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: SizedBox(
              width: double.maxFinite,
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatDateTime(dateTime),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLabelLine(
                        theme,
                        label: 'From: ',
                        value: notification.senderWebId,
                      ),
                      const SizedBox(height: 4),
                      _buildLabelLine(
                        theme,
                        label: 'To: ',
                        value: notification.recipientWebId,
                      ),
                      const Divider(height: 24),
                      _buildBodyText(
                        theme,
                        notification: notification,
                        fileTitle: fileTitle,
                        permissions: permissions,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
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
        );
      },
    );
  }

  /// Single "Label: value" row in the dialog body, where the label is
  /// rendered in bold and the value is selectable so the user can copy
  /// WebIDs out of the dialog.

  Widget _buildLabelLine(
    ThemeData theme, {
    required String label,
    required String value,
  }) {
    return Text.rich(
      TextSpan(
        style: theme.textTheme.bodyMedium,
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  /// Main body sentence under the From/To header. For share
  /// notifications (which carry structured permissions metadata) we
  /// render the templated "You have been granted X access to "Y".".
  /// For free-form notifications we fall back to the raw content.

  Widget _buildBodyText(
    ThemeData theme, {
    required PodNotification notification,
    required String fileTitle,
    required String? permissions,
  }) {
    final hasPermissions = permissions != null && permissions.isNotEmpty;
    if (hasPermissions) {
      return Text.rich(
        TextSpan(
          style: theme.textTheme.bodyLarge,
          children: [
            const TextSpan(text: 'You have been granted '),
            TextSpan(
              text: permissions,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ' access to '),
            TextSpan(
              text: '"$fileTitle"',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      );
    }

    final content = notification.content;
    if (content == null || content.isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(content, style: theme.textTheme.bodyLarge);
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

  static final DateFormat _dateFormat = DateFormat('d/M/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('d/M/yyyy HH:mm:ss');

  String formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _dateFormat.format(dt);
  }

  String formatDateTime(DateTime dt) => _dateTimeFormat.format(dt);

  /// Cap the detail dialog at roughly 80–100 characters of body text so
  /// long notification content never stretches across the full window
  /// on wide displays. The cap is measured live against the active
  /// `bodyLarge` text style so themes that bump the font size scale
  /// the dialog accordingly.

  double _detailDialogMaxWidth(ThemeData theme) {
    final style = theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 16);
    const sample = 'The quick brown fox jumps over the lazy dog 0123456789';
    final tp = TextPainter(
      text: TextSpan(text: sample, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final charWidth = tp.width / sample.length;
    return charWidth * 90;
  }
}
