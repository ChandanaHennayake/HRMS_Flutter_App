import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../notice/notice_dialog.dart';
import 'admin/admin_dashboard.dart';
import 'employee/employee_dashboard.dart';
import 'manager/manager_dashboard.dart';

class HomeView extends StatefulWidget {
  final User user;

  const HomeView({
    super.key,
    required this.user,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        NoticeDialog.checkAndShow(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.user.roleId) {
      case 1:
      case 2:
        return AdminDashboard(user: widget.user);

      case 3:
        return ManagerDashboard(user: widget.user);

      case 4:
        return EmployeeDashboard(user: widget.user);

      default:
        return Scaffold(
          backgroundColor: const Color(0xFFF7F5FA),
          appBar: AppBar(
            title: const Text('AlienHR'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No dashboard is available for Role ID ${widget.user.roleId}.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
    }
  }
}