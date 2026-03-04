import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final data = await ApiService.getNotifications();
      setState(() {
        _notifications = data['data'] ?? data['notifications'] ?? [];
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markRead(String id, int index) async {
    await ApiService.markNotificationRead(id);
    setState(() => _notifications[index]['isRead'] = true);
  }

  @override
  Widget build(BuildContext context) {
    final today = <dynamic>[];
    final older = <dynamic>[];
    for (final n in _notifications) {
      final created = DateTime.tryParse(n['createdAt'] ?? '') ?? DateTime.now();
      if (DateTime.now().difference(created).inDays == 0) {
        today.add(n);
      } else {
        older.add(n);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.any((n) => n['isRead'] == false))
            TextButton(
              onPressed: () async {
                for (final n in _notifications.where((n) => n['isRead'] == false)) {
                  await ApiService.markNotificationRead(n['id'].toString());
                }
                _loadNotifications();
              },
              child: const Text('Mark all read',
                  style: TextStyle(color: AppColors.primary)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(child: Text('No notifications yet'))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (today.isNotEmpty) ...[
            _sectionHeader('Today'),
            ...today.map((e) => _NotifTile(
              notif: e,
              onTap: () => _markRead(
                  e['id'].toString(),
                  _notifications.indexOf(e)),
            )),
          ],
          if (older.isNotEmpty) ...[
            _sectionHeader('Earlier'),
            ...older.map((e) => _NotifTile(
              notif: e,
              onTap: () => _markRead(
                  e['id'].toString(),
                  _notifications.indexOf(e)),
            )),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 10),
    child: Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.textSecondary)),
  );
}

class _NotifTile extends StatelessWidget {
  final Map<String, dynamic> notif;
  final VoidCallback onTap;
  const _NotifTile({required this.notif, required this.onTap});

  IconData get _icon {
    final type = (notif['type'] ?? '').toString().toLowerCase();
    if (type.contains('transfer')) return Icons.send;
    if (type.contains('request')) return Icons.request_page;
    if (type.contains('bill')) return Icons.receipt_long;
    return Icons.notifications_outlined;
  }

  Color get _iconColor {
    final type = (notif['type'] ?? '').toString().toLowerCase();
    if (type.contains('transfer')) return AppColors.primary;
    if (type.contains('request')) return Colors.orange;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notif['isRead'] == true;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : AppColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: isRead
              ? null
              : Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif['title'] ?? 'Notification',
                      style: TextStyle(
                          fontWeight:
                          isRead ? FontWeight.w500 : FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(notif['message'] ?? notif['body'] ?? '',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ]),
          ),
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
            ),
        ]),
      ),
    );
  }
}