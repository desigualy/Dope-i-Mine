import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/notifications/app_notification.dart';
import '../../providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  late Future<List<AppNotification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
    _notificationsFuture = authUser == null
        ? Future.value(<AppNotification>[]) 
        : ref
            .read(notificationRepositoryProvider)
            .getNotifications(userId: authUser.id);
  }

  Future<void> _refreshNotifications() async {
    _loadNotifications();
    setState(() {});
    await _notificationsFuture;
  }

  Future<void> _markRead(AppNotification notification) async {
    await ref
        .read(notificationRepositoryProvider)
        .markAsRead(notification.id);
    _refreshNotifications();
  }

  Future<void> _dismiss(AppNotification notification) async {
    await ref
        .read(notificationRepositoryProvider)
        .dismissNotification(notification.id);
    _refreshNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: FutureBuilder<List<AppNotification>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifications = snapshot.data ?? <AppNotification>[];
          if (notifications.isEmpty) {
            return const Center(
              child: Text('No notifications yet.'),
            );
          }
          return RefreshIndicator(
            onRefresh: _refreshNotifications,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Material(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).cardColor,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    title: Text(notification.title),
                    subtitle: Text(notification.body ?? ''),
                    leading: CircleAvatar(
                      child: Text(
                        notification.type.name.substring(0, 1).toUpperCase(),
                      ),
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        if (notification.status != AppNotificationStatus.read)
                          IconButton(
                            icon: const Icon(Icons.mark_chat_read_rounded),
                            tooltip: 'Mark read',
                            onPressed: () => _markRead(notification),
                          ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          tooltip: 'Dismiss',
                          onPressed: () => _dismiss(notification),
                        ),
                      ],
                    ),
                    onTap: notification.route == null
                        ? null
                        : () {
                            Navigator.of(context).pushNamed(notification.route!);
                          },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
