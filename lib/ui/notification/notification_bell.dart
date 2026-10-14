import 'package:flutter/material.dart';
import '../../core/storage/secure_storage.dart';
import '../../services/notification_service.dart';
import 'notification_page.dart';

class NotificationBell extends StatefulWidget {
  final Color iconColor;
  final Color badgeColor;
  final bool isHeaderButton;

  const NotificationBell({
    super.key,
    this.iconColor = Colors.white,
    this.badgeColor = const Color(0xFFEF4444),
    this.isHeaderButton = true,
  });

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final userId = await SecureStorage.getUserId();
      final summary = await _notificationService.getSummary(userId: userId);
      if (mounted) {
        setState(() {
          _unreadCount = summary.unreadCount;
        });
      }
    } catch (_) {
      // Ignore background badge fetch error
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationPage()),
    );
    // Refresh count on return
    _fetchUnreadCount();
  }

  Widget _buildBadge() {
    if (_unreadCount <= 0) return const SizedBox.shrink();

    return Positioned(
      right: widget.isHeaderButton ? 4 : -2,
      top: widget.isHeaderButton ? 4 : -2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: widget.badgeColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 1.2),
        ),
        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
        child: Text(
          _unreadCount > 99 ? '99+' : '$_unreadCount',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isHeaderButton) {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openNotifications,
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: widget.iconColor,
                  size: 21,
                ),
                _buildBadge(),
              ],
            ),
          ),
        ),
      );
    }

    return IconButton(
      tooltip: 'Notifications',
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_outlined, color: widget.iconColor, size: 26),
          _buildBadge(),
        ],
      ),
      onPressed: _openNotifications,
    );
  }
}
