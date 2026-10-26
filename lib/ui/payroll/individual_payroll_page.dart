import 'package:flutter/material.dart';
import '../../models/employee.dart';
import '../../models/payroll.dart';
import '../../services/employee_service.dart';
import '../../services/payroll_service.dart';
import '../../core/theme/app_colors.dart';

class IndividualPayrollPage extends StatefulWidget {
  final int? preselectedEmployeeId;

  const IndividualPayrollPage({super.key, this.preselectedEmployeeId});

  @override
  State<IndividualPayrollPage> createState() => _IndividualPayrollPageState();
}

class _IndividualPayrollPageState extends State<IndividualPayrollPage> {
  final EmployeeService _employeeService = EmployeeService();
  final PayrollService _payrollService = PayrollService();

  bool _loadingEmployees = true;
  bool _loadingPreview = false;
  bool _saving = false;

  List<Employee> _employees = [];
  Employee? _selectedEmployee;

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day);

  // Controllers & State
  final TextEditingController _baseSalaryCtrl = TextEditingController(text: '0');
  final TextEditingController _workingDaysCtrl = TextEditingController(text: '26');
  final TextEditingController _workedDaysCtrl = TextEditingController(text: '0');
  final TextEditingController _dailyRateCtrl = TextEditingController(text: '0');
  final TextEditingController _absentDaysCtrl = TextEditingController(text: '0');
  final TextEditingController _noPayDeductionCtrl = TextEditingController(text: '0');
  final TextEditingController _otHoursCtrl = TextEditingController(text: '0');
  final TextEditingController _otRateCtrl = TextEditingController(text: '0');
  final TextEditingController _otPayCtrl = TextEditingController(text: '0');

  bool _autoCalculateNoPay = true;
  bool _autoCalculateOt = true;
  final bool _deductEpf = false;
  final double _employeeEpfRate = 0.0;
  final double _employerEpfRate = 0.0;
  final double _employerEtfRate = 0.0;
  String _paymentStatus = 'Unpaid';

  List<PayrollManualItem> _allowances = [];
  List<PayrollManualItem> _deductions = [];

  EmployeePayrollPreview? _preview;

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _baseSalaryCtrl.dispose();
    _workingDaysCtrl.dispose();
    _workedDaysCtrl.dispose();
    _dailyRateCtrl.dispose();
    _absentDaysCtrl.dispose();
    _noPayDeductionCtrl.dispose();
    _otHoursCtrl.dispose();
    _otRateCtrl.dispose();
    _otPayCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() => _loadingEmployees = true);
    try {
      final list = await _employeeService.getAllEmployees();
      setState(() {
        _employees = list.where((e) => e.isActive).toList();
        _loadingEmployees = false;

        if (widget.preselectedEmployeeId != null) {
          _selectedEmployee = _employees.firstWhere(
            (e) => e.id == widget.preselectedEmployeeId,
            orElse: () => _employees.first,
          );
        } else if (_employees.isNotEmpty) {
          _selectedEmployee = _employees.first;
        }
      });

      if (_selectedEmployee != null) {
        _loadEmployeePreview();
      }
    } catch (e) {
      setState(() => _loadingEmployees = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load employees: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadEmployeePreview() async {
    if (_selectedEmployee == null) return;
    setState(() => _loadingPreview = true);

    try {
      final preview = await _payrollService.getEmployeePayrollPreview(
        _selectedEmployee!.id,
        year: _selectedYear,
        month: _selectedMonth,
        startDate: _formatDate(_startDate),
        endDate: _formatDate(_endDate),
      );

      setState(() {
        _preview = preview;
        _baseSalaryCtrl.text = preview.baseSalary.toStringAsFixed(2);
        _workingDaysCtrl.text = preview.workingDaysDivisor.toStringAsFixed(0);
        _workedDaysCtrl.text = preview.workedDays.toString();
        _dailyRateCtrl.text = preview.suggestedDailyRate.toStringAsFixed(2);
        _absentDaysCtrl.text = preview.detectedAbsentDays.toStringAsFixed(1);
        _noPayDeductionCtrl.text = preview.suggestedNoPayDeduction.toStringAsFixed(2);
        _otHoursCtrl.text = preview.otHours.toStringAsFixed(1);
        _otRateCtrl.text = preview.hourlyOtRate.toStringAsFixed(2);
        _otPayCtrl.text = preview.suggestedOtPay.toStringAsFixed(2);

        _allowances = List.from(preview.standardAllowances);
        _deductions = List.from(preview.standardDeductions);

        _loadingPreview = false;
      });
    } catch (e) {
      setState(() => _loadingPreview = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payroll preview: $e'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  void _onBaseSalaryOrDaysChanged() {
    final base = double.tryParse(_baseSalaryCtrl.text) ?? 0.0;
    final days = double.tryParse(_workingDaysCtrl.text) ?? 26.0;
    if (days > 0) {
      final rate = base / days;
      _dailyRateCtrl.text = rate.toStringAsFixed(2);

      if (_autoCalculateNoPay) {
        final absent = double.tryParse(_absentDaysCtrl.text) ?? 0.0;
        final noPay = absent * rate;
        _noPayDeductionCtrl.text = noPay.toStringAsFixed(2);
      }

      if (_autoCalculateOt) {
        final hourlyRate = (rate / 8.0) * 1.5;
        _otRateCtrl.text = hourlyRate.toStringAsFixed(2);
        final otHours = double.tryParse(_otHoursCtrl.text) ?? 0.0;
        _otPayCtrl.text = (otHours * hourlyRate).toStringAsFixed(2);
      }
    }
    setState(() {});
  }

  void _onAbsentDaysChanged() {
    if (_autoCalculateNoPay) {
      final absent = double.tryParse(_absentDaysCtrl.text) ?? 0.0;
      final rate = double.tryParse(_dailyRateCtrl.text) ?? 0.0;
      final noPay = absent * rate;
      _noPayDeductionCtrl.text = noPay.toStringAsFixed(2);
    }
    setState(() {});
  }

  void _onDailyRateChanged() {
    if (_autoCalculateNoPay) {
      final absent = double.tryParse(_absentDaysCtrl.text) ?? 0.0;
      final rate = double.tryParse(_dailyRateCtrl.text) ?? 0.0;
      final noPay = absent * rate;
      _noPayDeductionCtrl.text = noPay.toStringAsFixed(2);
    }
    if (_autoCalculateOt) {
      final rate = double.tryParse(_dailyRateCtrl.text) ?? 0.0;
      final hourlyRate = (rate / 8.0) * 1.5;
      _otRateCtrl.text = hourlyRate.toStringAsFixed(2);
      final otHours = double.tryParse(_otHoursCtrl.text) ?? 0.0;
      _otPayCtrl.text = (otHours * hourlyRate).toStringAsFixed(2);
    }
    setState(() {});
  }

  void _onOtChanged() {
    if (_autoCalculateOt) {
      final otHours = double.tryParse(_otHoursCtrl.text) ?? 0.0;
      final otRate = double.tryParse(_otRateCtrl.text) ?? 0.0;
      final totalOt = otHours * otRate;
      _otPayCtrl.text = totalOt.toStringAsFixed(2);
    }
    setState(() {});
  }

  // --- Real-time Calculations ---
  double get _baseSalary => double.tryParse(_baseSalaryCtrl.text) ?? 0.0;
  double get _overtimePay => double.tryParse(_otPayCtrl.text) ?? 0.0;
  double get _noPayDeduction => double.tryParse(_noPayDeductionCtrl.text) ?? 0.0;

  double get _totalAllowances => _allowances.fold(0.0, (sum, a) => sum + a.amount);
  double get _grossEarnings => _baseSalary + _totalAllowances + _overtimePay;

  double get _employeeEpf => 0.0;

  double get _totalCustomDeductions => _deductions.fold(0.0, (sum, d) => sum + d.amount);
  double get _totalDeductions => _noPayDeduction + _totalCustomDeductions;
  double get _netSalary {
    final net = _grossEarnings - _totalDeductions;
    return net > 0 ? net : 0.0;
  }

  // --- Add Allowance Dialog ---
  void _showAddAllowanceDialog() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    bool epf = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Allowance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Allowance Name',
                  hintText: 'e.g. Travel, Performance, Meal',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (Rs.)',
                  border: OutlineInputBorder(),
                  prefixText: 'Rs. ',
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Subject to EPF/ETF', style: TextStyle(fontSize: 14)),
                value: epf,
                onChanged: (val) => setDlgState(() => epf = val ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amountCtrl.text) ?? 0.0;
                if (nameCtrl.text.trim().isNotEmpty && amt > 0) {
                  setState(() {
                    _allowances.add(
                      PayrollManualItem(
                        name: nameCtrl.text.trim(),
                        amount: amt,
                        isEpfApplicable: epf,
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  // --- Add Deduction Dialog ---
  void _showAddDeductionDialog() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Deduction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Deduction Name',
                hintText: 'e.g. Salary Advance, Loan, Uniform',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (Rs.)',
                border: OutlineInputBorder(),
                prefixText: 'Rs. ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amountCtrl.text) ?? 0.0;
              if (nameCtrl.text.trim().isNotEmpty && amt > 0) {
                setState(() {
                  _deductions.add(
                    PayrollManualItem(
                      name: nameCtrl.text.trim(),
                      amount: amt,
                    ),
                  );
                });
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // --- Save Payslip ---
  Future<void> _savePayslip() async {
    if (_selectedEmployee == null) return;

    setState(() => _saving = true);

    try {
      final request = {
        'employeeId': _selectedEmployee!.id,
        'year': _selectedYear,
        'month': _selectedMonth,
        'startDate': _formatDate(_startDate),
        'endDate': _formatDate(_endDate),
        'workedDays': int.tryParse(_workedDaysCtrl.text) ?? 0,
        'baseSalary': _baseSalary,
        'workingDaysDivisor': double.tryParse(_workingDaysCtrl.text) ?? 26.0,
        'perDayRate': double.tryParse(_dailyRateCtrl.text) ?? 0.0,
        'noPayDays': double.tryParse(_absentDaysCtrl.text) ?? 0.0,
        'noPayDeduction': _noPayDeduction,
        'overtimeHours': double.tryParse(_otHoursCtrl.text) ?? 0.0,
        'overtimeRate': double.tryParse(_otRateCtrl.text) ?? 0.0,
        'overtimePay': _overtimePay,
        'deductEpf': _deductEpf,
        'employeeEpfRate': _employeeEpfRate,
        'employerEpfRate': _employerEpfRate,
        'employerEtfRate': _employerEtfRate,
        'allowances': _allowances.map((a) => a.toJson()).toList(),
        'deductions': _deductions.map((d) => d.toJson()).toList(),
        'paymentMode': 'Bank Transfer',
        'paymentStatus': _paymentStatus,
      };

      await _payrollService.saveIndividualPayroll(request);

      setState(() => _saving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Employee payroll saved successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Return back to the dashboard
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving payslip: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Individual Employee Payroll'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loadingEmployees
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Employee Selection & Period Card
                  _buildEmployeeSelectorCard(),

                  const SizedBox(height: 16),

                  if (_loadingPreview)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    // 2. Base Salary & No-Pay Rate Calculator
                    _buildSalaryCalculationCard(),

                    const SizedBox(height: 16),

                    // 3. Allowances (Earnings)
                    _buildAllowancesCard(),

                    const SizedBox(height: 16),

                    // 4. Overtime (Optional)
                    _buildOvertimeCard(),

                    const SizedBox(height: 16),

                    // 5. Deductions & No-Pay
                    _buildDeductionsCard(),

                    const SizedBox(height: 16),

                    // 6. EPF / ETF Settings
                    _buildEpfSettingsCard(),

                    const SizedBox(height: 20),

                    // 7. Dynamic Real-time Salary Summary Card
                    _buildSummaryCard(),

                    const SizedBox(height: 24),

                    // 8. Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _savePayslip,
                        icon: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(
                          _saving ? 'Saving Payslip...' : 'Save & Generate Payslip',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
    );
  }

  // Card 1: Employee and Period / Date Range Picker
  Widget _buildEmployeeSelectorCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employee & Salary Date Range',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 12),

            // Employee Dropdown
            DropdownButtonFormField<Employee>(
              initialValue: _selectedEmployee,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Select Employee *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              items: _employees.map((emp) {
                return DropdownMenuItem<Employee>(
                  value: emp,
                  child: Text(
                    '${emp.employeeCode} - ${emp.firstName} ${emp.lastName ?? ''}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedEmployee = val);
                  _loadEmployeePreview();
                }
              },
            ),

            const SizedBox(height: 14),

            // Date Range Presets
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ActionChip(
                  label: const Text('This Month', style: TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  onPressed: () {
                    final now = DateTime.now();
                    setState(() {
                      _selectedYear = now.year;
                      _selectedMonth = now.month;
                      _startDate = DateTime(now.year, now.month, 1);
                      _endDate = DateTime(now.year, now.month + 1, 0);
                    });
                    _loadEmployeePreview();
                  },
                ),
                ActionChip(
                  label: const Text('Last Month', style: TextStyle(fontSize: 12)),
                  backgroundColor: Colors.grey.shade200,
                  onPressed: () {
                    final now = DateTime.now();
                    final lastMonthDate = DateTime(now.year, now.month - 1, 1);
                    setState(() {
                      _selectedYear = lastMonthDate.year;
                      _selectedMonth = lastMonthDate.month;
                      _startDate = DateTime(lastMonthDate.year, lastMonthDate.month, 1);
                      _endDate = DateTime(lastMonthDate.year, lastMonthDate.month + 1, 0);
                    });
                    _loadEmployeePreview();
                  },
                ),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2030),
                      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked.start;
                        _endDate = picked.end;
                        _selectedYear = picked.start.year;
                        _selectedMonth = picked.start.month;
                      });
                      _loadEmployeePreview();
                    }
                  },
                  icon: const Icon(Icons.date_range, size: 18),
                  label: const Text('Custom Range', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Date Range Buttons
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked;
                          if (_endDate.isBefore(_startDate)) {
                            _endDate = _startDate;
                          }
                          _selectedYear = _startDate.year;
                          _selectedMonth = _startDate.month;
                        });
                        _loadEmployeePreview();
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'From Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today, size: 16),
                      ),
                      child: Text(
                        _formatDate(_startDate),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: _startDate,
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _endDate = picked;
                        });
                        _loadEmployeePreview();
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'To Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today, size: 16),
                      ),
                      child: Text(
                        _formatDate(_endDate),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_preview != null) ...[
              const SizedBox(height: 12),
              // Department & Branch
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.badge, size: 18, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_preview?.departmentName ?? 'Department'} • ${_preview?.designationName ?? 'Designation'}${_preview?.branchName != null ? ' • ${_preview!.branchName}' : ''}',
                        style: TextStyle(fontSize: 12.5, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Attendance & Holidays Detection Summary
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFC7EBD7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.analytics_outlined, size: 16, color: Color(0xFF107C41)),
                        SizedBox(width: 6),
                        Text(
                          'Attendance Detection in Selected Date Range',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF107C41)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _buildStatPill('Days Worked', '${_preview?.workedDays ?? 0}', Colors.teal.shade700),
                        _buildStatPill('No-Pay / Absent', _preview?.detectedAbsentDays.toStringAsFixed(1) ?? '0', Colors.red.shade700),
                        _buildStatPill('OT Detected', '${_preview?.otHours.toStringAsFixed(1) ?? '0'} hrs', Colors.indigo.shade700),
                        _buildStatPill('Holidays (Excluded)', '${_preview?.holidaysCount ?? 0}', Colors.purple.shade700),
                        _buildStatPill('Sundays (Excluded)', '${_preview?.sundaysCount ?? 0}', Colors.blueGrey.shade700),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  // Card 2: Basic Salary, Divisor, Worked Days & Per-Day Rate
  Widget _buildSalaryCalculationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payments, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Base Salary & Working Days',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Base Salary
            TextField(
              controller: _baseSalaryCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _onBaseSalaryOrDaysChanged(),
              decoration: const InputDecoration(
                labelText: 'Basic Salary (Rs.) *',
                hintText: 'Enter monthly basic salary',
                border: OutlineInputBorder(),
                prefixText: 'Rs. ',
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                // Days Worked (Manager can edit)
                Expanded(
                  child: TextField(
                    controller: _workedDaysCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Worked Days',
                      border: OutlineInputBorder(),
                      helperText: 'Manager can adjust',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Working Days Divisor
                Expanded(
                  child: TextField(
                    controller: _workingDaysCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _onBaseSalaryOrDaysChanged(),
                    decoration: const InputDecoration(
                      labelText: 'Divisor Days',
                      hintText: '26',
                      border: OutlineInputBorder(),
                      helperText: 'Standard: 26 days',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Daily Rate (Editable or auto-calculated)
            TextField(
              controller: _dailyRateCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _onDailyRateChanged(),
              decoration: const InputDecoration(
                labelText: 'Per-Day Rate (Rs.)',
                border: OutlineInputBorder(),
                prefixText: 'Rs. ',
                helperText: 'Base Salary ÷ Divisor Days (auto-calculated or manual)',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card 3: Allowances
  Widget _buildAllowancesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.add_circle_outline, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      'Allowances & Earnings',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, color: AppColors.primary, size: 28),
                  tooltip: 'Add Custom Allowance',
                  onPressed: _showAddAllowanceDialog,
                ),
              ],
            ),

            if (_allowances.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('No allowances added. Tap + to add.', style: TextStyle(color: Colors.grey.shade600)),
              )
            else
              ..._allowances.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    item.isEpfApplicable ? 'EPF/ETF Applicable' : 'Non-EPF',
                    style: TextStyle(fontSize: 11, color: item.isEpfApplicable ? Colors.green : Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+ Rs. ${item.amount.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                        onPressed: () => setState(() => _allowances.removeAt(idx)),
                      ),
                    ],
                  ),
                );
              }),

            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Allowances:', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  'Rs. ${_totalAllowances.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Card 4: Overtime Card
  Widget _buildOvertimeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.indigo),
                    const SizedBox(width: 8),
                    const Text(
                      'Overtime (OT)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Auto calculate', style: TextStyle(fontSize: 12)),
                    Switch(
                      value: _autoCalculateOt,
                      onChanged: (val) {
                        setState(() => _autoCalculateOt = val);
                        if (val) _onOtChanged();
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.indigo.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // OT Hours
                      Expanded(
                        child: TextField(
                          controller: _otHoursCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => _onOtChanged(),
                          decoration: const InputDecoration(
                            labelText: 'OT Hours',
                            border: OutlineInputBorder(),
                            helperText: 'From attendance',
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('×', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      // Hourly Rate
                      Expanded(
                        child: TextField(
                          controller: _otRateCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => _onOtChanged(),
                          decoration: const InputDecoration(
                            labelText: 'Hourly Rate',
                            border: OutlineInputBorder(),
                            prefixText: 'Rs. ',
                            helperText: 'Rate / Hour',
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('=', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      // Total OT Pay
                      Expanded(
                        child: TextField(
                          controller: _otPayCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Total OT Pay',
                            border: OutlineInputBorder(),
                            prefixText: 'Rs. ',
                            helperText: 'Hours × Rate',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Formula: OT Hours × Rate/Hr = Total OT Pay (Standard: Base ÷ Divisor ÷ 8 × 1.5). Manager can customize all values.',
                    style: TextStyle(fontSize: 11, color: Colors.indigo.shade800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card 5: Deductions & No-Pay
  Widget _buildDeductionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.remove_circle_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text(
                      'Deductions & No-Pay',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.red, size: 28),
                  tooltip: 'Add Custom Deduction',
                  onPressed: _showAddDeductionDialog,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // No Pay Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'No-Pay Deduction',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Row(
                        children: [
                          const Text('Auto calculate', style: TextStyle(fontSize: 12)),
                          Switch(
                            value: _autoCalculateNoPay,
                            onChanged: (val) {
                              setState(() => _autoCalculateNoPay = val);
                              if (val) _onAbsentDaysChanged();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _absentDaysCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => _onAbsentDaysChanged(),
                          decoration: const InputDecoration(
                            labelText: 'No-Pay Days',
                            border: OutlineInputBorder(),
                            helperText: 'Absent days',
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('×', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _dailyRateCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => _onDailyRateChanged(),
                          decoration: const InputDecoration(
                            labelText: 'Rate / Day',
                            border: OutlineInputBorder(),
                            prefixText: 'Rs. ',
                            helperText: 'Base ÷ Divisor',
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('=', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _noPayDeductionCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'No-Pay Deduction',
                            border: OutlineInputBorder(),
                            prefixText: 'Rs. ',
                            helperText: 'Days × Rate/Day',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Company Holidays & Sundays are automatically excluded from absent days. Manager can customize days, rate, or amount.',
                    style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Custom Deductions List
            if (_deductions.isNotEmpty) ...[
              const Text('Other Deductions:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ..._deductions.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '- Rs. ${item.amount.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 20),
                        onPressed: () => setState(() => _deductions.removeAt(idx)),
                      ),
                    ],
                  ),
                );
              }),
            ],

            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal (No-Pay + Other):', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  'Rs. ${(_noPayDeduction + _totalCustomDeductions).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Card 6: Statutory EPF / ETF (Removed as per requirements)
  Widget _buildEpfSettingsCard() => const SizedBox.shrink();

  // Card 7: Dynamic Real-time Salary Summary
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade900, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payslip Live Computation Summary',
            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),

          _summaryRow('Basic Salary', _baseSalary, Colors.white),
          if (_totalAllowances > 0) _summaryRow('Total Allowances', _totalAllowances, Colors.greenAccent),
          if (_overtimePay > 0) _summaryRow('Overtime Pay', _overtimePay, Colors.greenAccent),

          const Divider(color: Colors.white24),
          _summaryRow('GROSS EARNINGS', _grossEarnings, Colors.white, isBold: true),
          const Divider(color: Colors.white24),

          if (_noPayDeduction > 0) _summaryRow('No-Pay Deduction', -_noPayDeduction, Colors.orangeAccent),
          if (_employeeEpf > 0) _summaryRow('Employee EPF (8%)', -_employeeEpf, Colors.orangeAccent),
          if (_totalCustomDeductions > 0) _summaryRow('Other Deductions', -_totalCustomDeductions, Colors.orangeAccent),

          const Divider(color: Colors.white24),
          _summaryRow('TOTAL DEDUCTIONS', -_totalDeductions, Colors.redAccent, isBold: true),
          const Divider(color: Colors.white38, thickness: 1.5),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NET SALARY',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rs. ${_netSalary.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment Status:', style: TextStyle(color: Colors.white70)),
              DropdownButton<String>(
                value: _paymentStatus,
                dropdownColor: Colors.indigo.shade900,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                underline: const SizedBox.shrink(),
                items: ['Unpaid', 'Paid'].map((st) {
                  return DropdownMenuItem(value: st, child: Text(st));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _paymentStatus = val);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double amount, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.white : Colors.white70,
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'Rs. ${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
