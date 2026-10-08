import 'package:flutter/material.dart';

import '../../models/branch.dart';
import '../../models/branch_daily_attendance.dart';
import '../../models/user.dart';
import '../../services/attendance_service.dart';
import '../../services/branch_service.dart';

class CompanyAttendancePage extends StatefulWidget {
  final User? user;
  final int? initialBranchId;

  const CompanyAttendancePage({
    super.key,
    this.user,
    this.initialBranchId,
  });

  @override
  State<CompanyAttendancePage> createState() => _CompanyAttendancePageState();
}

class _CompanyAttendancePageState extends State<CompanyAttendancePage> {
  static const Color deepDark = Color(0xFF0B0614);
  static const Color violet = Color(0xFF7C2FCE);
  static const Color background = Color(0xFFF7F5FA);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);
  static const Color emerald = Color(0xFF10B981);
  static const Color crimson = Color(0xFFEF4444);
  static const Color amber = Color(0xFFF59E0B);
  static const Color sapphire = Color(0xFF3B82F6);

  final AttendanceService _attendanceService = AttendanceService();
  final BranchService _branchService = BranchService();
  final TextEditingController _searchController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int? _selectedBranchId; // null = all branches
  List<Branch> _branches = [];

  List<BranchDailyAttendance> _allRoster = [];
  List<BranchDailyAttendance> _filteredRoster = [];

  bool _isLoading = true;
  String? _errorMessage;
  String _statusFilter = 'All'; // 'All', 'Present', 'Absent', 'On Leave', 'Late'

  @override
  void initState() {
    super.initState();
    _selectedBranchId = widget.initialBranchId;
    _loadBranches();
    _loadRoster();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBranches() async {
    try {
      final branches = await _branchService.getBranches();
      if (!mounted) return;
      setState(() => _branches = branches);
    } catch (_) {}
  }

  Future<void> _loadRoster() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final roster = await _attendanceService.getBranchDailyAttendance(
        branchId: _selectedBranchId,
        date: _selectedDate,
      );

      if (!mounted) return;
      setState(() {
        _allRoster = roster;
        _applyFilters();
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

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    _filteredRoster = _allRoster.where((r) {
      final matchesSearch = query.isEmpty ||
          r.fullName.toLowerCase().contains(query) ||
          r.employeeCode.toLowerCase().contains(query) ||
          (r.departmentName?.toLowerCase().contains(query) ?? false);

      if (!matchesSearch) return false;

      if (_statusFilter == 'All') return true;
      if (_statusFilter == 'Present') return r.status == 1;
      if (_statusFilter == 'Absent') return r.status == 0;
      if (_statusFilter == 'On Leave') return r.status == 2;
      if (_statusFilter == 'Late') return r.isLate;

      return true;
    }).toList();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadRoster();
    }
  }

  void _shiftDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadRoster();
  }

  String _formatDateDisplay(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today, ${_monthName(dt.month)} ${dt.day}';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return 'Yesterday, ${_monthName(dt.month)} ${dt.day}';
    }
    return '${_monthName(dt.month)} ${dt.day}, ${dt.year}';
  }

  String _monthName(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m - 1];
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildDateSelector(),
            _buildBranchAndSearchFilters(),
            _buildStatusChips(),
            Expanded(
              child: RefreshIndicator(
                color: violet,
                onRefresh: _loadRoster,
                child: _buildRosterList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            deepDark,
            Color(0xFF3B0B63),
            violet,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Attendance Roster',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: _loadRoster,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: violet),
            onPressed: () => _shiftDate(-1),
          ),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, size: 18, color: violet),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateDisplay(_selectedDate),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: violet),
            onPressed: () => _shiftDate(1),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchAndSearchFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          // Branch selector
          if (_branches.isNotEmpty)
            DropdownButtonFormField<int?>(
              initialValue: _selectedBranchId,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: background,
                prefixIcon: const Icon(Icons.business, size: 18, color: textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All Branches', style: TextStyle(fontSize: 13)),
                ),
                ..._branches.map(
                  (b) => DropdownMenuItem<int?>(
                    value: b.branchId,
                    child: Text(b.branchName, style: const TextStyle(fontSize: 13)),
                  ),
                ),
              ],
              onChanged: (val) {
                setState(() => _selectedBranchId = val);
                _loadRoster();
              },
            ),
          const SizedBox(height: 8),
          // Search input
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(_applyFilters),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search employee name or code...',
              hintStyle: const TextStyle(fontSize: 12, color: textMuted),
              prefixIcon: const Icon(Icons.search, size: 18, color: textMuted),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16, color: textMuted),
                      onPressed: () {
                        _searchController.clear();
                        setState(_applyFilters);
                      },
                    )
                  : null,
              filled: true,
              fillColor: background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChips() {
    final presentCount = _allRoster.where((r) => r.status == 1).length;
    final absentCount = _allRoster.where((r) => r.status == 0).length;
    final leaveCount = _allRoster.where((r) => r.status == 2).length;
    final lateCount = _allRoster.where((r) => r.isLate).length;

    final filters = [
      {'label': 'All', 'count': _allRoster.length},
      {'label': 'Present', 'count': presentCount},
      {'label': 'Absent', 'count': absentCount},
      {'label': 'On Leave', 'count': leaveCount},
      {'label': 'Late', 'count': lateCount},
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = filters[i];
          final label = f['label'] as String;
          final count = f['count'] as int;
          final isSelected = _statusFilter == label;

          return ChoiceChip(
            label: Text('$label ($count)'),
            selected: isSelected,
            selectedColor: violet.withValues(alpha: 0.15),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? violet : textDark,
            ),
            side: BorderSide(
              color: isSelected ? violet : Colors.grey.shade300,
            ),
            onSelected: (val) {
              if (val) {
                setState(() {
                  _statusFilter = label;
                  _applyFilters();
                });
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildRosterList() {
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
                onPressed: _loadRoster,
                style: ElevatedButton.styleFrom(backgroundColor: violet),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredRoster.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_off_outlined, size: 56, color: textMuted),
              SizedBox(height: 12),
              Text(
                'No attendance records found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Try selecting a different date or filter.',
                style: TextStyle(fontSize: 12, color: textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _filteredRoster.length,
      itemBuilder: (context, index) {
        final item = _filteredRoster[index];
        return _buildAttendanceCard(item);
      },
    );
  }

  Widget _buildAttendanceCard(BranchDailyAttendance item) {
    Color statusColor;
    switch (item.status) {
      case 1:
        statusColor = emerald;
        break;
      case 2:
        statusColor = sapphire;
        break;
      case 3:
        statusColor = Colors.purple;
        break;
      case 4:
        statusColor = Colors.deepPurple;
        break;
      default:
        statusColor = item.statusName == 'Not Reported' ? textMuted : crimson;
    }

    final workedHours = item.workedMinutes ~/ 60;
    final workedMins = item.workedMinutes % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.12),
                  child: Text(
                    item.fullName.isNotEmpty ? item.fullName[0].toUpperCase() : 'E',
                    style: TextStyle(
                      color: statusColor,
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
                        item.fullName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      Text(
                        '${item.employeeCode} • ${item.designationName ?? item.departmentName ?? item.branchName ?? ''}',
                        style: const TextStyle(fontSize: 12, color: textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.statusName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _timeColumn('Check In', _formatTime(item.checkInTime)),
                  Container(width: 1, height: 24, color: Colors.grey.shade300),
                  _timeColumn('Check Out', _formatTime(item.checkOutTime)),
                  Container(width: 1, height: 24, color: Colors.grey.shade300),
                  _timeColumn(
                    'Worked',
                    item.workedMinutes > 0 ? '${workedHours}h ${workedMins}m' : '--',
                  ),
                ],
              ),
            ),
            if (item.isLate) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time_filled, size: 14, color: amber),
                  const SizedBox(width: 4),
                  Text(
                    'Late arrival by ${item.lateMinutes} minutes',
                    style: const TextStyle(
                      fontSize: 11,
                      color: amber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _timeColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
      ],
    );
  }
}
