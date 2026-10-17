import 'package:flutter/material.dart';

import '../../models/attendance_correction.dart';
import '../../models/branch.dart';
import '../../models/user.dart';
import '../../services/attendance_correction_service.dart';
import '../../services/branch_service.dart';

class ManagerAttendanceCorrectionsPage extends StatefulWidget {
  final User user;
  final int? branchId;
  final String? branchName;

  const ManagerAttendanceCorrectionsPage({
    super.key,
    required this.user,
    this.branchId,
    this.branchName,
  });

  @override
  State<ManagerAttendanceCorrectionsPage> createState() =>
      _ManagerAttendanceCorrectionsPageState();
}

class _ManagerAttendanceCorrectionsPageState
    extends State<ManagerAttendanceCorrectionsPage> {
  static const Color violet = Color(0xFF7C2FCE);
  static const Color background = Color(0xFFF7F5FA);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);
  static const Color emerald = Color(0xFF10B981);
  static const Color crimson = Color(0xFFEF4444);

  final AttendanceCorrectionService _service = AttendanceCorrectionService();
  final BranchService _branchService = BranchService();

  List<AttendanceCorrection> _corrections = [];
  List<Branch> _branches = [];
  int? _selectedBranchId;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Admin (roleId == 1) defaults to null (All Branches) unless explicitly passed
    if (widget.user.roleId == 1) {
      _selectedBranchId = widget.branchId;
    } else {
      _selectedBranchId = widget.branchId ?? (widget.user.branchId > 0 ? widget.user.branchId : null);
    }
    _loadBranches();
    _loadCorrections();
  }

  Future<void> _loadBranches() async {
    try {
      List<Branch> list = [];
      if (widget.user.roleId == 1) {
        list = await _branchService.getBranches();
      } else {
        list = await _branchService.getUserBranches(widget.user.userId);
      }
      if (mounted) {
        setState(() {
          _branches = list;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadCorrections() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _service.getPendingCorrections(
        branchId: _selectedBranchId,
      );
      if (!mounted) return;
      setState(() {
        _corrections = list;
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

  Future<void> _approveCorrection(AttendanceCorrection item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Correction'),
        content: Text(
          'Are you sure you want to approve the attendance correction for ${item.employeeName} on ${item.attendanceDate}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: emerald),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.reviewCorrection(
        id: item.id,
        reviewerId: widget.user.userId,
        status: 1,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Correction approved for ${item.employeeName}.'),
          backgroundColor: emerald,
        ),
      );
      _loadCorrections();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: crimson,
        ),
      );
    }
  }

  Future<void> _rejectCorrection(AttendanceCorrection item) async {
    final commentController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Correction'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Provide a reason for rejecting ${item.employeeName}\'s request:'),
              const SizedBox(height: 12),
              TextFormField(
                controller: commentController,
                maxLines: 3,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Rejection reason is required.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'e.g. Unverified punch, employee was not present.',
                  hintStyle: const TextStyle(fontSize: 12, color: textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: crimson),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.reviewCorrection(
        id: item.id,
        reviewerId: widget.user.userId,
        status: 2,
        comment: commentController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Correction rejected for ${item.employeeName}.'),
          backgroundColor: crimson,
        ),
      );
      _loadCorrections();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: crimson,
        ),
      );
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final local = dt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    final min = local.minute.toString().padLeft(2, '0');
    return '$hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Attendance Corrections',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCorrections,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_branches.isNotEmpty) _buildBranchSelector(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBranchSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: const Text('All Branches'),
                selected: _selectedBranchId == null,
                selectedColor: violet.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color: _selectedBranchId == null ? violet : textDark,
                  fontWeight: _selectedBranchId == null ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedBranchId = null);
                    _loadCorrections();
                  }
                },
              ),
            ),
            ..._branches.map((b) {
              final isSelected = _selectedBranchId == b.branchId;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(b.branchName),
                  selected: isSelected,
                  selectedColor: violet.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: isSelected ? violet : textDark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedBranchId = b.branchId);
                      _loadCorrections();
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: violet));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: crimson),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: crimson),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCorrections,
                style: ElevatedButton.styleFrom(backgroundColor: violet),
                child: const Text('Try Again', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_corrections.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadCorrections,
        color: violet,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: textMuted),
                  SizedBox(height: 16),
                  Text(
                    'No pending attendance corrections',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textMuted,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'All employee punch adjustments are reviewed.',
                    style: TextStyle(fontSize: 12, color: textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCorrections,
      color: violet,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _corrections.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = _corrections[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E0EE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Employee Name, Code & Date
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: violet.withValues(alpha: 0.1),
                      child: Text(
                        item.employeeName.isNotEmpty
                            ? item.employeeName[0].toUpperCase()
                            : 'E',
                        style: const TextStyle(
                          color: violet,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.employeeName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.employeeCode} • ${item.branchName}',
                            style: const TextStyle(fontSize: 12, color: textMuted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.attendanceDate,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // Punch Time Changes
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.login, size: 16, color: emerald),
                          const SizedBox(width: 8),
                          const Text('Check-In:', style: TextStyle(fontSize: 12, color: textMuted)),
                          const SizedBox(width: 6),
                          Text(
                            _formatDateTime(item.originalCheckInTime),
                            style: const TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: textMuted,
                            ),
                          ),
                          const Icon(Icons.arrow_right_alt, size: 16, color: textMuted),
                          Text(
                            _formatDateTime(item.requestedCheckInTime),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.logout, size: 16, color: crimson),
                          const SizedBox(width: 8),
                          const Text('Check-Out:', style: TextStyle(fontSize: 12, color: textMuted)),
                          const SizedBox(width: 6),
                          Text(
                            _formatDateTime(item.originalCheckOutTime),
                            style: const TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: textMuted,
                            ),
                          ),
                          const Icon(Icons.arrow_right_alt, size: 16, color: textMuted),
                          Text(
                            _formatDateTime(item.requestedCheckOutTime),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Reason
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.comment_outlined, size: 15, color: textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.reason,
                        style: const TextStyle(fontSize: 12, color: textDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _rejectCorrection(item),
                      icon: const Icon(Icons.close, size: 16, color: crimson),
                      label: const Text('Reject', style: TextStyle(color: crimson)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: crimson),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _approveCorrection(item),
                      icon: const Icon(Icons.check, size: 16, color: Colors.white),
                      label: const Text('Approve', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: emerald,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
