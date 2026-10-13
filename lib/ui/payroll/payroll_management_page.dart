import 'package:flutter/material.dart';
import '../../models/payroll.dart';
import '../../services/payroll_service.dart';
import 'payslip_page.dart';

class PayrollManagementPage extends StatefulWidget {
  final int companyId;
  final int? branchId;
  final String? branchName;

  const PayrollManagementPage({
    super.key,
    this.companyId = 1,
    this.branchId,
    this.branchName,
  });

  @override
  State<PayrollManagementPage> createState() => _PayrollManagementPageState();
}

class _PayrollManagementPageState extends State<PayrollManagementPage> {
  final PayrollService _payrollService = PayrollService();

  bool _isLoading = true;
  String? _errorMessage;
  List<PayrollRun> _runs = [];

  // Theme colors
  static const Color violet = Color(0xFF6B21A8);
  static const Color emeraldDark = Color(0xFF047857);
  static const Color slateDark = Color(0xFF0F172A);
  static const Color slateMuted = Color(0xFF64748B);
  static const Color slateBorder = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _loadRuns();
  }

  Future<void> _loadRuns() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final runs = await _payrollService.getPayrollRuns(
        companyId: widget.companyId,
        branchId: widget.branchId,
      );
      if (!mounted) return;
      setState(() {
        _runs = runs;
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

  Future<void> _updateRunStatus(PayrollRun run, int newStatus, String actionName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$actionName Payroll'),
        content: Text(
          'Are you sure you want to transition period "${run.periodName}" to ${newStatus == 1 ? "Under Review" : newStatus == 2 ? "Approved" : "Published"}?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: violet),
            child: Text(actionName),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _payrollService.updatePayrollStatus(run.id, newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payroll transitioned to $actionName successfully.')),
      );
      _loadRuns();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}')),
      );
    }
  }

  Future<void> _showProcessDialog() async {
    int selectedYear = DateTime.now().year;
    int selectedMonth = DateTime.now().month;
    double divisor = 26;
    final commentsCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: const Text('Process Payroll Run', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Period Year & Month', style: TextStyle(fontSize: 12, color: slateMuted)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: selectedYear,
                        decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder()),
                        items: [2025, 2026, 2027].map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                        onChanged: (v) {
                          if (v != null) setDlgState(() => selectedYear = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: selectedMonth,
                        decoration: const InputDecoration(labelText: 'Month', border: OutlineInputBorder()),
                        items: List.generate(12, (i) => i + 1).map((m) => DropdownMenuItem(value: m, child: Text('M$m'))).toList(),
                        onChanged: (v) {
                          if (v != null) setDlgState(() => selectedMonth = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: '26',
                  decoration: const InputDecoration(labelText: 'Working Days Divisor', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    final d = double.tryParse(v);
                    if (d != null && d > 0) divisor = d;
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: commentsCtrl,
                  decoration: const InputDecoration(labelText: 'Comments (Optional)', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(ctx);
                try {
                  await _payrollService.processPayroll({
                    'companyId': widget.companyId,
                    'branchId': widget.branchId,
                    'year': selectedYear,
                    'month': selectedMonth,
                    'workingDaysDivisor': divisor,
                    'comments': commentsCtrl.text.trim(),
                  });
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Payroll processed successfully as Draft!')),
                  );
                  _loadRuns();
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed: ${e.toString().replaceAll("Exception: ", "")}')),
                  );
                }
              },
              style: FilledButton.styleFrom(backgroundColor: violet),
              child: const Text('Process Now'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Text(
          widget.branchName != null ? 'Payroll - ${widget.branchName}' : 'Payroll Management',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: slateDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showProcessDialog,
            tooltip: 'Process Payroll',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadRuns,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _runs.isEmpty
                  ? _buildEmptyView()
                  : _buildRunsList(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Failed to load payroll runs.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: slateDark, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadRuns,
              icon: const Icon(Icons.refresh, size: 18),
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

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF3E8FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet_outlined, color: violet, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Payroll Runs Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: slateDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Process automated payroll batches with EPF/ETF statutory calculations.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: slateMuted),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _showProcessDialog,
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Process First Run'),
              style: FilledButton.styleFrom(backgroundColor: violet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunsList() {
    return RefreshIndicator(
      onRefresh: _loadRuns,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _runs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final run = _runs[index];
          return _buildRunCard(run);
        },
      ),
    );
  }

  Widget _buildRunCard(PayrollRun run) {
    Color badgeBg;
    Color badgeFg;
    switch (run.status) {
      case 0: // Draft
        badgeBg = const Color(0xFFF1F5F9);
        badgeFg = const Color(0xFF475569);
        break;
      case 1: // Under Review
        badgeBg = const Color(0xFFFEF3C7);
        badgeFg = const Color(0xFFB45309);
        break;
      case 2: // Approved
        badgeBg = const Color(0xFFDBEAFE);
        badgeFg = const Color(0xFF1D4ED8);
        break;
      case 3: // Published
      default:
        badgeBg = const Color(0xFFDCFCE7);
        badgeFg = const Color(0xFF15803D);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: slateBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    run.periodName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: slateDark,
                    ),
                  ),
                  if (run.branchName != null)
                    Text(
                      'Branch: ${run.branchName}',
                      style: const TextStyle(fontSize: 11.5, color: slateMuted),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  run.statusName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: badgeFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: slateBorder),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metricCol('Employees', '${run.processedCount}'),
              _metricCol('Gross Total', 'LKR ${run.totalGross.toStringAsFixed(0)}'),
              _metricCol('Net Payout', 'LKR ${run.totalNet.toStringAsFixed(0)}', isBold: true, color: emeraldDark),
            ],
          ),
          const SizedBox(height: 14),

          // Workflow Action Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (run.status == 0) // Draft -> Review
                OutlinedButton.icon(
                  onPressed: () => _updateRunStatus(run, 1, 'Submit for Review'),
                  icon: const Icon(Icons.send_rounded, size: 14, color: violet),
                  label: const Text('Submit for Review', style: TextStyle(fontSize: 11.5, color: violet)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD6C2EB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              if (run.status == 1) // Review -> Approve
                FilledButton.icon(
                  onPressed: () => _updateRunStatus(run, 2, 'Approve'),
                  icon: const Icon(Icons.check_circle_outline, size: 14),
                  label: const Text('Approve Run', style: TextStyle(fontSize: 11.5)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              if (run.status == 2) // Approved -> Publish
                FilledButton.icon(
                  onPressed: () => _updateRunStatus(run, 3, 'Publish & Disburse'),
                  icon: const Icon(Icons.publish_rounded, size: 14),
                  label: const Text('Publish Payslips', style: TextStyle(fontSize: 11.5)),
                  style: FilledButton.styleFrom(
                    backgroundColor: emeraldDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () => _viewRunPayslips(run),
                icon: const Icon(Icons.receipt_long_outlined, size: 14, color: slateDark),
                label: const Text('View Payslips', style: TextStyle(fontSize: 11.5, color: slateDark)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: slateBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _viewRunPayslips(PayrollRun run) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => FutureBuilder<PayrollRun?>(
          future: _payrollService.getPayrollRunDetails(run.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final details = snapshot.data;
            if (details == null || details.payslips.isEmpty) {
              return const Center(child: Text('No payslips generated for this run.'));
            }

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: slateBorder)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payslips - ${details.periodName}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${details.payslips.length} Employees',
                        style: const TextStyle(color: slateMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: details.payslips.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: slateBorder),
                    itemBuilder: (context, idx) {
                      final slip = details.payslips[idx];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          slip.employeeName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                        ),
                        subtitle: Text(
                          '${slip.employeeCode} • ${slip.designationName ?? "Staff"}',
                          style: const TextStyle(fontSize: 11.5, color: slateMuted),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'LKR ${slip.netSalary.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: emeraldDark,
                              ),
                            ),
                            Text(
                              slip.paymentStatus,
                              style: const TextStyle(fontSize: 10.5, color: slateMuted),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PayslipPage(payslipId: slip.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _metricCol(String title, String val, {bool isBold = false, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 10.5, color: slateMuted)),
        const SizedBox(height: 3),
        Text(
          val,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? slateDark,
          ),
        ),
      ],
    );
  }
}
