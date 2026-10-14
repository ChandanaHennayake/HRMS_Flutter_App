import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/audit_log.dart';
import '../../services/audit_service.dart';

class AuditLogPage extends StatefulWidget {
  const AuditLogPage({super.key});

  @override
  State<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditLogPageState extends State<AuditLogPage> {
  final AuditService _auditService = AuditService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<AuditLogItem> _logs = [];
  AuditStats? _stats;
  String _selectedSeverity = 'All';
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;

  // Brand Palette
  static const Color violet = Color(0xFF6B21A8);
  static const Color violetLight = Color(0xFFF5F3FF);
  static const Color slateDark = Color(0xFF0F172A);
  static const Color slateMuted = Color(0xFF64748B);
  static const Color slateBorder = Color(0xFFE2E8F0);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color emerald = Color(0xFF059669);
  static const Color amber = Color(0xFFD97706);
  static const Color orange = Color(0xFFEA580C);
  static const Color crimson = Color(0xFFDC2626);

  final List<String> _severityOptions = ['All', 'Security', 'Critical', 'Warning', 'Info'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final statsFuture = _auditService.getAuditStats();
      final logsFuture = _auditService.getAuditLogs(
        page: _currentPage,
        pageSize: 30,
        severity: _selectedSeverity == 'All' ? null : _selectedSeverity,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      );

      final results = await Future.wait([statsFuture, logsFuture]);

      if (!mounted) return;
      setState(() {
        _stats = results[0] as AuditStats;
        final pagedResult = results[1] as PagedAuditResult;
        _logs = pagedResult.items;
        _totalCount = pagedResult.totalCount;
        _totalPages = pagedResult.totalPages;
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

  void _onSearchChanged(String _) {
    _currentPage = 1;
    _loadData();
  }

  void _onSeveritySelected(String severity) {
    if (_selectedSeverity == severity) return;
    setState(() {
      _selectedSeverity = severity;
      _currentPage = 1;
    });
    _loadData();
  }

  void _showLogDetails(AuditLogItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildDetailModal(item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: const Text(
          'Security & Audit Trail',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: violet,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh Audit Trail',
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Stats Summary
          if (_stats != null) _buildStatsHeader(),

          // Search and Filter Bar
          _buildFilterBar(),

          // Main Log List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: violet,
              child: _buildBody(),
            ),
          ),

          // Pagination Bar
          if (_totalPages > 1) _buildPaginationBar(),
        ],
      ),
    );
  }

  Widget _buildPaginationBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: slateBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page $_currentPage of $_totalPages ($_totalCount total)',
            style: const TextStyle(fontSize: 12.5, color: slateMuted, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: _currentPage > 1
                    ? () {
                        setState(() => _currentPage--);
                        _loadData();
                      }
                    : null,
                iconSize: 22,
                color: violet,
                disabledColor: slateBorder,
                tooltip: 'Previous page',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: _currentPage < _totalPages
                    ? () {
                        setState(() => _currentPage++);
                        _loadData();
                      }
                    : null,
                iconSize: 22,
                color: violet,
                disabledColor: slateBorder,
                tooltip: 'Next page',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildStatCard('Total Logs', '${_stats!.totalLogs}', violet, Icons.receipt_long_rounded),
          const SizedBox(width: 8),
          _buildStatCard('Security', '${_stats!.securityCount}', crimson, Icons.shield_outlined),
          const SizedBox(width: 8),
          _buildStatCard('Warnings', '${_stats!.warningCount}', amber, Icons.warning_amber_rounded),
          const SizedBox(width: 8),
          _buildStatCard('Critical', '${_stats!.criticalCount}', orange, Icons.error_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          // Search box
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: bgLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: slateBorder),
            ),
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearchChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Search action, entity, user, message...',
                hintStyle: const TextStyle(fontSize: 13, color: slateMuted),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: slateMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: slateMuted),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Severity Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _severityOptions.map((sev) {
                final isSelected = _selectedSeverity == sev;
                Color activeColor = violet;
                if (sev == 'Security') activeColor = crimson;
                if (sev == 'Critical') activeColor = orange;
                if (sev == 'Warning') activeColor = amber;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      sev,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : slateDark,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: activeColor,
                    backgroundColor: const Color(0xFFF1F5F9),
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? activeColor : slateBorder,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    onSelected: (_) => _onSeveritySelected(sev),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: violet));
    }

    if (_errorMessage != null) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline_rounded, size: 54, color: crimson),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: slateMuted),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: violet,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_logs.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: violetLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.history_rounded, size: 48, color: violet),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No Audit Logs Found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: slateDark),
                ),
                const SizedBox(height: 8),
                const Text(
                  'There are no audit events matching your filter criteria.',
                  style: TextStyle(fontSize: 14, color: slateMuted),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _logs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _logs[index];
        return _buildAuditCard(item);
      },
    );
  }

  Widget _buildAuditCard(AuditLogItem item) {
    Color badgeColor;
    Color badgeBg;
    IconData iconData;

    switch (item.severity.toLowerCase()) {
      case 'security':
        badgeColor = crimson;
        badgeBg = const Color(0xFFFEF2F2);
        iconData = Icons.shield_outlined;
        break;
      case 'critical':
        badgeColor = orange;
        badgeBg = const Color(0xFFFFF7ED);
        iconData = Icons.error_outline_rounded;
        break;
      case 'warning':
        badgeColor = amber;
        badgeBg = const Color(0xFFFFFBEB);
        iconData = Icons.warning_amber_rounded;
        break;
      case 'info':
      default:
        badgeColor = violet;
        badgeBg = violetLight;
        iconData = Icons.info_outline_rounded;
        break;
    }

    return InkWell(
      onTap: () => _showLogDetails(item),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: slateBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Action, Entity, and Severity
            Row(
              children: [
                // Severity icon badge
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(iconData, color: badgeColor, size: 16),
                ),
                const SizedBox(width: 10),

                // Action Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.action,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: slateDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Entity Pill
                Text(
                  item.entityId != null ? '${item.entityName} #${item.entityId}' : item.entityName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: slateMuted,
                  ),
                ),

                const Spacer(),

                // Timestamp
                Text(
                  _formatTimestamp(item.createdAt),
                  style: const TextStyle(fontSize: 11.5, color: slateMuted),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Description text
            if (item.description != null && item.description!.isNotEmpty) ...[
              Text(
                item.description!,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: slateDark,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Bottom metadata row (Actor, IP)
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 13, color: slateMuted),
                const SizedBox(width: 4),
                Text(
                  item.userName ?? 'System',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: slateMuted),
                ),
                if (item.ipAddress != null && item.ipAddress!.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.language_rounded, size: 13, color: slateMuted),
                  const SizedBox(width: 4),
                  Text(
                    item.ipAddress!,
                    style: const TextStyle(fontSize: 11.5, color: slateMuted),
                  ),
                ],
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, size: 18, color: slateMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailModal(AuditLogItem item) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 30,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: slateBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Row(
              children: [
                const Text(
                  'Audit Event Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: slateDark),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: item.severity == 'Security'
                        ? const Color(0xFFFEF2F2)
                        : (item.severity == 'Warning' ? const Color(0xFFFFFBEB) : violetLight),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.severity,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: item.severity == 'Security'
                          ? crimson
                          : (item.severity == 'Warning' ? amber : violet),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _detailRow('Event ID', '#${item.id}'),
            _detailRow('Action', item.action),
            _detailRow('Entity', '${item.entityName} ${item.entityId != null ? "#${item.entityId}" : ""}'),
            _detailRow('Actor', item.userName ?? 'System'),
            _detailRow('User ID', item.userId != null ? '${item.userId}' : 'N/A'),
            _detailRow('IP Address', item.ipAddress ?? 'N/A'),
            _detailRow('Timestamp', item.createdAt.toLocal().toString().replaceAll('.000', '')),

            if (item.description != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Description',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: slateDark),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: slateBorder),
                ),
                child: Text(
                  item.description!,
                  style: const TextStyle(fontSize: 13, color: slateDark, height: 1.35),
                ),
              ),
            ],

            // Old Values (if any)
            if (item.oldValues != null && item.oldValues!.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text(
                'Prior State (Old Values)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: crimson),
              ),
              const SizedBox(height: 4),
              _buildJsonBlock(item.oldValues!),
            ],

            // New Values (if any)
            if (item.newValues != null && item.newValues!.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text(
                'Modified State (New Values)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: emerald),
              ),
              const SizedBox(height: 4),
              _buildJsonBlock(item.newValues!),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: slateBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Close', style: TextStyle(color: slateDark)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: slateMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: slateDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonBlock(String raw) {
    String formatted;
    try {
      final decoded = jsonDecode(raw);
      formatted = const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      formatted = raw;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        formatted,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: Color(0xFFE2E8F0),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final localDt = dt.toLocal();
    final diff = now.difference(localDt);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${localDt.day.toString().padLeft(2, '0')}/${localDt.month.toString().padLeft(2, '0')} ${localDt.hour.toString().padLeft(2, '0')}:${localDt.minute.toString().padLeft(2, '0')}';
    }
  }
}
