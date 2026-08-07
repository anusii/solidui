/// Notification Button - AppBar button with unread badge overlay.
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

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidpod/solidpod.dart';

import 'package:solidui/src/widgets/solid_notification_centre.dart';

/// Polling interval for background unread-count refreshes.

const Duration _pollInterval = Duration(seconds: 10);

/// An AppBar icon button that shows a notification bell with an unread
/// count badge. Tapping it navigates to the [SolidNotificationCentre].
/// The badge count is refreshed when the button is mounted, periodically
/// via a polling timer, and again after returning from the notification
/// centre.

class SolidNotificationButton extends StatefulWidget {
  const SolidNotificationButton({super.key});

  @override
  State<SolidNotificationButton> createState() =>
      _SolidNotificationButtonState();
}

class _SolidNotificationButtonState extends State<SolidNotificationButton>
    with WidgetsBindingObserver {
  int _unreadCount = 0;
  Timer? _pollTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshUnreadCount();
    _startTimer();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Refresh immediately when the application returns to the foreground,
  /// because [Timer.periodic] does not fire whilst the app is suspended.

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshUnreadCount();
      _restartTimer();
    }
  }

  void _startTimer() {
    _pollTimer = Timer.periodic(_pollInterval, (_) => _refreshUnreadCount());
  }

  /// Cancel and re-create the periodic timer so the next tick is a full
  /// [_pollInterval] away. Call after any manual refresh to avoid a near-
  /// immediate duplicate poll.

  void _restartTimer() {
    _pollTimer?.cancel();
    _startTimer();
  }

  /// Fetch the current unread-notification count via the new pair-based
  /// notification API and update the badge. Concurrent invocations are
  /// skipped to avoid redundant cross-POD traffic.

  Future<void> _refreshUnreadCount() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      if (!await isUserLoggedIn()) {
        if (mounted) setState(() => _unreadCount = 0);
        return;
      }

      final notifications = await fetchNotifications();

      final prefs = await SharedPreferences.getInstance();
      final readList = prefs.getStringList(solidReadNotificationsKey) ?? [];
      final readIds = readList.toSet();

      final unread = notifications.where((n) => !readIds.contains(n.id)).length;

      if (mounted) setState(() => _unreadCount = unread);
    } on Object catch (e) {
      debugPrint('[NOTIF] Failed to refresh unread count: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Badge(
        isLabelVisible: _unreadCount > 0,
        backgroundColor: Colors.grey,
        label: Text('$_unreadCount'),
        child: const Icon(Icons.notifications_outlined),
      ),
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SolidNotificationCentre()),
        );
        await _refreshUnreadCount();
        _restartTimer();
      },
      tooltip: 'Notifications',
    );
  }
}
