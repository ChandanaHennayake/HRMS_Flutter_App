import 'package:flutter/material.dart';
import '../../core/storage/secure_storage.dart';
import '../../models/payroll.dart';
import '../../services/payroll_service.dart';
import 'payslip_page.dart';

class MyPayslipsPage extends StatefulWidget {
  final int? employeeId;

  const MyPayslipsPage({
    super.key,
    this.employeeId,
  });

  @override
  State<MyPayslipsPage> createState() => _MyPayslipsPageState();
}

class _MyPayslipsPageState extends State<MyPayslipsPage> {
  final PayrollService _payrollService = PayrollService();

  bool _isLoading = true;
  String? _errorMessage;
  List<PayslipSummary> _payslips = [];

  // Palette
  static const Color violet = Color(0xFF6B21A8);
  static const Color emeraldDark = Color(0xFF047857);
  static const Color slateDark = Color(0xFF0F172A);
  static const Color slateMuted = Color(0xFF64748B);
  static const Color slateBorder = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _loadPayslips();
  }

  Future<void> _loadPayslips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      int? empId = widget.employeeId;
      if (empId == null || empId <= 0) {
        empId = await SecureStorage.getEmployeeId();
      }

      if (empId == null || empId <= 0) {
        throw Exception('Employee profile could not be identified.');
      }

      final list = await _payrollService.getEmployeePayslips(empId);

      if (!mounted) return;
      setState(() {
        _payslips = list;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text(
          'My Payslips',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: slateDark,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _payslips.isEmpty
                  ? _buildEmptyView()
                  : _buildPayslipsList(),
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
              _errorMessage ?? 'Failed to load payslips.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: slateDark, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPayslips,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: violet,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_outlined, color: violet, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Payslips Available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: slateDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your monthly payroll runs and itemized payslips will appear here once published by HR.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: slateMuted),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _loadPayslips,
              icon: const Icon(Icons.refresh, size: 18, color: violet),
              label: const Text('Refresh', style: TextStyle(color: violet)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD6C2EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayslipsList() {
    return RefreshIndicator(
      onRefresh: _loadPayslips,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _payslips.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = _payslips[index];
          final bool isPaid = item.paymentStatus.toLowerCase() == 'paid';

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PayslipPage(
                    payslipId: item.id,
                    title: 'Payslip #${item.id}',
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.receipt_rounded, color: violet, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.employeeName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: slateDark,
                                ),
                              ),
                              Text(
                                item.employeeCode,
                                style: const TextStyle(fontSize: 11.5, color: slateMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? const Color(0xFFE8F8F0)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.paymentStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isPaid ? emeraldDark : const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: slateBorder),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gross Earnings', style: TextStyle(fontSize: 11, color: slateMuted)),
                          const SizedBox(height: 2),
                          Text(
                            'LKR ${item.grossEarnings.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: slateDark),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Deductions', style: TextStyle(fontSize: 11, color: slateMuted)),
                          const SizedBox(height: 2),
                          Text(
                            'LKR ${item.totalDeductions.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.redAccent),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Net Salary', style: TextStyle(fontSize: 11, color: slateMuted)),
                          const SizedBox(height: 2),
                          Text(
                            'LKR ${item.netSalary.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: emeraldDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'View Itemized Breakdown',
                        style: TextStyle(fontSize: 11.5, color: violet, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, size: 16, color: violet),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
