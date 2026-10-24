import 'package:flutter/material.dart';

import '../../core/storage/secure_storage.dart';
import '../../models/attendance_correction.dart';
import '../../models/attendance_history.dart';
import '../../models/user.dart';
import '../../services/attendance_service.dart';
import 'attendance_correction_dialog.dart';

class AttendanceHistoryPage extends StatefulWidget {
  final User user;

  const AttendanceHistoryPage({
    super.key,
    required this.user,
  });

  @override
  State<AttendanceHistoryPage> createState() =>
      _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState
    extends State<AttendanceHistoryPage> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color deepDark =
      Color(0xFF0B0614);

  static const Color violet =
      Color(0xFF7C2FCE);

  static const Color background =
      Color(0xFFF7F5FA);

  static const Color textDark =
      Color(0xFF211B2E);

  static const Color textMuted =
      Color(0xFF8B87A0);

  // ============================================================
  // SERVICE
  // ============================================================

  final AttendanceService _attendanceService =
      AttendanceService();

  // ============================================================
  // STATE
  // ============================================================

  List<AttendanceHistoryModel> _attendance = [];

  bool _isLoading = false;

  DateTime? _fromDate;

  DateTime? _toDate;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadAttendance();
  }

  // ============================================================
  // GET EMPLOYEE ID
  // ============================================================

  int get employeeId {
    return widget.user.employeeId;
  }

  // ============================================================
  // LOAD ATTENDANCE
  // ============================================================

  Future<void> _loadAttendance() async {
    int targetEmployeeId = employeeId;
    if (targetEmployeeId <= 0) {
      final storedId = await SecureStorage.getEmployeeId();
      if (storedId != null && storedId > 0) {
        targetEmployeeId = storedId;
      }
    }

    if (targetEmployeeId <= 0) {
      _showError(
        'Employee ID is not available for this account.',
      );

      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final result =
          await _attendanceService.getAttendanceHistory(
        employeeId: targetEmployeeId,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      if (!mounted) return;

      setState(() {
        _attendance = result;
      });
    } catch (e) {
      if (!mounted) return;

      _showError(
        _cleanError(e),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // APPLY FILTER
  // ============================================================

  Future<void> _applyFilter() async {
    if (_fromDate != null &&
        _toDate != null &&
        _fromDate!.isAfter(_toDate!)) {
      _showError(
        'From date cannot be after To date.',
      );

      return;
    }

    await _loadAttendance();
  }

  // ============================================================
  // CLEAR FILTER
  // ============================================================

  Future<void> _clearFilter() async {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });

    await _loadAttendance();
  }

  Future<void> _openCorrectionDialog() async {
    int targetEmployeeId = employeeId;
    if (targetEmployeeId <= 0) {
      final storedId = await SecureStorage.getEmployeeId();
      if (storedId != null && storedId > 0) {
        targetEmployeeId = storedId;
      }
    }

    if (!mounted) return;

    final result = await showDialog<AttendanceCorrection?>(
      context: context,
      builder: (_) => AttendanceCorrectionDialog(
        employeeId: targetEmployeeId,
      ),
    );

    if (result != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Attendance correction request submitted successfully.',
          ),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      _loadAttendance();
    }
  }

  // ============================================================
  // FROM DATE
  // ============================================================

  Future<void> _selectFromDate() async {
    final now = DateTime.now();

    final picked =
        await showDatePicker(
      context: context,
      initialDate:
          _fromDate ?? now,
      firstDate:
          DateTime(2020),
      lastDate:
          now,
      helpText:
          'Select From Date',
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _fromDate = picked;

      // If To Date is before From Date,
      // automatically clear To Date.
      if (_toDate != null &&
          _toDate!.isBefore(picked)) {
        _toDate = null;
      }
    });
  }

  // ============================================================
  // TO DATE
  // ============================================================

  Future<void> _selectToDate() async {
    final now = DateTime.now();

    final firstDate =
        _fromDate ?? DateTime(2020);

    final picked =
        await showDatePicker(
      context: context,
      initialDate:
          _toDate ?? now,
      firstDate:
          firstDate,
      lastDate:
          now,
      helpText:
          'Select To Date',
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _toDate = picked;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          background,

      appBar: _buildAppBar(),

      body: RefreshIndicator(
        color:
            violet,

        onRefresh:
            _loadAttendance,

        child: CustomScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),

          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.all(18),

                child: Column(
                  children: [
                    _buildEmployeeCard(),

                    const SizedBox(
                      height: 16,
                    ),

                    _buildFilterCard(),

                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody:
                    false,

                child: Center(
                  child:
                      CircularProgressIndicator(
                    color:
                        violet,
                  ),
                ),
              )
            else if (_attendance.isEmpty)
              SliverFillRemaining(
                hasScrollBody:
                    false,

                child:
                    _buildEmptyState(),
              )
            else
              SliverPadding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 18,
                ),

                sliver:
                    SliverList(
                  delegate:
                      SliverChildBuilderDelegate(
                    (
                      context,
                      index,
                    ) {
                      final attendance =
                          _attendance[index];

                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),

                        child:
                            _buildAttendanceCard(
                          attendance,
                        ),
                      );
                    },

                    childCount:
                        _attendance.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child:
                  SizedBox(
                height: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,

      backgroundColor:
          deepDark,

      foregroundColor:
          Colors.white,

      titleSpacing:
          18,

      title: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            'Attendance History',
            style:
                TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          SizedBox(
            height: 2,
          ),

          Text(
            'View your attendance records',
            style:
                TextStyle(
              fontSize: 11,
              color:
                  Colors.white70,
              fontWeight:
                  FontWeight.normal,
            ),
          ),
        ],
      ),

      actions: [
        IconButton(
          tooltip: 'Request Attendance Correction',
          onPressed: _openCorrectionDialog,
          icon: const Icon(
            Icons.edit_calendar_outlined,
            color: Color(0xFFA855F7),
          ),
        ),

        IconButton(
          onPressed:
              _loadAttendance,

          icon:
              const Icon(
            Icons.refresh_rounded,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPLOYEE CARD
  // ============================================================

  Widget _buildEmployeeCard() {
    final name =
        widget.user.fullName
                .trim()
                .isNotEmpty
            ? widget.user.fullName
            : widget.user.username;

    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            deepDark,
            violet,
          ],
        ),

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        boxShadow: [
          BoxShadow(
            color:
                violet.withValues(
              alpha: 0.18,
            ),

            blurRadius:
                16,

            offset:
                const Offset(
              0,
              6,
            ),
          ),
        ],
      ),

      child: Row(
        children: [
          // ------------------------------------------------------
          // AVATAR
          // ------------------------------------------------------

          Container(
            width: 54,
            height: 54,

            decoration:
                BoxDecoration(
              color:
                  Colors.white
                      .withValues(
                alpha: 0.15,
              ),

              shape:
                  BoxShape.circle,
            ),

            alignment:
                Alignment.center,

            child: Text(
              _initials(name),

              style:
                  const TextStyle(
                color:
                    Colors.white,

                fontSize:
                    17,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          // ------------------------------------------------------
          // EMPLOYEE
          // ------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  name,

                  maxLines:
                      1,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Colors.white,

                    fontSize:
                        17,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  'Employee ID: $employeeId',

                  style:
                      TextStyle(
                    color:
                        Colors.white
                            .withValues(
                      alpha: 0.78,
                    ),

                    fontSize:
                        12,
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
  // FILTER CARD
  // ============================================================

  Widget _buildFilterCard() {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFEEE8F3,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withValues(
              alpha: 0.035,
            ),

            blurRadius:
                14,

            offset:
                const Offset(
              0,
              5,
            ),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ------------------------------------------------------
          // TITLE
          // ------------------------------------------------------

          Row(
            children: [
              Container(
                width: 38,
                height: 38,

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFF3E8FB,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),

                child:
                    const Icon(
                  Icons
                      .filter_alt_outlined,

                  color:
                      violet,

                  size: 20,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Filter Attendance',

                      style:
                          TextStyle(
                        color:
                            textDark,

                        fontSize:
                            15,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(
                      height: 2,
                    ),

                    Text(
                      'Select a date range',

                      style:
                          TextStyle(
                        color:
                            textMuted,

                        fontSize:
                            11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          // ------------------------------------------------------
          // DATES
          // ------------------------------------------------------

          Row(
            children: [
              Expanded(
                child:
                    _dateField(
                  label:
                      'From Date',

                  value:
                      _fromDate,

                  onTap:
                      _selectFromDate,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child:
                    _dateField(
                  label:
                      'To Date',

                  value:
                      _toDate,

                  onTap:
                      _selectToDate,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          // ------------------------------------------------------
          // BUTTONS
          // ------------------------------------------------------

          Row(
            children: [
              Expanded(
                child:
                    SizedBox(
                  height: 48,

                  child:
                      ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _applyFilter,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          violet,

                      foregroundColor:
                          Colors.white,

                      elevation:
                          0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          13,
                        ),
                      ),
                    ),

                    child:
                        const Text(
                      'Apply Filter',

                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.bold,

                        fontSize:
                            13,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              SizedBox(
                height: 48,

                child:
                    OutlinedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _clearFilter,

                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        violet,

                    side:
                        const BorderSide(
                      color:
                          violet,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        13,
                      ),
                    ),
                  ),

                  child:
                      const Icon(
                    Icons
                        .refresh_rounded,

                    size:
                        20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap:
          onTap,

      borderRadius:
          BorderRadius.circular(
        13,
      ),

      child: Container(
        padding:
            const EdgeInsets
                .symmetric(
          horizontal: 12,
          vertical: 12,
        ),

        decoration:
            BoxDecoration(
          color:
              const Color(
            0xFFFAF8FC,
          ),

          borderRadius:
              BorderRadius.circular(
            13,
          ),

          border:
              Border.all(
            color:
                const Color(
              0xFFE9E2EE,
            ),
          ),
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              label,

              style:
                  const TextStyle(
                color:
                    textMuted,

                fontSize:
                    10,

                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Row(
              children: [
                const Icon(
                  Icons
                      .calendar_today_outlined,

                  color:
                      violet,

                  size:
                      17,
                ),

                const SizedBox(
                  width:
                      7,
                ),

                Expanded(
                  child: Text(
                    value == null
                        ? 'Select date'
                        : _formatDate(
                            value,
                          ),

                    maxLines:
                        1,

                    overflow:
                        TextOverflow
                            .ellipsis,

                    style:
                        TextStyle(
                      color:
                          value == null
                              ? textMuted
                              : textDark,

                      fontSize:
                          12,

                      fontWeight:
                          value == null
                              ? FontWeight.normal
                              : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ATTENDANCE CARD
  // ============================================================

  Widget _buildAttendanceCard(
    AttendanceHistoryModel attendance,
  ) {
    final date =
        attendance.attendanceDate;

    final isPresent =
        attendance.checkInTime != null;

    final isCompleted =
        attendance.checkInTime != null &&
        attendance.checkOutTime != null;

    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(17),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFEEE8F3,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withValues(
              alpha: 0.035,
            ),

            blurRadius:
                13,

            offset:
                const Offset(
              0,
              5,
            ),
          ),
        ],
      ),

      child: Column(
        children: [
          // ------------------------------------------------------
          // DATE + STATUS
          // ------------------------------------------------------

          Row(
            children: [
              Container(
                width: 48,
                height: 48,

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFF4EAFB,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),

                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [
                    Text(
                      date.day
                          .toString(),

                      style:
                          const TextStyle(
                        color:
                            violet,

                        fontSize:
                            17,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    Text(
                      _monthName(
                        date.month,
                      ),

                      style:
                          const TextStyle(
                        color:
                            violet,

                        fontSize:
                            8,

                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width:
                    12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      _fullDate(
                        date,
                      ),

                      style:
                          const TextStyle(
                        color:
                            textDark,

                        fontSize:
                            14,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height:
                          3,
                    ),

                    Text(
                      _dayName(
                        date,
                      ),

                      style:
                          const TextStyle(
                        color:
                            textMuted,

                        fontSize:
                            11,
                      ),
                    ),
                  ],
                ),
              ),

              _statusBadge(
                isPresent:
                    isPresent,

                isCompleted:
                    isCompleted,
              ),
            ],
          ),

          const SizedBox(
            height:
                16,
          ),

          const Divider(
            height:
                1,
            color:
                Color(
              0xFFF0ECF2,
            ),
          ),

          const SizedBox(
            height:
                14,
          ),

          // ------------------------------------------------------
          // DETAILS
          // ------------------------------------------------------

          Row(
            children: [
              Expanded(
                child:
                    _attendanceDetail(
                  icon:
                      Icons.login_rounded,

                  title:
                      'Check In',

                  value:
                      _formatTime(
                    attendance
                        .checkInTime,
                  ),
                ),
              ),

              Expanded(
                child:
                    _attendanceDetail(
                  icon:
                      Icons.logout_rounded,

                  title:
                      'Check Out',

                  value:
                      _formatTime(
                    attendance
                        .checkOutTime,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
                14,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _attendanceDetail(
                  icon:
                      Icons.schedule_outlined,

                  title:
                      'Worked',

                  value:
                      _formatMinutes(
                    attendance
                        .workedMinutes,
                  ),
                ),
              ),

              Expanded(
                child:
                    _attendanceDetail(
                  icon:
                      Icons
                          .more_time_rounded,

                  title:
                      'Overtime',

                  value:
                      _formatMinutes(
                    attendance
                        .otMinutes,
                  ),
                ),
              ),
            ],
          ),

          // ------------------------------------------------------
          // LATE / EARLY
          // ------------------------------------------------------

          if (attendance.isLate ||
              attendance
                  .isEarlyDeparture) ...[
            const SizedBox(
              height:
                  14,
            ),

            Row(
              children: [
                if (attendance.isLate)
                  Expanded(
                    child:
                        _smallStatus(
                      icon:
                          Icons
                              .schedule_outlined,

                      title:
                          'Late',

                      value:
                          '${attendance.lateMinutes} min',
                    ),
                  ),

                if (attendance
                    .isLate)
                  const SizedBox(
                    width:
                        8,
                  ),

                if (attendance
                    .isEarlyDeparture)
                  Expanded(
                    child:
                        _smallStatus(
                      icon:
                          Icons
                              .logout_outlined,

                      title:
                          'Early Departure',

                      value:
                          '${attendance.earlyDepartureMinutes} min',
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // ATTENDANCE DETAIL
  // ============================================================

  Widget _attendanceDetail({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,

          decoration:
              BoxDecoration(
            color:
                const Color(
              0xFFF6F0FA,
            ),

            borderRadius:
                BorderRadius.circular(
              10,
            ),
          ),

          child:
              Icon(
            icon,
            color:
                violet,
            size:
                17,
          ),
        ),

        const SizedBox(
          width:
              9,
        ),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              title,

              style:
                  const TextStyle(
                color:
                    textMuted,

                fontSize:
                    9,
              ),
            ),

            const SizedBox(
              height:
                  2,
            ),

            Text(
              value,

              style:
                  const TextStyle(
                color:
                    textDark,

                fontSize:
                    12,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // SMALL STATUS
  // ============================================================

  Widget _smallStatus({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        10,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFFFF7EA,
        ),

        borderRadius:
            BorderRadius.circular(
          11,
        ),
      ),

      child: Row(
        children: [
          const Icon(
            Icons
                .warning_amber_rounded,

            color:
                Color(
              0xFFE58A00,
            ),

            size:
                17,
          ),

          const SizedBox(
            width:
                7,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style:
                      const TextStyle(
                    color:
                        textMuted,

                    fontSize:
                        9,
                  ),
                ),

                Text(
                  value,

                  style:
                      const TextStyle(
                    color:
                        textDark,

                    fontSize:
                        11,

                    fontWeight:
                        FontWeight.bold,
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
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge({
    required bool isPresent,
    required bool isCompleted,
  }) {
    final Color color;

    final String text;

    if (!isPresent) {
      color =
          Colors.orange.shade700;

      text =
          'Absent';
    } else if (!isCompleted) {
      color =
          Colors.blue.shade700;

      text =
          'Working';
    } else {
      color =
          Colors.green.shade700;

      text =
          'Present';
    }

    return Container(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal:
            10,

        vertical:
            6,
      ),

      decoration:
          BoxDecoration(
        color:
            color.withValues(
          alpha: 0.10,
        ),

        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),

      child: Text(
        text,

        style:
            TextStyle(
          color:
              color,

          fontSize:
              10,

          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          30,
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 80,
              height: 80,

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFF2E8FB,
                ),

                shape:
                    BoxShape.circle,
              ),

              child:
                  const Icon(
                Icons
                    .event_busy_outlined,

                color:
                    violet,

                size:
                    38,
              ),
            ),

            const SizedBox(
              height:
                  18,
            ),

            const Text(
              'No Attendance Found',

              style:
                  TextStyle(
                color:
                    textDark,

                fontSize:
                    17,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height:
                  7,
            ),

            const Text(
              'There are no attendance records for the selected date range.',

              textAlign:
                  TextAlign.center,

              style:
                  TextStyle(
                color:
                    textMuted,

                fontSize:
                    12,
              ),
            ),

            const SizedBox(
              height:
                  18,
            ),

            OutlinedButton.icon(
              onPressed:
                  _clearFilter,

              icon:
                  const Icon(
                Icons.refresh_rounded,
                size:
                    18,
              ),

              label:
                  const Text(
                'Clear Filter',
              ),

              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    violet,

                side:
                    const BorderSide(
                  color:
                      violet,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    )
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(message),

          backgroundColor:
              Colors.red.shade700,

          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(
    DateTime date,
  ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // FULL DATE
  // ============================================================

  String _fullDate(
    DateTime date,
  ) {
    return '${date.day.toString().padLeft(2, '0')} '
        '${_monthName(date.month)} '
        '${date.year}';
  }

  // ============================================================
  // MONTH
  // ============================================================

  String _monthName(
    int month,
  ) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    return months[
        month - 1];
  }

  // ============================================================
  // DAY
  // ============================================================

  String _dayName(
    DateTime date,
  ) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[
      date.weekday - 1
    ];
  }

  // ============================================================
  // TIME
  // ============================================================

  String _formatTime(
    DateTime? value,
  ) {
    if (value == null) {
      return '--:--';
    }

    final local = value.toLocal();
    final hour =
        local.hour
            .toString()
            .padLeft(
          2,
          '0',
        );

    final minute =
        local.minute
            .toString()
            .padLeft(
          2,
          '0',
        );

    return '$hour:$minute';
  }

  // ============================================================
  // MINUTES
  // ============================================================

  String _formatMinutes(
    int minutes,
  ) {
    if (minutes <= 0) {
      return '00h 00m';
    }

    final hours =
        minutes ~/ 60;

    final remaining =
        minutes % 60;

    return '${hours.toString().padLeft(2, '0')}h '
        '${remaining.toString().padLeft(2, '0')}m';
  }

  // ============================================================
  // INITIALS
  // ============================================================

  String _initials(
    String name,
  ) {
    final parts =
        name
            .trim()
            .split(' ')
            .where(
              (x) =>
                  x.isNotEmpty,
            )
            .toList();

    if (parts.isEmpty) {
      return 'U';
    }

    if (parts.length == 1) {
      return parts.first[0]
          .toUpperCase();
    }

    return '${parts[0][0]}'
        '${parts[1][0]}'
        .toUpperCase();
  }

  // ============================================================
  // CLEAN ERROR
  // ============================================================

  String _cleanError(
    Object error,
  ) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );
  }
}