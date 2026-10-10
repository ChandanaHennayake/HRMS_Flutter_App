import 'package:flutter/material.dart';

import '../../models/branch.dart';
import '../../models/user.dart';
import '../../services/branch_service.dart';
import '../../services/user_service.dart';
import 'branch_form_dialog.dart';

class BranchListPage extends StatefulWidget {
  final User? user;

  const BranchListPage({
    super.key,
    this.user,
  });

  @override
  State<BranchListPage> createState() => _BranchListPageState();
}

class _BranchListPageState extends State<BranchListPage> {
  static const Color deepDark = Color(0xFF0B0614);
  static const Color violet = Color(0xFF7C2FCE);
  static const Color background = Color(0xFFF7F5FA);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);
  static const Color emerald = Color(0xFF10B981);

  final BranchService _branchService = BranchService();
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();

  List<Branch> _allBranches = [];
  List<Branch> _filteredBranches = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBranches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final branches = await _branchService.getBranches();
      if (!mounted) return;
      setState(() {
        _allBranches = branches;
        _applySearch();
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

  void _applySearch() {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      _filteredBranches = List.from(_allBranches);
    } else {
      _filteredBranches = _allBranches.where((b) {
        final name = b.branchName.toLowerCase();
        final code = (b.branchCode ?? '').toLowerCase();
        final addr = (b.address ?? '').toLowerCase();
        return name.contains(q) || code.contains(q) || addr.contains(q);
      }).toList();
    }
  }

  Future<void> _openBranchForm([Branch? branch]) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BranchFormDialog(
        user: widget.user,
        branch: branch,
      ),
    );

    if (result == true && mounted) {
      _loadBranches();
    }
  }

  Future<void> _showManagersSheet(Branch branch) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BranchManagersSheet(
        branch: branch,
        branchService: _branchService,
        userService: _userService,
      ),
    );
  }

  Future<void> _confirmDelete(Branch branch) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Branch'),
        content: Text(
          'Are you sure you want to deactivate "${branch.branchName}"? Employees assigned will not be able to check in until reactivated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _branchService.deleteBranch(branch.branchId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Branch deactivated successfully.'),
            backgroundColor: emerald,
          ),
        );
        _loadBranches();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: RefreshIndicator(
                color: violet,
                onRefresh: _loadBranches,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBranchForm(),
        backgroundColor: violet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Branch',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final activeCount = _allBranches.where((b) => b.isActive).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
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
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Branches & Locations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _loadBranches,
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '${_allBranches.length} Total Branches ($activeCount Active)',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(_applySearch),
        decoration: InputDecoration(
          hintText: 'Search by branch name, code, or address...',
          hintStyle: const TextStyle(fontSize: 13, color: textMuted),
          prefixIcon: const Icon(Icons.search, color: textMuted),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: textMuted),
                  onPressed: () {
                    _searchController.clear();
                    setState(_applySearch);
                  },
                )
              : null,
          filled: true,
          fillColor: background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: violet),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadBranches,
                style: ElevatedButton.styleFrom(backgroundColor: violet),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredBranches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.business_outlined, size: 56, color: textMuted),
              SizedBox(height: 12),
              Text(
                'No branches found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Try adjusting your search or add a new branch.',
                style: TextStyle(fontSize: 12, color: textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: _filteredBranches.length,
      itemBuilder: (context, index) {
        final b = _filteredBranches[index];
        return _buildBranchCard(b);
      },
    );
  }

  Widget _buildBranchCard(Branch branch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Name, Code, and Status
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        branch.branchName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      if (branch.branchCode != null &&
                          branch.branchCode!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: violet.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            branch.branchCode!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: violet,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: branch.isActive
                        ? emerald.withValues(alpha: 0.12)
                        : Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    branch.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: branch.isActive ? emerald : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Address
            if (branch.address != null && branch.address!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        branch.address!,
                        style: const TextStyle(fontSize: 12, color: textMuted),
                      ),
                    ),
                  ],
                ),
              ),

            // Phone
            if (branch.phone != null && branch.phone!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.phone_outlined,
                        size: 16, color: textMuted),
                    const SizedBox(width: 6),
                    Text(
                      branch.phone!,
                      style: const TextStyle(fontSize: 12, color: textMuted),
                    ),
                  ],
                ),
              ),

            // GPS Info
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F8FC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.radar, size: 18, color: violet),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch.latitude != null && branch.longitude != null
                              ? 'GPS: ${branch.latitude!.toStringAsFixed(4)}, ${branch.longitude!.toStringAsFixed(4)}'
                              : 'GPS: Not configured',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textDark,
                          ),
                        ),
                        Text(
                          'Geofence Radius: ${branch.geofenceRadiusMeters} meters',
                          style: const TextStyle(
                            fontSize: 11,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showManagersSheet(branch),
                  icon: const Icon(Icons.manage_accounts, size: 16),
                  label: const Text('Managers', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: violet,
                    side: const BorderSide(color: violet),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 20, color: violet),
                  tooltip: 'Edit Branch',
                  onPressed: () => _openBranchForm(branch),
                ),
                if (branch.isActive)
                  IconButton(
                    icon: const Icon(Icons.block_outlined,
                        size: 20, color: Colors.red),
                    tooltip: 'Deactivate Branch',
                    onPressed: () => _confirmDelete(branch),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchManagersSheet extends StatefulWidget {
  final Branch branch;
  final BranchService branchService;
  final UserService userService;

  const _BranchManagersSheet({
    required this.branch,
    required this.branchService,
    required this.userService,
  });

  @override
  State<_BranchManagersSheet> createState() => _BranchManagersSheetState();
}

class _BranchManagersSheetState extends State<_BranchManagersSheet> {
  static const Color violet = Color(0xFF7C2FCE);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);

  List<BranchManager> _managers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadManagers();
  }

  Future<void> _loadManagers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final managers =
          await widget.branchService.getBranchManagers(widget.branch.branchId);
      if (!mounted) return;
      setState(() {
        _managers = managers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _assignNewManager() async {
    // Load all users to pick from
    try {
      final allUsers = await widget.userService.getUsers();
      if (!mounted) return;

      // Filter out users already assigned to this branch
      final assignedIds = _managers.map((m) => m.userId).toSet();
      final eligible = allUsers.where((u) {
        final uid = u['userId'] ?? u['id'];
        return uid != null && !assignedIds.contains(uid);
      }).toList();

      if (eligible.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All available users are already assigned to this branch.')),
        );
        return;
      }

      int? selectedUserId;
      final assigned = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text('Assign Manager to ${widget.branch.branchName}'),
            content: DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Select User'),
              items: eligible.map((u) {
                final id = (u['userId'] ?? u['id']) as int;
                final name = u['fullName'] ?? u['username'] ?? 'User #$id';
                final role = u['role'] ?? '';
                return DropdownMenuItem<int>(
                  value: id,
                  child: Text('$name ($role)'),
                );
              }).toList(),
              onChanged: (val) => setDialogState(() => selectedUserId = val),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selectedUserId == null
                    ? null
                    : () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: violet),
                child: const Text('Assign', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );

      if (assigned == true && selectedUserId != null) {
        await widget.branchService.assignManager(
          userId: selectedUserId!,
          branchId: widget.branch.branchId,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Manager assigned successfully.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        _loadManagers();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _removeManager(BranchManager mgr) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Manager'),
        content: Text(
          'Remove "${mgr.fullName.isNotEmpty ? mgr.fullName : mgr.username}" from ${widget.branch.branchName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.branchService.removeManager(
          userId: mgr.userId,
          branchId: widget.branch.branchId,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Manager removed from branch.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        _loadManagers();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assigned Managers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    Text(
                      widget.branch.branchName,
                      style: const TextStyle(fontSize: 13, color: textMuted),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _assignNewManager,
                icon: const Icon(Icons.person_add, size: 16, color: Colors.white),
                label: const Text('Assign', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: violet,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(color: violet),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          else if (_managers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No managers assigned to this branch yet.',
                  style: TextStyle(color: textMuted, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _managers.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final m = _managers[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: violet.withValues(alpha: 0.1),
                    child: Text(
                      m.fullName.isNotEmpty
                          ? m.fullName[0].toUpperCase()
                          : m.username.isNotEmpty
                              ? m.username[0].toUpperCase()
                              : 'M',
                      style: const TextStyle(
                        color: violet,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    m.fullName.isNotEmpty ? m.fullName : m.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    m.email.isNotEmpty ? m.email : '@${m.username}',
                    style: const TextStyle(fontSize: 12, color: textMuted),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Remove Assignment',
                    onPressed: () => _removeManager(m),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
