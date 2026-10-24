import 'package:alionhr/ui/attendance/attendance_history_page.dart';
import 'package:flutter/material.dart';

import '../../../core/location/location_service.dart';
import '../../../models/holiday.dart';
import '../../../models/user.dart';
import '../../../services/attendance_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/holiday_service.dart';
import '../../../services/user_service.dart';
import '../../auth/login_view.dart';
import '../../holiday/holidays_page.dart';
import '../../leave/leave_page.dart';
import '../../notification/notification_bell.dart';
import '../../payroll/my_payslips_page.dart';
import '../../profile/profile_page.dart';

class EmployeeDashboard extends StatefulWidget {
  final User user;

  const EmployeeDashboard({
    super.key,
    required this.user,
  });

  @override
  State<EmployeeDashboard> createState() =>
      _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  static const Color deepDark = Color(0xFF0B0614);
  static const Color violet = Color(0xFF7C2FCE);
  static const Color brightViolet = Color(0xFFA855F7);
  static const Color background = Color(0xFFF7F5FA);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);

  final AttendanceService _attendanceService =
      AttendanceService();

  final LocationService _locationService =
      LocationService();

  final HolidayService _holidayService =
      HolidayService();

  Holiday? _upcomingHoliday;

  int selectedIndex = 0;

  bool isCheckedIn = false;
  bool isCheckedOut = false;
  bool isAttendanceLoading = false;

  String checkInTime = '--:--';
  String checkOutTime = '--:--';

  String workedTime = '00h 00m';
  String overtime = '00h 00m';

  final UserService _userService =
      UserService();

  String currentLocationText =
      'GPS location will be captured when marking attendance';

  String branchName = 'Assigned Branch';

  @override
  void initState() {
    super.initState();
    branchName = (widget.user.branchName != null &&
            widget.user.branchName!.trim().isNotEmpty)
        ? widget.user.branchName!
        : 'Assigned Branch';
    _loadTodayAttendance();
    _loadUpcomingHoliday();
    _loadBranchInfo();
  }

  Future<void> _loadBranchInfo() async {
    if (widget.user.userId <= 0) return;
    try {
      final profile = await _userService.getUserProfile(widget.user.userId);
      if (!mounted) return;
      if (profile.branchName != null && profile.branchName!.trim().isNotEmpty) {
        setState(() {
          branchName = profile.branchName!;
        });
      }
    } catch (_) {
      // Keep existing branchName if profile fetch fails
    }
  }

  // ============================================================
  // LOAD TODAY ATTENDANCE
  // ============================================================

  Future<void> _loadTodayAttendance() async {
    if (widget.user.employeeId <= 0) return;

    try {
      final attendance = await _attendanceService.getTodayAttendance(
        employeeId: widget.user.employeeId,
      );

      if (!mounted) return;

      if (attendance != null) {
        setState(() {
          if (attendance.checkInTime != null) {
            checkInTime = _formatTime(attendance.checkInTime!);
          }
          if (attendance.checkOutTime != null) {
            checkOutTime = _formatTime(attendance.checkOutTime!);
            isCheckedIn = false;
            isCheckedOut = true;
          } else if (attendance.checkInTime != null) {
            isCheckedIn = true;
            isCheckedOut = false;
          }

          final hours = attendance.workedMinutes ~/ 60;
          final mins = attendance.workedMinutes % 60;
          workedTime =
              '${hours.toString().padLeft(2, '0')}h ${mins.toString().padLeft(2, '0')}m';

          final otHours = attendance.otMinutes ~/ 60;
          final otMins = attendance.otMinutes % 60;
          overtime =
              '${otHours.toString().padLeft(2, '0')}h ${otMins.toString().padLeft(2, '0')}m';
        });
      }
    } catch (_) {
      // Keep defaults if failed to load
    }
  }

  Future<void> _loadUpcomingHoliday() async {
    try {
      final holiday = await _holidayService.getUpcomingHoliday();
      if (!mounted) return;
      setState(() {
        _upcomingHoliday = holiday;
      });
    } catch (_) {
      // Keep defaults if failed to load
    }
  }

  String _formatHolidayDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(DateTime time) {
    final localTime = time.toLocal();
    final hour = localTime.hour % 12 == 0 ? 12 : localTime.hour % 12;
    final period = localTime.hour >= 12 ? 'PM' : 'AM';
    final minute = localTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  // ============================================================
  // CHECK IN
  // ============================================================

  Future<void> _checkIn() async {
    if (isAttendanceLoading) return;

    if (widget.user.employeeId <= 0) {
      _showError(
        'Employee ID is not available for this account.',
      );
      return;
    }

    setState(() {
      isAttendanceLoading = true;
      currentLocationText =
          'Getting current GPS location...';
    });

    try {
      // Get current GPS location
      final position =
          await _locationService.getCurrentLocation();

      if (!mounted) return;

      final employeeId = widget.user.employeeId;
      final latitude = position.latitude;
      final longitude = position.longitude;

      setState(() {
        currentLocationText =
            '${latitude.toStringAsFixed(6)}, '
            '${longitude.toStringAsFixed(6)}';
      });

      // Confirm before sending
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Confirm Check In'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Employee ID: $employeeId',
                ),
                const SizedBox(height: 10),
                Text(
                  'Latitude: ${latitude.toStringAsFixed(6)}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Longitude: ${longitude.toStringAsFixed(6)}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    false,
                  );
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    true,
                  );
                },
                child: const Text('Check In'),
              ),
            ],
          );
        },
      );

      if (confirmed != true) {
        return;
      }

      // Send to API
      await _attendanceService.checkIn(
        employeeId: employeeId,
        latitude: latitude,
        longitude: longitude,
        deviceTime: DateTime.now(),
      );

      await _loadTodayAttendance();

      if (!mounted) return;

      _showSuccess(
        'Checked in successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showError(
        _cleanError(e),
      );
    } finally {
      if (mounted) {
        setState(() {
          isAttendanceLoading = false;
        });
      }
    }
  }

  // ============================================================
  // CHECK OUT
  // ============================================================

  Future<void> _checkOut() async {
    if (isAttendanceLoading) return;

    if (widget.user.employeeId <= 0) {
      _showError(
        'Employee ID is not available for this account.',
      );
      return;
    }

    setState(() {
      isAttendanceLoading = true;
      currentLocationText =
          'Getting current GPS location...';
    });

    try {
      final position =
          await _locationService.getCurrentLocation();

      if (!mounted) return;

      final latitude = position.latitude;
      final longitude = position.longitude;

      setState(() {
        currentLocationText =
            '${latitude.toStringAsFixed(6)}, '
            '${longitude.toStringAsFixed(6)}';
      });

      await _attendanceService.checkOut(
        employeeId: widget.user.employeeId,
        latitude: latitude,
        longitude: longitude,
        deviceTime: DateTime.now(),
      );

      await _loadTodayAttendance();

      if (!mounted) return;

      _showSuccess(
        'Checked out successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showError(
        _cleanError(e),
      );
    } finally {
      if (mounted) {
        setState(() {
          isAttendanceLoading = false;
        });
      }
    }
  }

  // ============================================================
  // ATTENDANCE ACTION
  // ============================================================

  Future<void> _attendanceAction() async {
    if (isAttendanceLoading) return;

    if (isCheckedOut) {
      _showMessage('You have already completed attendance for today.');
      return;
    }

    if (isCheckedIn) {
      await _checkOut();
    } else {
      await _checkIn();
    }
  }

  // ============================================================
  // OPEN LEAVE PAGE
  // ============================================================

  Future<void> _openLeavePage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LeavePage(
          user: widget.user,
        ),
      ),
    );
  }


// ============================================================
// OPEN ATTENDANCE HISTORY
// ============================================================

Future<void> _openAttendanceHistory() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AttendanceHistoryPage(
        user: widget.user,
      ),
    ),
  );
}

// ============================================================
// OPEN HOLIDAYS PAGE
// ============================================================

Future<void> _openHolidaysPage() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => HolidaysPage(
        user: widget.user,
      ),
    ),
  );
  _loadUpcomingHoliday();
}

// ============================================================
// OPEN PROFILE PAGE
// ============================================================

Future<void> _openProfilePage() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProfilePage(
        user: widget.user,
      ),
    ),
  );
}

// ============================================================
// OPEN PAYSLIPS PAGE
// ============================================================

Future<void> _openPayslipsPage() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MyPayslipsPage(
        employeeId: widget.user.employeeId,
      ),
    ),
  );
}

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginView(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // MESSAGES
  // ============================================================

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: RefreshIndicator(
          color: violet,
          onRefresh: () async {
            await Future.wait([
              _loadTodayAttendance(),
              _loadUpcomingHoliday(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              bottom: 30,
            ),
            child: Column(
              children: [
                _buildHeader(),

                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child: Column(
                      children: [
                        _buildAttendanceCard(),

                        const SizedBox(height: 18),

                        _buildTodaySummary(),

                        const SizedBox(height: 24),

                        _buildQuickActions(),

                        const SizedBox(height: 24),

                        _buildUpcoming(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildNavigation(),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    final displayName =
        widget.user.fullName.trim().isNotEmpty
            ? widget.user.fullName
            : widget.user.username;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        55,
      ),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.hub_outlined,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'AlienHR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const NotificationBell(
                isHeaderButton: true,
              ),

              const SizedBox(width: 8),

              _headerButton(
                Icons.logout_rounded,
                _logout,
              ),
            ],
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              _avatar(displayName),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      displayName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      widget.user.role,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ATTENDANCE CARD
  // ============================================================

  Widget _buildAttendanceCard() {
    return _card(
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TODAY'S ATTENDANCE",
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      '8:30 AM - 7:30 PM',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              _statusBadge(
                isCheckedOut
                    ? 'Completed'
                    : (isCheckedIn ? 'Working' : 'Not checked in'),
                isCheckedOut
                    ? const Color(0xFF0284C7)
                    : (isCheckedIn ? Colors.green : Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 28),

          GestureDetector(
            onTap: isAttendanceLoading ? null : _attendanceAction,
            child: AnimatedOpacity(
              opacity: isAttendanceLoading ? 0.75 : 1,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 145,
                height: 145,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isCheckedOut
                        ? [
                            const Color(0xFF0D9488),
                            const Color(0xFF0F766E),
                          ]
                        : isCheckedIn
                            ? [
                                const Color(0xFFEF4444),
                                const Color(0xFFB91C1C),
                              ]
                            : [
                                violet,
                                brightViolet,
                              ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isCheckedOut
                              ? Colors.teal
                              : (isCheckedIn ? Colors.red : violet))
                          .withValues(
                        alpha: 0.25,
                      ),
                      blurRadius: 25,
                    ),
                  ],
                ),
                child: isAttendanceLoading
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 35,
                            height: 35,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'PLEASE WAIT',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCheckedOut
                                ? Icons.check_circle_rounded
                                : (isCheckedIn
                                    ? Icons.logout_rounded
                                    : Icons.fingerprint),
                            color: Colors.white,
                            size: 42,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isCheckedOut
                                ? 'COMPLETED'
                                : (isCheckedIn ? 'CHECK OUT' : 'CHECK IN'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F5FB),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: violet,
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        branchName,
                        style: const TextStyle(
                          color: textDark,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        currentLocationText,
                        style: const TextStyle(
                          color: textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TODAY SUMMARY
  // ============================================================

  Widget _buildTodaySummary() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Today',
          Icons.today_outlined,
        ),

        const SizedBox(height: 12),

        _card(
          padding:
              const EdgeInsets.symmetric(
            vertical: 20,
          ),
          child: Row(
            children: [
              _summary(
                'Check In',
                checkInTime,
                Icons.login_rounded,
              ),

              _divider(),

              _summary(
                'Check Out',
                checkOutTime,
                Icons.logout_rounded,
              ),

              _divider(),

              _summary(
                'Worked',
                workedTime,
                Icons.schedule_outlined,
              ),

              _divider(),

              _summary(
                'OT',
                overtime,
                Icons.more_time_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Quick Actions',
          Icons.grid_view_rounded,
        ),

        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: [
            // APPLY LEAVE
            _quickAction(
              Icons.calendar_month_outlined,
              'Apply Leave',
              'Request time off',
              onTap: _openLeavePage,
            ),

            // ATTENDANCE
          // ATTENDANCE
_quickAction(
  Icons.history_rounded,
  'Attendance',
  'View attendance history',
  onTap: _openAttendanceHistory,
),

            // HOLIDAYS
            _quickAction(
              Icons.celebration_outlined,
              'Holidays',
              'View holidays',
              onTap: _openHolidaysPage,
            ),

            // PROFILE
            _quickAction(
              Icons.person_outline,
              'My Profile',
              'Personal details',
              onTap: _openProfilePage,
            ),

            // PAYSLIPS
            _quickAction(
              Icons.receipt_long_rounded,
              'My Payslips',
              'Salary & payouts',
              onTap: _openPayslipsPage,
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // UPCOMING
  // ============================================================

  Widget _buildUpcoming() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Upcoming',
          Icons.event_outlined,
        ),

        const SizedBox(height: 12),

        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _openHolidaysPage,
          child: _card(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: violet.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.celebration_outlined,
                    color: violet,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Next Holiday',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        _upcomingHoliday?.holidayName ?? 'No upcoming holidays',
                        style: const TextStyle(
                          color: textDark,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        _upcomingHoliday != null
                            ? _formatHolidayDate(_upcomingHoliday!.holidayDate)
                            : 'Tap to view full company calendar',
                        style: const TextStyle(
                          color: textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  color: textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SHARED CARD
  // ============================================================

  Widget _card({
    required Widget child,
    EdgeInsets padding =
        const EdgeInsets.all(20),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEEE8F3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // QUICK ACTION CARD
  // ============================================================

  Widget _quickAction(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap ??
            () {
              _showMessage(
                '$title screen will be added next.',
              );
            },
        borderRadius:
            BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFEEE8F3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFF1E8FA),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: violet,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY ITEM
  // ============================================================

  Widget _summary(
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: violet,
            size: 20,
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: const TextStyle(
              color: textMuted,
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _divider() {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFFEEE8F3),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: violet,
          size: 19,
        ),

        const SizedBox(width: 7),

        Text(
          title,
          style: const TextStyle(
            color: textDark,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(
    String text,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // AVATAR
  // ============================================================

  Widget _avatar(String name) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.15,
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // HEADER BUTTON
  // ============================================================

  Widget _headerButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white.withValues(
        alpha: 0.12,
      ),
      borderRadius:
          BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(12),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildNavigation() {
    return NavigationBar(
      selectedIndex: selectedIndex,
      backgroundColor: Colors.white,
      indicatorColor:
          const Color(0xFFF0E4FA),

      onDestinationSelected: (index) {
        // Attendance
        if (index == 1) {
          _openAttendanceHistory();
          return;
        }

        // Leave
        if (index == 2) {
          _openLeavePage();
          return;
        }

        // Profile
        if (index == 3) {
          _openProfilePage();
          return;
        }

        setState(() {
          selectedIndex = index;
        });
      },

      destinations: const [
        NavigationDestination(
          icon: Icon(
            Icons.home_outlined,
          ),
          selectedIcon: Icon(
            Icons.home,
            color: violet,
          ),
          label: 'Home',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.access_time_outlined,
          ),
          selectedIcon: Icon(
            Icons.access_time_filled,
            color: violet,
          ),
          label: 'Attendance',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.calendar_month_outlined,
          ),
          selectedIcon: Icon(
            Icons.calendar_month,
            color: violet,
          ),
          label: 'Leave',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.person_outline,
          ),
          selectedIcon: Icon(
            Icons.person,
            color: violet,
          ),
          label: 'Profile',
        ),
      ],
    );
  }

  // ============================================================
  // INITIALS
  // ============================================================

  String _initials(String name) {
    final parts = name
        .trim()
        .split(' ')
        .where(
          (e) => e.isNotEmpty,
        )
        .toList();

    if (parts.isEmpty) {
      return 'U';
    }

    if (parts.length == 1) {
      return parts.first[0]
          .toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'
        .toUpperCase();
  }
}