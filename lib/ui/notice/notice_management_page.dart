import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/notice.dart';
import '../../services/notice_service.dart';
import '../../core/theme/app_colors.dart';

class NoticeManagementPage extends StatefulWidget {
  const NoticeManagementPage({super.key});

  @override
  State<NoticeManagementPage> createState() => _NoticeManagementPageState();
}

class _NoticeManagementPageState extends State<NoticeManagementPage> {
  final NoticeService _service = NoticeService();
  bool _loading = true;
  List<SystemNotice> _notices = [];

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    setState(() => _loading = true);
    try {
      final list = await _service.getAllNotices();
      setState(() {
        _notices = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load notices: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _toggleNotice(int id) async {
    final success = await _service.toggleNotice(id);
    if (success) {
      _loadNotices();
    }
  }

  Future<void> _deleteNotice(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Notice'),
        content: const Text('Are you sure you want to delete this notice?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.deleteNotice(id);
      _loadNotices();
    }
  }

  Widget _buildThumbnail(String url) {
    if (url.startsWith('data:image')) {
      try {
        final commaIdx = url.indexOf(',');
        final base64Str = commaIdx != -1 ? url.substring(commaIdx + 1) : url;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          height: 140,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        );
      } catch (_) {
        return const SizedBox.shrink();
      }
    }

    return Image.network(
      url,
      height: 140,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }

  void _showAddNoticeDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    final imageUrlController = TextEditingController();
    String selectedRole = 'All';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Create Announcement Poster'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'e.g. Office Holiday Notice',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Message *',
                    hintText: 'Details of the announcement...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Target Audience',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Users (Everyone)')),
                    DropdownMenuItem(value: 'Employee', child: Text('Employees Only')),
                    DropdownMenuItem(value: 'Manager', child: Text('Managers Only')),
                    DropdownMenuItem(value: 'Admin', child: Text('Admins Only')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedRole = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Poster Image URL (Optional)',
                    hintText: 'https://... or data:image/...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.image),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty || messageController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill title and message')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                try {
                  await _service.createNotice(
                    title: titleController.text.trim(),
                    message: messageController.text.trim(),
                    targetAudience: selectedRole,
                    imageUrl: imageUrlController.text.trim().isNotEmpty ? imageUrlController.text.trim() : null,
                  );
                  _loadNotices();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Post Notice'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Notices & Posters'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNoticeDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('New Notice'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.campaign_outlined, size: 70, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('No notices found', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotices,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: _notices.length,
                    itemBuilder: (context, index) {
                      final n = _notices[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (n.imageUrl != null && n.imageUrl!.isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: _buildThumbnail(n.imageUrl!),
                              ),
                            ListTile(
                              title: Text(
                                n.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(n.message, maxLines: 3, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: n.isActive ? Colors.green.shade50 : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: n.isActive ? Colors.green : Colors.grey,
                                          ),
                                        ),
                                        child: Text(
                                          n.isActive ? 'Active (Shows on Login)' : 'Inactive',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: n.isActive ? Colors.green.shade800 : Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: Colors.blue.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          'Audience: ${n.targetAudience ?? "All"}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (val) {
                                  if (val == 'toggle') _toggleNotice(n.id);
                                  if (val == 'delete') _deleteNotice(n.id);
                                },
                                itemBuilder: (ctx) => [
                                  PopupMenuItem(
                                    value: 'toggle',
                                    child: Text(n.isActive ? 'Set Inactive' : 'Set Active'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
