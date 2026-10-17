import 'package:flutter/material.dart';

import '../../models/admin_user.dart';
import '../../models/lookup_item.dart';
import '../../models/user.dart';
import '../../services/lookup_service.dart';
import '../../services/user_service.dart';

class UserManagementPage extends StatefulWidget {
  final User user;

  const UserManagementPage({
    super.key,
    required this.user,
  });

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  static const Color violet = Color(0xFF7C2FCE);
  static const Color background = Color(0xFFF7F5FA);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);

  final UserService _userService = UserService();
  final LookupService _lookupService = LookupService();

  List<AdminUserItem> _users = [];
  bool _isLoading = true;
  String? _error;

  String _searchQuery = '';
  String _selectedRoleFilter = 'All';

  List<LookupItem> _roles = [];
  List<LookupItem> _branches = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _userService.getAllUsers(),
        _lookupService.getRoles(companyId: widget.user.companyId),
        _lookupService.getBranches(companyId: widget.user.companyId),
      ]);

      if (!mounted) return;

      setState(() {
        _users = results[0] as List<AdminUserItem>;
        _roles = results[1] as List<LookupItem>;
        _branches = results[2] as List<LookupItem>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  List<AdminUserItem> get _filteredUsers {
    return _users.where((u) {
      final matchesQuery = _searchQuery.isEmpty ||
          u.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesRole = _selectedRoleFilter == 'All' ||
          u.role.toLowerCase() == _selectedRoleFilter.toLowerCase();

      return matchesQuery && matchesRole;
    }).toList();
  }

  // ============================================================
  // ADD USER DIALOG
  // ============================================================

  void _openAddUserDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddUserSheet(
        companyId: widget.user.companyId,
        roles: _roles,
        branches: _branches,
        onUserCreated: () {
          Navigator.pop(ctx);
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User account created successfully.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // DELETE USER
  // ============================================================

  Future<void> _confirmDeleteUser(AdminUserItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User Account'),
        content: Text('Are you sure you want to delete user "${item.username}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await _userService.deleteUser(item.userId);
      _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddUserDialog,
        backgroundColor: violet,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text(
          'Add User',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: violet,
        child: Column(
          children: [
            // Search & Filter header
            _buildSearchAndFilters(),

            // List of Users
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final roles = ['All', 'Admin', 'Manager', 'Employee'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          // Search TextField
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search by name, username or email...',
              hintStyle: const TextStyle(fontSize: 13.5, color: Colors.grey),
              prefixIcon: const Icon(Icons.search_rounded, color: violet, size: 20),
              filled: true,
              fillColor: const Color(0xFFF7F5FA),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Role Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: roles.map((r) {
                final isSelected = _selectedRoleFilter == r;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(r),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedRoleFilter = r),
                    selectedColor: violet.withValues(alpha: 0.15),
                    checkmarkColor: violet,
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? violet : textDark,
                    ),
                    backgroundColor: const Color(0xFFF7F5FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? violet : Colors.transparent,
                      ),
                    ),
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

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: textDark),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(backgroundColor: violet),
              ),
            ],
          ),
        ),
      );
    }

    final users = _filteredUsers;

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline_rounded, size: 54, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'No users found',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try a different search term or add a new user.',
              style: TextStyle(fontSize: 13, color: textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final u = users[index];
        return _buildUserCard(u);
      },
    );
  }

  Widget _buildUserCard(AdminUserItem u) {
    Color roleBadgeColor;
    Color roleTextColor;
    switch (u.role.toLowerCase()) {
      case 'admin':
        roleBadgeColor = const Color(0xFFF3E8FF);
        roleTextColor = const Color(0xFF7C2FCE);
        break;
      case 'manager':
        roleBadgeColor = const Color(0xFFFEF3C7);
        roleTextColor = const Color(0xFFD97706);
        break;
      default:
        roleBadgeColor = const Color(0xFFE0F2FE);
        roleTextColor = const Color(0xFF0284C7);
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: roleTextColor.withValues(alpha: 0.15),
              child: Text(
                u.fullName.isNotEmpty
                    ? u.fullName[0].toUpperCase()
                    : u.username.isNotEmpty
                        ? u.username[0].toUpperCase()
                        : 'U',
                style: TextStyle(
                  color: roleTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          u.fullName.isNotEmpty ? u.fullName : u.username,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: roleBadgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          u.role.isNotEmpty ? u.role : 'Employee',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: roleTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '@${u.username}',
                    style: const TextStyle(fontSize: 12.5, color: textMuted),
                  ),
                  if (u.email.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      u.email,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Delete Action
            if (u.username != 'admin')
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                onPressed: () => _confirmDeleteUser(u),
              ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ADD USER MODAL SHEET
// ================================================================

class _AddUserSheet extends StatefulWidget {
  final int companyId;
  final List<LookupItem> roles;
  final List<LookupItem> branches;
  final VoidCallback onUserCreated;

  const _AddUserSheet({
    required this.companyId,
    required this.roles,
    required this.branches,
    required this.onUserCreated,
  });

  @override
  State<_AddUserSheet> createState() => _AddUserSheetState();
}

class _AddUserSheetState extends State<_AddUserSheet> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  int? _selectedRoleId;
  int? _selectedBranchId;
  bool _isSubmitting = false;
  bool _hidePassword = true;

  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    if (widget.roles.isNotEmpty) {
      _selectedRoleId = widget.roles.first.id;
    }
    if (widget.branches.isNotEmpty) {
      _selectedBranchId = widget.branches.first.id;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _userService.createUser(
        companyId: widget.companyId,
        branchId: _selectedBranchId,
        roleId: _selectedRoleId!,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      widget.onUserCreated();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '').trim()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create New User',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF211B2E),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),

              // Username & Password
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: _inputDecoration('Username *', Icons.account_circle_outlined),
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      decoration: _inputDecoration(
                        'Password *',
                        Icons.lock_outline_rounded,
                        suffix: IconButton(
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                          ),
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                        ),
                      ),
                      validator: (val) =>
                          (val == null || val.length < 6) ? 'Min 6 chars' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // First Name & Last Name
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: _inputDecoration('First Name *', Icons.badge_outlined),
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: _inputDecoration('Last Name', Icons.badge_outlined),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Email & Phone
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration('Email *', Icons.email_outlined),
                      validator: (val) =>
                          (val == null || !val.contains('@')) ? 'Valid email required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration('Phone', Icons.phone_outlined),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Role Dropdown
              DropdownButtonFormField<int>(
                initialValue: _selectedRoleId,
                decoration: _inputDecoration('Role *', Icons.security_outlined),
                items: widget.roles.map((r) {
                  return DropdownMenuItem<int>(
                    value: r.id,
                    child: Text(r.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedRoleId = val),
              ),

              const SizedBox(height: 14),

              // Branch Dropdown
              DropdownButtonFormField<int>(
                initialValue: _selectedBranchId,
                decoration: _inputDecoration('Branch', Icons.business_outlined),
                items: widget.branches.map((b) {
                  return DropdownMenuItem<int>(
                    value: b.id,
                    child: Text(b.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedBranchId = val),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C2FCE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      prefixIcon: Icon(icon, color: const Color(0xFF7C2FCE), size: 18),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF7C2FCE), width: 1.5),
      ),
    );
  }
}
