import 'package:flutter/material.dart';

import '../../models/holiday.dart';
import '../../models/user.dart';
import '../../services/holiday_service.dart';

class HolidaysPage extends StatefulWidget {
  final User? user;

  const HolidaysPage({
    super.key,
    this.user,
  });

  @override
  State<HolidaysPage> createState() => _HolidaysPageState();
}

class _HolidaysPageState extends State<HolidaysPage> {
  static const Color deepDark = Color(0xFF0B0614);
  static const Color violet = Color(0xFF7C2FCE);
  static const Color background = Color(0xFFF7F5FA);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);

  final HolidayService _holidayService = HolidayService();
  final TextEditingController _searchController = TextEditingController();

  List<Holiday> _allHolidays = [];
  List<Holiday> _filteredHolidays = [];
  bool _isLoading = true;
  String? _errorMessage;

  int _selectedYear = DateTime.now().year;
  late final List<int> _availableYears;

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _availableYears = [
      currentYear - 1,
      currentYear,
      currentYear + 1,
    ];
    _loadHolidays();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHolidays() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final holidays = await _holidayService.getHolidays(
        companyId: widget.user?.companyId,
        year: _selectedYear,
      );

      if (!mounted) return;

      setState(() {
        _allHolidays = holidays;
        _applySearch();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applySearch() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      _filteredHolidays = List.from(_allHolidays);
    } else {
      _filteredHolidays = _allHolidays.where((h) {
        final nameMatch = h.holidayName.toLowerCase().contains(query);
        final descMatch =
            h.description?.toLowerCase().contains(query) ?? false;
        final dateMatch = h.holidayDate.contains(query);
        return nameMatch || descMatch || dateMatch;
      }).toList();
    }
  }

  bool get _canManage =>
      widget.user != null &&
      (widget.user!.roleId == 1 ||
          widget.user!.roleId == 2 ||
          widget.user!.roleId == 3 ||
          widget.user!.role.toLowerCase().contains('admin') ||
          widget.user!.role.toLowerCase().contains('manager'));

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<void> _showHolidayDialog({Holiday? holiday}) async {
    final bool isEdit = holiday != null;
    final nameCtrl = TextEditingController(text: holiday?.holidayName ?? '');
    final descCtrl = TextEditingController(text: holiday?.description ?? '');
    DateTime selectedDate = holiday?.parsedDate ?? DateTime(_selectedYear, DateTime.now().month, DateTime.now().day);
    bool isActive = holiday?.isActive ?? true;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEdit ? 'Edit Holiday' : 'Add New Holiday'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Holiday Name *',
                    hintText: 'e.g. Independence Day, Christmas',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(_selectedYear - 2),
                      lastDate: DateTime(_selectedYear + 3),
                    );
                    if (picked != null) {
                      setDlgState(() => selectedDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Holiday Date *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month, color: violet),
                    ),
                    child: Text(
                      _formatDate(selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'e.g. Public and bank holiday',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (isEdit) ...[
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Is Active', style: TextStyle(fontSize: 14)),
                    value: isActive,
                    activeThumbColor: violet,
                    onChanged: (val) => setDlgState(() => isActive = val),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a holiday name.')),
                  );
                  return;
                }

                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(ctx);
                setState(() => _isLoading = true);

                try {
                  final formattedDate = _formatDate(selectedDate);
                  if (isEdit) {
                    await _holidayService.updateHoliday(holiday.id, {
                      'holidayDate': formattedDate,
                      'holidayName': name,
                      'description': descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null,
                      'isActive': isActive,
                    });
                  } else {
                    await _holidayService.createHoliday({
                      'companyId': widget.user?.companyId != null && widget.user!.companyId > 0
                          ? widget.user!.companyId
                          : 1,
                      'holidayDate': formattedDate,
                      'holidayName': name,
                      'description': descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null,
                      'createdBy': widget.user?.userId,
                    });
                  }

                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(isEdit ? 'Holiday updated successfully!' : 'Holiday added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  await _loadHolidays();
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                    setState(() => _isLoading = false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: violet, foregroundColor: Colors.white),
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteHoliday(Holiday holiday) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Holiday'),
        content: Text('Are you sure you want to delete "${holiday.holidayName}" (${holiday.holidayDate})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _holidayService.deleteHoliday(holiday.id, deletedBy: widget.user?.userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Holiday deleted successfully!'), backgroundColor: Colors.green),
          );
        }
        await _loadHolidays();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      floatingActionButton: _canManage
          ? FloatingActionButton.extended(
              onPressed: () => _showHolidayDialog(),
              backgroundColor: violet,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Holiday'),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                color: violet,
                onRefresh: _loadHolidays,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Expanded(
                child: Text(
                  'Company Holidays',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Year selector chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedYear,
                    dropdownColor: const Color(0xFF211B2E),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    items: _availableYears.map((y) {
                      return DropdownMenuItem<int>(
                        value: y,
                        child: Text(
                          y.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (y) {
                      if (y != null && y != _selectedYear) {
                        setState(() {
                          _selectedYear = y;
                        });
                        _loadHolidays();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search Bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(_applySearch),
              decoration: InputDecoration(
                hintText: 'Search holiday by name...',
                hintStyle: const TextStyle(
                  color: textMuted,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: textMuted,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: textMuted,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(_applySearch);
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BODY STATES
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: violet,
        ),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Failed to load holidays',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loadHolidays,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: violet,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_filteredHolidays.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: violet.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_available_outlined,
                    color: violet,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isNotEmpty
                      ? 'No matching holidays found'
                      : 'No holidays scheduled for $_selectedYear',
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pull down to refresh or check another year.',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      itemCount: _filteredHolidays.length,
      itemBuilder: (context, index) {
        final holiday = _filteredHolidays[index];
        return _buildHolidayCard(holiday);
      },
    );
  }

  // ============================================================
  // HOLIDAY CARD
  // ============================================================

  Widget _buildHolidayCard(Holiday holiday) {
    final parsed = holiday.parsedDate;
    final String dayNum = parsed != null ? parsed.day.toString() : '--';
    final String monthName = parsed != null ? _shortMonth(parsed.month) : '--';
    final String weekDay = parsed != null ? _weekDay(parsed.weekday) : '';

    final bool isUpcoming = parsed != null &&
        parsed.isAfter(DateTime.now().subtract(const Duration(days: 1)));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Box
            Container(
              width: 54,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isUpcoming
                    ? violet.withValues(alpha: 0.12)
                    : const Color(0xFFF1E8FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUpcoming
                      ? violet.withValues(alpha: 0.3)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    monthName.toUpperCase(),
                    style: TextStyle(
                      color: isUpcoming ? violet : textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dayNum,
                    style: TextStyle(
                      color: isUpcoming ? violet : textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          holiday.holidayName,
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isUpcoming)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'UPCOMING',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (_canManage)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20, color: textMuted),
                          padding: EdgeInsets.zero,
                          onSelected: (val) {
                            if (val == 'edit') {
                              _showHolidayDialog(holiday: holiday);
                            } else if (val == 'delete') {
                              _confirmDeleteHoliday(holiday);
                            }
                          },
                          itemBuilder: (ctx) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18, color: violet),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$weekDay • ${holiday.holidayDate}',
                        style: const TextStyle(
                          color: textMuted,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                  if (holiday.description != null &&
                      holiday.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      holiday.description!,
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _shortMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  static String _weekDay(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (weekday >= 1 && weekday <= 7) return days[weekday - 1];
    return '';
  }
}
