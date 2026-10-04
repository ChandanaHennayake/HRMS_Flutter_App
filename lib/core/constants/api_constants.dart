class ApiConstants {
  static const String baseUrl = 'http://172.20.10.5:5000';

  

  static const String login = '/api/Authentication/login';

    static const String checkIn =
      '/api/Attendance/check-in';

  static const String checkOut =
      '/api/Attendance/check-out';

  static const String attendanceHistory =
      '/api/Attendance/history';

  static const String todayAttendance =
      '/api/Attendance/today';




static const String leaveTypes = '/api/LeaveType';

static const String applyLeave = '/api/Leave/apply';

static const String leaveEmployee = '/api/Leave/employee';

static const String pendingLeaves = '/api/Leave/pending';

static String approveLeave(int id) =>
    '/api/Leave/$id/approve';

static String rejectLeave(int id) =>
    '/api/Leave/$id/reject';

static String cancelLeave(int id) =>
    '/api/Leave/$id/cancel';


      // ============================================================
  // EMPLOYEE
  // ============================================================

  static const String employees =
      '/api/Employee';
}