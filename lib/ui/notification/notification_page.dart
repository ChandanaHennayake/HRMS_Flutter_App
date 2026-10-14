import 'package:flutter/material.dart';
import '../../core/storage/secure_storage.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';
import '../payroll/payslip_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = true;
  String? _errorMessage;
  List<AppNotification> _notifications = [];
  int? _userId;
  String _selectedFilter = 'all'; // 'all' or 'unread'

  // Brand Palette
  static const Color violet = Color(0xFF6B21A8);
  static const Color violetLight = Color(0xFFF5F3FF);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color emeraldLight = Color(0xFFECFDF5);
  static const Color amberDark = Color(0xFFD97706);
  static const Color amberLight = Color(0xFFFFFBEB);
  static const Color redDark = Color(0xFFDC2626);
  static const Color redLight = Color(0xFFFEF2F2);
  static const Color slateDark = Color(0xFF0F172A);
  static const Color slateMuted = Color(0xFF64748B);
  static const Color slateBorder = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _userId = await SecureStorage.getUserId();
      final list = await _notificationService.getMyNotifications(userId: _userId);

      if (!mounted) return;
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.isRead) return;

    // Optimistic update
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification.copyWith(isRead: true, readAt: DateTime.now());
      }
    });

    try {
      await _notificationService.markAsRead(notification.id);
    } catch (_) {
      // Revert if failed
      _loadNotifications();
    }
  }

  Future<void> _markAllAsRead() async {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    if (unreadCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications are already marked as read.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true, readAt: DateTime.now())).toList();
    });

    try {
      await _notificationService.markAllAsRead(userId: _userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read.'),
          backgroundColor: emeraldDark,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _loadNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark all as read: $e'),
          backgroundColor: redDark,
        ),
      );
    }
  }

  void _onNotificationTap(AppNotification notification) {
    _markAsRead(notification);

    if (notification.referenceType == 'Payslip' && notification.referenceId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PayslipPage(payslipId: notification.referenceId!),
        ),
      );
    }
  }

  List<AppNotification> get _filteredNotifications {
    if (_selectedFilter == 'unread') {
      return _notifications.where((n) => !n.isRead).toList();
    }
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: violet,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: Colors.white),
            tooltip: 'Mark all as read',
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(unreadCount),

          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadNotifications,
              color: violet,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(int unreadCount) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All (${_notifications.length})',
            isSelected: _selectedFilter == 'all',
            onTap: () => setState(() => _selectedFilter = 'all'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Unread ($unreadCount)',
            isSelected: _selectedFilter == 'unread',
            hasBadge: unreadCount > 0,
            onTap: () => setState(() => _selectedFilter = 'unread'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? violet : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? violet : slateBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : slateDark,
              ),
            ),
            if (hasBadge && !isSelected) ...[
              const SizedBox(width: 6),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: violet,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: violet),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline_rounded, size: 54, color: redDark),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: slateMuted),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadNotifications,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: violet,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final displayList = _filteredNotifications;

    if (displayList.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: violetLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_off_outlined,
                    size: 48,
                    color: violet,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _selectedFilter == 'unread'
                      ? 'No unread notifications'
                      : 'You\'re all caught up!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: slateDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedFilter == 'unread'
                      ? 'All your notifications have been read.'
                      : 'Important updates will appear here in real-time.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: slateMuted),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: displayList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = displayList[index];
        return _buildNotificationCard(item);
      },
    );
  }

  Widget _buildNotificationCard(AppNotification item) {
    Color iconColor;
    Color iconBg;
    IconData iconData;

    switch (item.type.toLowerCase()) {
      case 'success':
        iconColor = emeraldDark;
        iconBg = emeraldLight;
        iconData = Icons.check_circle_rounded;
        break;
      case 'warning':
        iconColor = amberDark;
        iconBg = amberLight;
        iconData = Icons.warning_amber_rounded;
        break;
      case 'error':
        iconColor = redDark;
        iconBg = redLight;
        iconData = Icons.error_outline_rounded;
        break;
      case 'info':
      default:
        iconColor = violet;
        iconBg = violetLight;
        iconData = Icons.notifications_active_rounded;
        break;
    }

    return InkWell(
      onTap: () => _onNotificationTap(item),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFFAF5FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isRead ? slateBorder : const Color(0xFFD8B4FE),
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: item.isRead ? 0.02 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Badge
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: slateDark,
                          ),
                        ),
                      ),
                      if (!item.isRead) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: violet,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.message,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: item.isRead ? slateMuted : slateDark,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 13, color: slateMuted),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimestamp(item.createdAt),
                        style: const TextStyle(fontSize: 11.5, color: slateMuted),
                      ),
                      if (item.referenceType != null) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.referenceType!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: slateMuted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }
  }
}
