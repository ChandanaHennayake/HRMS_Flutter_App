import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/branch.dart';
import '../../models/report.dart';
import '../../services/branch_service.dart';
import '../../services/report_service.dart';

class ReportsHubPage extends StatefulWidget {
  final int? initialBranchId;
  final String? initialBranchName;

  const ReportsHubPage({
    super.key,
    this.initialBranchId,
    this.initialBranchName,
  });

  @override
  State<ReportsHubPage> createState() => _ReportsHubPageState();
}

class _ReportsHubPageState extends State<ReportsHubPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReportService _reportService = ReportService();
  final BranchService _branchService = BranchService();

  // Brand Palette
  static const Color violet = Color(0xFF6B21A8);
  static const Color violetLight = Color(0xFFF5F3FF);
  static const Color slateDark = Color(0xFF0F172A);
  static const Color slateMuted = Color(0xFF64748B);
  static const Color slateBorder = Color(0xFFE2E8F0);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color emerald = Color(0xFF059669);
  static const Color emeraldLight = Color(0xFFECFDF5);
  static const Color amber = Color(0xFFD97706);
  static const Color amberLight = Color(0xFFFFFBEB);
  static const Color crimson = Color(0xFFDC2626);
  static const Color crimsonLight = Color(0xFFFEF2F2);
  static const Color blue = Color(0xFF2563EB);
  static const Color blueLight = Color(0xFFEFF6FF);

  // Filters
  late DateTime _startDate;
  late DateTime _endDate;
  int? _selectedBranchId;
  List<Branch> _branches = [];
  bool _isLoadingBranches = false;

  // Tab Data States
  bool _isLoadingAttendance = false;
  String? _attendanceError;
  AttendanceReportResponse? _attendanceData;

  bool _isLoadingLeave = false;
  String? _leaveError;
  LeaveReportResponse? _leaveData;

  bool _isLoadingPayroll = false;
  String? _payrollError;
  PayrollReportResponse? _payrollData;

  bool _isLoadingHeadcount = false;
  String? _headcountError;
  HeadcountReport? _headcountData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);

    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;
    _selectedBranchId = widget.initialBranchId;

    _loadBranches();
    _loadCurrentTab();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadCurrentTab();
    }
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadBranches() async {
    setState(() => _isLoadingBranches = true);
    try {
      final list = await _branchService.getBranches();
      if (mounted) {
        setState(() {
          _branches = list;
          _isLoadingBranches = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingBranches = false);
    }
  }

  void _loadCurrentTab() {
    switch (_tabController.index) {
      case 0:
        _loadAttendance();
        break;
      case 1:
        _loadLeave();
        break;
      case 2:
        _loadPayroll();
        break;
      case 3:
        _loadHeadcount();
        break;
    }
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _isLoadingAttendance = true;
      _attendanceError = null;
    });

    try {
      final data = await _reportService.getAttendanceReport(
        startDate: _formatDate(_startDate),
        endDate: _formatDate(_endDate),
        branchId: _selectedBranchId,
      );
      if (mounted) {
        setState(() {
          _attendanceData = data;
          _isLoadingAttendance = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _attendanceError = e.toString().replaceAll('Exception: ', '');
          _isLoadingAttendance = false;
        });
      }
    }
  }

  Future<void> _loadLeave() async {
    setState(() {
      _isLoadingLeave = true;
      _leaveError = null;
    });

    try {
      final data = await _reportService.getLeaveReport(
        startDate: _formatDate(_startDate),
        endDate: _formatDate(_endDate),
        branchId: _selectedBranchId,
      );
      if (mounted) {
        setState(() {
          _leaveData = data;
          _isLoadingLeave = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _leaveError = e.toString().replaceAll('Exception: ', '');
          _isLoadingLeave = false;
        });
      }
    }
  }

  Future<void> _loadPayroll() async {
    setState(() {
      _isLoadingPayroll = true;
      _payrollError = null;
    });

    try {
      final data = await _reportService.getPayrollReport(
        branchId: _selectedBranchId,
        year: _endDate.year,
        month: _endDate.month,
      );
      if (mounted) {
        setState(() {
          _payrollData = data;
          _isLoadingPayroll = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _payrollError = e.toString().replaceAll('Exception: ', '');
          _isLoadingPayroll = false;
        });
      }
    }
  }

  Future<void> _loadHeadcount() async {
    setState(() {
      _isLoadingHeadcount = true;
      _headcountError = null;
    });

    try {
      final data = await _reportService.getHeadcountReport(
        branchId: _selectedBranchId,
      );
      if (mounted) {
        setState(() {
          _headcountData = data;
          _isLoadingHeadcount = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _headcountError = e.toString().replaceAll('Exception: ', '');
          _isLoadingHeadcount = false;
        });
      }
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: violet,
              onPrimary: Colors.white,
              onSurface: slateDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadCurrentTab();
    }
  }

  Future<void> _exportCsv() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: violet),
        ),
      );

      String csvContent = '';
      String filename = 'report.csv';

      final startStr = _formatDate(_startDate);
      final endStr = _formatDate(_endDate);

      switch (_tabController.index) {
        case 0:
          csvContent = await _reportService.exportAttendanceCsv(
            startDate: startStr,
            endDate: endStr,
            branchId: _selectedBranchId,
          );
          filename = 'attendance_${startStr}_to_$endStr.csv';
          break;
        case 1:
          csvContent = await _reportService.exportLeaveCsv(
            startDate: startStr,
            endDate: endStr,
            branchId: _selectedBranchId,
          );
          filename = 'leave_${startStr}_to_$endStr.csv';
          break;
        case 2:
          csvContent = await _reportService.exportPayrollCsv(
            branchId: _selectedBranchId,
            year: _endDate.year,
            month: _endDate.month,
          );
          filename = 'payroll_${_endDate.year}_${_endDate.month}.csv';
          break;
        case 3:
          csvContent = _buildHeadcountCsv();
          filename = 'headcount_report.csv';
          break;
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loading dialog

      _showCsvPreviewModal(filename, csvContent);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export CSV: $e'),
          backgroundColor: crimson,
        ),
      );
    }
  }

  String _buildHeadcountCsv() {
    if (_headcountData == null) return '';
    final buffer = StringBuffer();
    buffer.writeln('Category,Name,Count,Percentage');
    for (final b in _headcountData!.branchDistribution) {
      buffer.writeln('"Branch","${b.name}",${b.count},${b.percentage}%');
    }
    for (final d in _headcountData!.departmentDistribution) {
      buffer.writeln('"Department","${d.name}",${d.count},${d.percentage}%');
    }
    for (final d in _headcountData!.designationDistribution) {
      buffer.writeln('"Designation","${d.name}",${d.count},${d.percentage}%');
    }
    for (final e in _headcountData!.employmentTypeDistribution) {
      buffer.writeln('"Employment Type","${e.name}",${e.count},${e.percentage}%');
    }
    return buffer.toString();
  }

  void _showCsvPreviewModal(String filename, String content) {
    final lineCount = content.split('\n').where((l) => l.trim().isNotEmpty).length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: slateBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: emeraldLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.table_chart_rounded, color: emerald, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filename,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: slateDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$lineCount rows generated • RFC 4180 CSV',
                          style: const TextStyle(fontSize: 12, color: slateMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: violet),
                    tooltip: 'Copy CSV to Clipboard',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('CSV copied to clipboard!'),
                          backgroundColor: emerald,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Data Stream Preview:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: slateDark,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: slateBorder),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: SelectableText(
                        content,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: slateDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: content));
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('CSV copied to clipboard successfully!'),
                        backgroundColor: emerald,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded, color: Colors.white),
                  label: const Text(
                    'Copy All & Done',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: violet,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: const Text(
          'Reports & Analytics',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: slateDark,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(106),
          child: Column(
            children: [
              _buildFilterBar(),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: violet,
                unselectedLabelColor: slateMuted,
                indicatorColor: violet,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(Icons.alarm_on_rounded, size: 20), text: 'Attendance'),
                  Tab(icon: Icon(Icons.event_note_rounded, size: 20), text: 'Leave'),
                  Tab(icon: Icon(Icons.payments_outlined, size: 20), text: 'Payroll'),
                  Tab(icon: Icon(Icons.pie_chart_outline_rounded, size: 20), text: 'Workforce'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: violet),
            tooltip: 'Export Tab to CSV',
            onPressed: _exportCsv,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: slateDark),
            tooltip: 'Refresh',
            onPressed: _loadCurrentTab,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAttendanceTab(),
          _buildLeaveTab(),
          _buildPayrollTab(),
          _buildHeadcountTab(),
        ],
      ),
    );
  }

  // ==========================================
  // FILTER BAR
  // ==========================================

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Branch Dropdown
          Expanded(
            flex: 5,
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: slateBorder),
              ),
              child: _isLoadingBranches
                  ? const Center(child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: violet)))
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: _selectedBranchId,
                        isExpanded: true,
                        hint: const Text('All Branches', style: TextStyle(fontSize: 12, color: slateMuted)),
                        icon: const Icon(Icons.arrow_drop_down, color: slateMuted, size: 18),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('All Branches', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                          ..._branches.map((b) => DropdownMenuItem<int?>(
                                value: b.branchId,
                                child: Text(b.branchName, style: const TextStyle(fontSize: 12)),
                              )),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedBranchId = val);
                          _loadCurrentTab();
                        },
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          // Date Range Button
          Expanded(
            flex: 6,
            child: InkWell(
              onTap: _pickDateRange,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: bgLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: slateBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range_rounded, size: 16, color: violet),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${_formatDate(_startDate)} to ${_formatDate(_endDate)}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: slateDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: ATTENDANCE
  // ==========================================

  Widget _buildAttendanceTab() {
    if (_isLoadingAttendance) {
      return const Center(child: CircularProgressIndicator(color: violet));
    }
    if (_attendanceError != null) {
      return _buildErrorView(_attendanceError!, _loadAttendance);
    }
    if (_attendanceData == null) {
      return const Center(child: Text('No attendance data available.'));
    }

    final summary = _attendanceData!.summary;
    final items = _attendanceData!.items;

    return RefreshIndicator(
      color: violet,
      onRefresh: _loadAttendance,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // KPI Metric Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Punctuality',
                  value: '${summary.punctualityRate.toStringAsFixed(1)}%',
                  icon: Icons.verified_user_rounded,
                  iconColor: emerald,
                  bgColor: emeraldLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Total Records',
                  value: summary.totalRecords.toString(),
                  icon: Icons.fact_check_rounded,
                  iconColor: blue,
                  bgColor: blueLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Present',
                  value: summary.presentCount.toString(),
                  icon: Icons.check_circle_rounded,
                  iconColor: emerald,
                  bgColor: emeraldLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  title: 'Late',
                  value: summary.lateCount.toString(),
                  icon: Icons.schedule_rounded,
                  iconColor: amber,
                  bgColor: amberLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  title: 'Absent',
                  value: summary.absentCount.toString(),
                  icon: Icons.cancel_rounded,
                  iconColor: crimson,
                  bgColor: crimsonLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  title: 'Early Exit',
                  value: summary.earlyDepartureCount.toString(),
                  icon: Icons.logout_rounded,
                  iconColor: slateMuted,
                  bgColor: bgLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Worked & OT Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: slateBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Total Worked Hours', style: TextStyle(fontSize: 12, color: slateMuted)),
                    const SizedBox(height: 4),
                    Text(
                      '${summary.totalWorkedHours.toStringAsFixed(1)} hrs',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: slateDark),
                    ),
                  ],
                ),
                Container(height: 32, width: 1, color: slateBorder),
                Column(
                  children: [
                    const Text('Total Overtime', style: TextStyle(fontSize: 12, color: slateMuted)),
                    const SizedBox(height: 4),
                    Text(
                      '${summary.totalOvertimeHours.toStringAsFixed(1)} hrs',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: violet),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance Logs (${items.length})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: slateDark),
              ),
              Text(
                'Sorted by Date',
                style: const TextStyle(fontSize: 12, color: slateMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            _buildEmptyState('No attendance logs found for this filter.')
          else
            ...items.map((item) => _buildAttendanceRow(item)),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(AttendanceReportItem item) {
    final dateStr = item.date != null ? _formatDate(item.date!) : 'N/A';
    final inStr = item.checkInTime != null
        ? '${item.checkInTime!.hour.toString().padLeft(2, '0')}:${item.checkInTime!.minute.toString().padLeft(2, '0')}'
        : '--:--';
    final outStr = item.checkOutTime != null
        ? '${item.checkOutTime!.hour.toString().padLeft(2, '0')}:${item.checkOutTime!.minute.toString().padLeft(2, '0')}'
        : '--:--';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: slateBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.employeeName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: slateDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.status == 'Present' ? emeraldLight : crimsonLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: item.status == 'Present' ? emerald : crimson,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${item.employeeCode} • ${item.departmentName} • ${item.branchName}',
            style: const TextStyle(fontSize: 11, color: slateMuted),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 12, color: slateMuted),
              const SizedBox(width: 4),
              Text(dateStr, style: const TextStyle(fontSize: 11, color: slateDark, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text('In: $inStr  Out: $outStr', style: const TextStyle(fontSize: 11, color: slateMuted)),
              const SizedBox(width: 8),
              Text(
                '${item.workedHours.toStringAsFixed(1)}h',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: violet),
              ),
            ],
          ),
          if (item.isLate || item.otMinutes > 0) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                if (item.isLate)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: amberLight, borderRadius: BorderRadius.circular(4)),
                    child: Text('Late +${item.lateMinutes}m', style: const TextStyle(fontSize: 10, color: amber, fontWeight: FontWeight.bold)),
                  ),
                if (item.otMinutes > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: violetLight, borderRadius: BorderRadius.circular(4)),
                    child: Text('OT +${item.otMinutes}m', style: const TextStyle(fontSize: 10, color: violet, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: LEAVE
  // ==========================================

  Widget _buildLeaveTab() {
    if (_isLoadingLeave) {
      return const Center(child: CircularProgressIndicator(color: violet));
    }
    if (_leaveError != null) {
      return _buildErrorView(_leaveError!, _loadLeave);
    }
    if (_leaveData == null) {
      return const Center(child: Text('No leave data available.'));
    }

    final summary = _leaveData!.summary;
    final items = _leaveData!.items;

    return RefreshIndicator(
      color: violet,
      onRefresh: _loadLeave,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Approved Days',
                  value: summary.approvedDays.toStringAsFixed(1),
                  icon: Icons.check_circle_rounded,
                  iconColor: emerald,
                  bgColor: emeraldLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Pending Days',
                  value: summary.pendingDays.toStringAsFixed(1),
                  icon: Icons.pending_actions_rounded,
                  iconColor: amber,
                  bgColor: amberLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Rejected Days',
                  value: summary.rejectedDays.toStringAsFixed(1),
                  icon: Icons.cancel_rounded,
                  iconColor: crimson,
                  bgColor: crimsonLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Paid vs Unpaid Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: slateBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: emerald, size: 20),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Paid Leave', style: TextStyle(fontSize: 11, color: slateMuted)),
                        Text('${summary.paidDays.toStringAsFixed(1)} days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                Container(height: 28, width: 1, color: slateBorder),
                Row(
                  children: [
                    const Icon(Icons.money_off_rounded, color: amber, size: 20),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Unpaid Leave', style: TextStyle(fontSize: 11, color: slateMuted)),
                        Text('${summary.unpaidDays.toStringAsFixed(1)} days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Type breakdown chips
          if (summary.byTypeBreakdown.isNotEmpty) ...[
            const Text(
              'Leaves by Type',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: slateDark),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: summary.byTypeBreakdown.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: violetLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: violet.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    '${entry.key}: ${entry.value.toStringAsFixed(1)} d',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: violet),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'Leave Requests (${items.length})',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: slateDark),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            _buildEmptyState('No leave requests found for this filter.')
          else
            ...items.map((item) => _buildLeaveRow(item)),
        ],
      ),
    );
  }

  Widget _buildLeaveRow(LeaveReportItem item) {
    final fromStr = item.fromDate != null ? _formatDate(item.fromDate!) : 'N/A';
    final toStr = item.toDate != null ? _formatDate(item.toDate!) : 'N/A';

    Color statusColor;
    Color statusBg;
    if (item.status == 'Approved') {
      statusColor = emerald;
      statusBg = emeraldLight;
    } else if (item.status == 'Pending') {
      statusColor = amber;
      statusBg = amberLight;
    } else {
      statusColor = crimson;
      statusBg = crimsonLight;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: slateBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.employeeName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: slateDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  item.status,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${item.employeeCode} • ${item.branchName}',
            style: const TextStyle(fontSize: 11, color: slateMuted),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(4)),
                child: Text(item.leaveTypeName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: violet)),
              ),
              const SizedBox(width: 8),
              Text('$fromStr → $toStr', style: const TextStyle(fontSize: 11, color: slateMuted)),
              const Spacer(),
              Text(
                '${item.totalDays.toStringAsFixed(1)} days',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: slateDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: PAYROLL
  // ==========================================

  Widget _buildPayrollTab() {
    if (_isLoadingPayroll) {
      return const Center(child: CircularProgressIndicator(color: violet));
    }
    if (_payrollError != null) {
      return _buildErrorView(_payrollError!, _loadPayroll);
    }
    if (_payrollData == null) {
      return const Center(child: Text('No payroll data available.'));
    }

    final summary = _payrollData!.summary;
    final items = _payrollData!.items;

    return RefreshIndicator(
      color: violet,
      onRefresh: _loadPayroll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Total Company Cost Highlight Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B21A8), Color(0xFF4C1D95)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: violet.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL COMPANY COST',
                      style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                    Text(
                      summary.periodName.isNotEmpty ? summary.periodName : 'Current Run',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'LKR ${summary.totalCompanyCost.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  '${summary.employeeCount} active payslips processed',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Breakdown Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Gross Earnings',
                  value: 'LKR ${summary.totalGrossSalary.toStringAsFixed(0)}',
                  icon: Icons.trending_up_rounded,
                  iconColor: emerald,
                  bgColor: emeraldLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Net Salary',
                  value: 'LKR ${summary.totalNetSalary.toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: blue,
                  bgColor: blueLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Deductions',
                  value: 'LKR ${summary.totalDeductions.toStringAsFixed(0)}',
                  icon: Icons.trending_down_rounded,
                  iconColor: crimson,
                  bgColor: crimsonLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Employer EPF/ETF',
                  value: 'LKR ${(summary.totalEPFEmployer + summary.totalETFEmployer).toStringAsFixed(0)}',
                  icon: Icons.shield_rounded,
                  iconColor: amber,
                  bgColor: amberLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Itemized Payslips (${items.length})',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: slateDark),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            _buildEmptyState('No payslips found for this cycle.')
          else
            ...items.map((item) => _buildPayrollRow(item)),
        ],
      ),
    );
  }

  Widget _buildPayrollRow(PayrollReportItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: slateBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.employeeName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: slateDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'LKR ${item.netSalary.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: emerald),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${item.employeeCode} • ${item.departmentName} • ${item.branchName}',
            style: const TextStyle(fontSize: 11, color: slateMuted),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Base: ${item.baseSalary.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: slateMuted)),
              Text('Gross: ${item.grossEarnings.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: slateMuted)),
              Text('Ded: ${item.totalDeductions.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: crimson)),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: WORKFORCE HEADCOUNT
  // ==========================================

  Widget _buildHeadcountTab() {
    if (_isLoadingHeadcount) {
      return const Center(child: CircularProgressIndicator(color: violet));
    }
    if (_headcountError != null) {
      return _buildErrorView(_headcountError!, _loadHeadcount);
    }
    if (_headcountData == null) {
      return const Center(child: Text('No workforce data available.'));
    }

    final data = _headcountData!;

    return RefreshIndicator(
      color: violet,
      onRefresh: _loadHeadcount,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Total / Active / Inactive
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Total Workforce',
                  value: data.totalEmployees.toString(),
                  icon: Icons.people_alt_rounded,
                  iconColor: violet,
                  bgColor: violetLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Active Employees',
                  value: data.activeEmployees.toString(),
                  icon: Icons.person_pin_circle_rounded,
                  iconColor: emerald,
                  bgColor: emeraldLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Inactive',
                  value: data.inactiveEmployees.toString(),
                  icon: Icons.person_off_rounded,
                  iconColor: crimson,
                  bgColor: crimsonLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildDistributionSection('Branch Distribution', data.branchDistribution, violet),
          const SizedBox(height: 18),
          _buildDistributionSection('Department Distribution', data.departmentDistribution, blue),
          const SizedBox(height: 18),
          _buildDistributionSection('Designation Distribution', data.designationDistribution, emerald),
          const SizedBox(height: 18),
          _buildDistributionSection('Employment Type', data.employmentTypeDistribution, amber),
        ],
      ),
    );
  }

  Widget _buildDistributionSection(String title, List<DistributionItem> items, Color barColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: slateBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: slateDark),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text('No data found.', style: TextStyle(fontSize: 12, color: slateMuted))
          else
            ...items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name.isNotEmpty ? item.name : 'Unknown',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: slateDark),
                        ),
                        Text(
                          '${item.count} (${item.percentage.toStringAsFixed(1)}%)',
                          style: const TextStyle(fontSize: 12, color: slateMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (item.percentage / 100).clamp(0.0, 1.0),
                        backgroundColor: bgLight,
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ==========================================
  // REUSABLE HELPER WIDGETS
  // ==========================================

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: slateBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: slateDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: slateMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: crimson, size: 48),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: slateDark, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: violet,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: slateBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded, color: slateMuted, size: 36),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 13, color: slateMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
