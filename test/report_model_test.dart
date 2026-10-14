import 'package:flutter_test/flutter_test.dart';
import 'package:alionhr/models/report.dart';

void main() {
  group('Report Models Parsing Tests', () {
    test('AttendanceReportResponse deserializes correctly', () {
      final json = {
        'summary': {
          'totalRecords': 50,
          'presentCount': 45,
          'lateCount': 5,
          'absentCount': 3,
          'earlyDepartureCount': 2,
          'totalWorkedHours': 390.5,
          'totalOvertimeHours': 22.0,
          'punctualityRate': 90.0,
        },
        'items': [
          {
            'date': '2026-10-14T00:00:00',
            'employeeId': 101,
            'employeeCode': 'EMP001',
            'employeeName': 'Kasun Perera',
            'branchName': 'Head Office',
            'departmentName': 'Engineering',
            'checkInTime': '2026-10-14T08:25:00',
            'checkOutTime': '2026-10-14T17:15:00',
            'workedHours': 8.8,
            'isLate': false,
            'lateMinutes': 0,
            'otMinutes': 45,
            'status': 'Present',
          }
        ]
      };

      final response = AttendanceReportResponse.fromJson(json);

      expect(response.summary.totalRecords, 50);
      expect(response.summary.presentCount, 45);
      expect(response.summary.punctualityRate, 90.0);
      expect(response.items.length, 1);
      expect(response.items.first.employeeName, 'Kasun Perera');
      expect(response.items.first.otMinutes, 45);
    });

    test('LeaveReportResponse deserializes breakdown correctly', () {
      final json = {
        'summary': {
          'totalRequests': 12,
          'approvedDays': 18.5,
          'pendingDays': 3.0,
          'rejectedDays': 1.0,
          'paidDays': 15.5,
          'unpaidDays': 3.0,
          'byTypeBreakdown': {
            'Annual Leave': 10.0,
            'Casual Leave': 5.5,
            'Medical Leave': 3.0,
          }
        },
        'items': [
          {
            'id': 1,
            'employeeId': 101,
            'employeeCode': 'EMP001',
            'employeeName': 'Kasun Perera',
            'branchName': 'Head Office',
            'leaveTypeName': 'Annual Leave',
            'fromDate': '2026-10-20',
            'toDate': '2026-10-22',
            'totalDays': 3.0,
            'isPaid': true,
            'status': 'Approved',
          }
        ]
      };

      final response = LeaveReportResponse.fromJson(json);

      expect(response.summary.totalRequests, 12);
      expect(response.summary.approvedDays, 18.5);
      expect(response.summary.byTypeBreakdown['Annual Leave'], 10.0);
      expect(response.items.first.status, 'Approved');
      expect(response.items.first.totalDays, 3.0);
    });

    test('PayrollReportResponse deserializes statutory totals correctly', () {
      final json = {
        'summary': {
          'periodName': 'October 2026',
          'employeeCount': 25,
          'totalBasicSalary': 2000000.0,
          'totalGrossSalary': 2350000.0,
          'totalDeductions': 280000.0,
          'totalNetSalary': 2070000.0,
          'totalEPFEmployer': 240000.0,
          'totalETFEmployer': 60000.0,
          'totalCompanyCost': 2650000.0,
        },
        'items': [
          {
            'payslipId': 10,
            'employeeCode': 'EMP001',
            'employeeName': 'Kasun Perera',
            'branchName': 'Head Office',
            'departmentName': 'Engineering',
            'baseSalary': 120000.0,
            'grossEarnings': 140000.0,
            'totalDeductions': 18000.0,
            'netSalary': 122000.0,
            'paymentStatus': 'Paid',
          }
        ]
      };

      final response = PayrollReportResponse.fromJson(json);

      expect(response.summary.employeeCount, 25);
      expect(response.summary.totalCompanyCost, 2650000.0);
      expect(response.items.first.netSalary, 122000.0);
    });

    test('HeadcountReport parses branch and department distributions', () {
      final json = {
        'totalEmployees': 100,
        'activeEmployees': 95,
        'inactiveEmployees': 5,
        'branchDistribution': [
          {'name': 'Head Office', 'count': 60, 'percentage': 60.0},
          {'name': 'Colombo Branch', 'count': 40, 'percentage': 40.0},
        ],
        'departmentDistribution': [
          {'name': 'Engineering', 'count': 45, 'percentage': 45.0},
          {'name': 'HR', 'count': 15, 'percentage': 15.0},
        ],
        'designationDistribution': [],
        'employmentTypeDistribution': []
      };

      final report = HeadcountReport.fromJson(json);

      expect(report.totalEmployees, 100);
      expect(report.activeEmployees, 95);
      expect(report.branchDistribution.length, 2);
      expect(report.branchDistribution.first.name, 'Head Office');
      expect(report.branchDistribution.first.count, 60);
      expect(report.departmentDistribution.first.percentage, 45.0);
    });
  });
}
