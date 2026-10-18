import 'package:flutter/material.dart';
import '../../models/payroll.dart';
import '../../services/payroll_service.dart';

class PayslipPage extends StatefulWidget {
  final int payslipId;
  final String? title;

  const PayslipPage({
    super.key,
    required this.payslipId,
    this.title,
  });

  @override
  State<PayslipPage> createState() => _PayslipPageState();
}

class _PayslipPageState extends State<PayslipPage> {
  final PayrollService _payrollService = PayrollService();
  bool _isLoading = true;
  String? _errorMessage;
  Payslip? _payslip;

  // Premium corporate palette
  static const Color violet = Color(0xFF6B21A8);
  static const Color emeraldDark = Color(0xFF047857);
  static const Color crimson = Color(0xFFDC2626);
  static const Color slateDark = Color(0xFF0F172A);
  static const Color slateMuted = Color(0xFF64748B);
  static const Color slateBorder = Color(0xFFE2E8F0);
  static const Color slateCard = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _loadPayslip();
  }

  Future<void> _loadPayslip() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final slip = await _payrollService.getPayslipDetails(widget.payslipId);
      if (!mounted) return;
      setState(() {
        _payslip = slip;
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

  Future<void> _deletePayslip() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Payslip'),
        content: const Text('Are you sure you want to delete this payslip record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: crimson, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _payrollService.deletePayslip(widget.payslipId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payslip deleted successfully.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e'), backgroundColor: crimson),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Text(
          widget.title ?? (_payslip != null ? 'Payslip - ${_payslip!.periodName}' : 'Salary Payslip'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: slateDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: crimson),
            onPressed: _deletePayslip,
            tooltip: 'Delete Payslip',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadPayslip,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _payslip == null
                  ? const Center(child: Text('Payslip not found'))
                  : _buildPayslipContent(_payslip!),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: crimson, size: 48),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Failed to load payslip',
              textAlign: TextAlign.center,
              style: const TextStyle(color: slateDark, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPayslip,
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

  Widget _buildPayslipContent(Payslip slip) {
    final bool isPaid = slip.paymentStatus.toLowerCase() == 'paid';

    return RefreshIndicator(
      onRefresh: _loadPayslip,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // Company Header Banner
            _buildCompanyHeader(slip),
            const SizedBox(height: 16),

            // Net Pay Hero Card
            _buildNetPayHero(slip, isPaid),
            const SizedBox(height: 16),

            // Employee & Period Details
            _buildEmployeeDetailsCard(slip),
            const SizedBox(height: 16),

            // Earnings Card
            _buildEarningsCard(slip),
            const SizedBox(height: 16),

            // Deductions Card
            _buildDeductionsCard(slip),
            const SizedBox(height: 16),

            // Statutory EPF / ETF Employer Contributions Card
            if (slip.employerEpf > 0 || slip.employerEtf > 0) ...[
              _buildStatutoryEmployerCard(slip),
              const SizedBox(height: 16),
            ],

            // Corporate Footer Note
            _buildFooterNote(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyHeader(Payslip slip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: slateBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B21A8), Color(0xFF9333EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.corporate_fare_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AlienHR Enterprise',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: slateDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Pay Period: ${slip.periodName} (${slip.periodStartDate} to ${slip.periodEndDate})',
                  style: const TextStyle(
                    fontSize: 12,
                    color: slateMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetPayHero(Payslip slip, bool isPaid) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPaid
              ? [const Color(0xFF047857), const Color(0xFF10B981)]
              : [const Color(0xFF4C1D95), const Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isPaid ? Colors.green : Colors.purple).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
                'TAKE-HOME NET SALARY',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  slip.paymentStatus.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'LKR ${slip.netSalary.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_rounded, color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Text(
                  '${slip.paymentMode} • ${slip.bankName ?? "Bank"} (${slip.bankAccountNo ?? "N/A"})',
                  style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeDetailsCard(Payslip slip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: slateBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Employee Information',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: slateDark),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: slateBorder),
          const SizedBox(height: 12),
          _detailRow('Employee Name', slip.employeeName),
          _detailRow('Employee Code', slip.employeeCode),
          _detailRow('Department', slip.departmentName ?? 'General'),
          _detailRow('Designation', slip.designationName ?? 'Staff'),
          if (slip.branchName != null && slip.branchName!.isNotEmpty)
            _detailRow('Branch', slip.branchName!),
          _detailRow('Payment Mode', slip.paymentMode),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(Payslip slip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: slateBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.add_circle_outline_rounded, color: emeraldDark, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Earnings & Allowances',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: slateDark),
                  ),
                ],
              ),
              Text(
                'LKR ${slip.grossEarnings.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: emeraldDark),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: slateBorder),
          const SizedBox(height: 12),
          _itemRow('Basic Salary', slip.baseSalary),
          if (slip.totalAllowances > 0)
            _itemRow('Allowances', slip.totalAllowances),
          if (slip.overtimePay > 0)
            _itemRow('Overtime Pay (${slip.overtimeHours.toStringAsFixed(1)} hrs)', slip.overtimePay),
          ...slip.earnings.map((e) => _itemRow(e.name, e.amount)),
          const SizedBox(height: 8),
          const Divider(height: 1, color: slateBorder),
          const SizedBox(height: 8),
          _itemRow('Gross Earnings', slip.grossEarnings, isBold: true, textColor: emeraldDark),
        ],
      ),
    );
  }

  Widget _buildDeductionsCard(Payslip slip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: slateBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.remove_circle_outline_rounded, color: crimson, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Deductions & Statutory',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: slateDark),
                  ),
                ],
              ),
              Text(
                'LKR ${slip.totalDeductions.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: crimson),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: slateBorder),
          const SizedBox(height: 12),
          if (slip.noPayDeduction > 0)
            _itemRow('No-Pay (${slip.noPayDays.toStringAsFixed(1)} days)', slip.noPayDeduction),
          if (slip.employeeEpf > 0)
            _itemRow('Employee EPF (8%)', slip.employeeEpf),
          if (slip.apitTax > 0)
            _itemRow('APIT (PAYE Tax)', slip.apitTax),
          if (slip.otherDeductions > 0)
            _itemRow('Other Deductions', slip.otherDeductions),
          ...slip.deductions.map((d) => _itemRow(d.name, d.amount)),
          const SizedBox(height: 8),
          const Divider(height: 1, color: slateBorder),
          const SizedBox(height: 8),
          _itemRow('Total Deductions', slip.totalDeductions, isBold: true, textColor: crimson),
        ],
      ),
    );
  }

  Widget _buildStatutoryEmployerCard(Payslip slip) {
    final double totalEmployerContrib = slip.employerEpf + slip.employerEtf;
    final double totalCompanyCost = slip.grossEarnings + totalEmployerContrib;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: slateCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: violet, size: 18),
              SizedBox(width: 8),
              Text(
                'Employer Statutory Contributions (Not Deducted)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: slateDark),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: slateBorder),
          const SizedBox(height: 12),
          _itemRow('EPF Employer (12%)', slip.employerEpf),
          _itemRow('ETF Employer (3%)', slip.employerEtf),
          _itemRow('Total Statutory Contribution', totalEmployerContrib, isBold: true),
          const SizedBox(height: 8),
          const Divider(height: 1, color: slateBorder),
          const SizedBox(height: 8),
          _itemRow('Total Cost to Company (CTC)', totalCompanyCost, isBold: true, textColor: violet),
        ],
      ),
    );
  }

  Widget _buildFooterNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: slateBorder),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: slateMuted, size: 16),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This is a computer-generated payslip produced by AlienHR. Please contact the HR department for any inquiries regarding salary disbursements.',
              style: TextStyle(color: slateMuted, fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: slateMuted, fontSize: 12.5)),
          Text(value, style: const TextStyle(color: slateDark, fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _itemRow(String label, double amount, {bool isBold = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? slateDark : slateMuted,
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'LKR ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: textColor ?? (isBold ? slateDark : slateDark),
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
