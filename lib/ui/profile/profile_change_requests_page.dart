import 'package:flutter/material.dart';
import '../../models/profile_change_request.dart';
import '../../models/user.dart';
import '../../services/profile_change_service.dart';

class ProfileChangeRequestsPage extends StatefulWidget {
  final User user;
  final bool isManagerOrAdmin;

  const ProfileChangeRequestsPage({
    super.key,
    required this.user,
    this.isManagerOrAdmin = false,
  });

  @override
  State<ProfileChangeRequestsPage> createState() => _ProfileChangeRequestsPageState();
}

class _ProfileChangeRequestsPageState extends State<ProfileChangeRequestsPage> with SingleTickerProviderStateMixin {
  static const Color violet = Color(0xFF7C2FCE);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);
  static const Color emerald = Color(0xFF10B981);
  static const Color crimson = Color(0xFFEF4444);
  static const Color amber = Color(0xFFF59E0B);

  final ProfileChangeService _service = ProfileChangeService();

  late final TabController _tabController;
  List<ProfileChangeRequest> _allRequests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<ProfileChangeRequest> list;
      if (widget.isManagerOrAdmin) {
        list = await _service.getAllRequests();
      } else {
        list = await _service.getMyRequests(widget.user.employeeId);
      }

      if (!mounted) return;
      setState(() {
        _allRequests = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _approve(ProfileChangeRequest req) async {
    final commentController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: emerald, size: 24),
            SizedBox(width: 8),
            Text('Approve Changes', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to approve profile updates for ${req.employeeName}? This will immediately update both the Employee profile and User login records.',
              style: const TextStyle(fontSize: 13, height: 1.4, color: textDark),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: 'Approval Note (Optional)',
                hintText: 'e.g., Verified documents',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: emerald,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm Approval'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.approveRequest(
        req.id,
        reviewerUserId: widget.user.userId,
        comment: commentController.text.trim().isEmpty ? null : commentController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile changes approved and applied successfully.'),
          backgroundColor: emerald,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadRequests();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: crimson,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _reject(ProfileChangeRequest req) async {
    final commentController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: crimson, size: 24),
            SizedBox(width: 8),
            Text('Reject Request', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reject profile update request for ${req.employeeName}. Please specify the reason so the employee can correct their details.',
              style: const TextStyle(fontSize: 13, height: 1.4, color: textDark),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: 'Rejection Reason *',
                hintText: 'e.g., Incomplete bank details or invalid passbook',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: crimson,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (commentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a rejection reason.')),
                );
                return;
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('Confirm Rejection'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.rejectRequest(
        req.id,
        reviewerUserId: widget.user.userId,
        comment: commentController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile change request rejected.'),
          backgroundColor: crimson,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadRequests();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: crimson,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _cancel(ProfileChangeRequest req) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Request', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to cancel your pending profile change request?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No, Keep')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: crimson,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.cancelRequest(req.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request cancelled successfully.')),
      );
      _loadRequests();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FA),
      appBar: AppBar(
        title: Text(
          widget.isManagerOrAdmin ? 'Profile Change Requests' : 'My Change Requests',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: violet,
          unselectedLabelColor: textMuted,
          indicatorColor: violet,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: violet))
          : _errorMessage != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(_allRequests.where((r) => r.isPending).toList(), 'No pending change requests'),
                    _buildList(_allRequests.where((r) => r.isApproved).toList(), 'No approved requests'),
                    _buildList(_allRequests.where((r) => r.isRejected).toList(), 'No rejected requests'),
                    _buildList(_allRequests, 'No requests found'),
                  ],
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: crimson, size: 48),
            const SizedBox(height: 12),
            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: crimson)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadRequests,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(backgroundColor: violet, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<ProfileChangeRequest> items, String emptyMessage) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadRequests,
        color: violet,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, color: Colors.grey.shade400, size: 52),
                  const SizedBox(height: 12),
                  Text(
                    emptyMessage,
                    style: const TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      color: violet,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final req = items[index];
          return _buildRequestCard(req);
        },
      ),
    );
  }

  Widget _buildRequestCard(ProfileChangeRequest req) {
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    if (req.isApproved) {
      statusColor = emerald;
      statusBg = const Color(0xFFD1FAE5);
      statusIcon = Icons.check_circle_rounded;
    } else if (req.isRejected) {
      statusColor = crimson;
      statusBg = const Color(0xFFFEE2E2);
      statusIcon = Icons.cancel_rounded;
    } else if (req.isCancelled) {
      statusColor = Colors.grey.shade600;
      statusBg = Colors.grey.shade200;
      statusIcon = Icons.block_rounded;
    } else {
      statusColor = amber;
      statusBg = const Color(0xFFFEF3C7);
      statusIcon = Icons.schedule_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEE8F3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Employee Info + Status Chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: violet.withValues(alpha: 0.12),
                  child: Text(
                    req.employeeName.isNotEmpty ? req.employeeName[0].toUpperCase() : 'E',
                    style: const TextStyle(color: violet, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req.employeeName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '#${req.employeeCode} • ${req.departmentName ?? "Operations"}',
                        style: const TextStyle(color: textMuted, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        req.statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 14),

            // Diff Details Breakdown
            _buildDiffSection(req),

            // Employee Reason
            if (req.reason != null && req.reason!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote_rounded, size: 16, color: violet),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        req.reason!,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Reviewer Notes if Approved or Rejected
            if (!req.isPending && req.reviewerName != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: req.isApproved ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: req.isApproved ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reviewed by ${req.reviewerName} ${req.reviewedAt != null ? "• ${_formatTimestamp(req.reviewedAt!)}" : ""}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: req.isApproved ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                      ),
                    ),
                    if (req.reviewerComment != null && req.reviewerComment!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        req.reviewerComment!,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: req.isApproved ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Action Buttons for Manager/Admin
            if (widget.isManagerOrAdmin && req.isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _reject(req),
                      icon: const Icon(Icons.close_rounded, size: 16, color: crimson),
                      label: const Text('Reject', style: TextStyle(color: crimson, fontWeight: FontWeight.bold, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approve(req),
                      icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                      label: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: emerald,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (!widget.isManagerOrAdmin && req.isPending) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _cancel(req),
                  icon: const Icon(Icons.cancel_outlined, size: 15, color: crimson),
                  label: const Text('Cancel Request', style: TextStyle(color: crimson, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiffSection(ProfileChangeRequest req) {
    final diffs = <Widget>[];

    // Bank Account Number
    if (req.bankAccountNo != null && req.bankAccountNo != req.currentBankAccountNo) {
      diffs.add(_buildDiffRow('Bank Account', req.currentBankAccountNo ?? 'None', req.bankAccountNo!, Icons.numbers_outlined));
    }

    // Bank Name
    if (req.bankName != null && req.bankName != req.currentBankName) {
      diffs.add(_buildDiffRow('Bank Name', req.currentBankName ?? 'None', req.bankName!, Icons.account_balance_outlined));
    }

    // Bank Branch
    if (req.bankBranch != null && req.bankBranch != req.currentBankBranch) {
      diffs.add(_buildDiffRow('Bank Branch', req.currentBankBranch ?? 'None', req.bankBranch!, Icons.location_city_outlined));
    }

    // Name
    final oldName = '${req.currentFirstName ?? ""} ${req.currentLastName ?? ""}'.trim();
    final newName = '${req.firstName ?? req.currentFirstName ?? ""} ${req.lastName ?? req.currentLastName ?? ""}'.trim();
    if (newName.isNotEmpty && newName != oldName) {
      diffs.add(_buildDiffRow('Name', oldName.isEmpty ? 'None' : oldName, newName, Icons.badge_outlined));
    }

    // Phone
    if (req.phone != null && req.phone != req.currentPhone) {
      diffs.add(_buildDiffRow('Phone', req.currentPhone ?? 'None', req.phone!, Icons.phone_outlined));
    }

    // DOB
    if (req.dateOfBirth != null && req.dateOfBirth != req.currentDateOfBirth) {
      diffs.add(_buildDiffRow('Date of Birth', req.currentDateOfBirth ?? 'None', req.dateOfBirth!, Icons.cake_outlined));
    }

    // Gender
    if (req.gender != null && req.gender != req.currentGender) {
      diffs.add(_buildDiffRow('Gender', req.currentGender ?? 'None', req.gender!, Icons.people_outline));
    }

    // Address
    if (req.addressLine1 != null && req.addressLine1 != req.currentAddressLine1) {
      diffs.add(_buildDiffRow('Address', req.currentAddressLine1 ?? 'None', req.addressLine1!, Icons.home_outlined));
    }

    // City
    if (req.city != null && req.city != req.currentCity) {
      diffs.add(_buildDiffRow('City', req.currentCity ?? 'None', req.city!, Icons.location_on_outlined));
    }

    // Qualification
    if (req.qualification != null && req.qualification != req.currentQualification) {
      diffs.add(_buildDiffRow('Qualification', req.currentQualification ?? 'None', req.qualification!, Icons.school_outlined));
    }

    if (diffs.isEmpty) {
      return const Text('No specific field diff recorded.', style: TextStyle(fontSize: 12, color: textMuted));
    }

    return Column(children: diffs);
  }

  Widget _buildDiffRow(String label, String oldVal, String newVal, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: violet),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: textMuted),
            ),
          ),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  oldVal,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.red.shade400,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_forward_rounded, size: 13, color: textMuted),
                ),
                Text(
                  newVal,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: emerald,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}
