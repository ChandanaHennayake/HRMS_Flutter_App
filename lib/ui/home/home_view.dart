import 'package:flutter/material.dart';

import '../../models/user.dart';
import 'admin/admin_dashboard.dart';
import 'employee/employee_dashboard.dart';
import 'manager/manager_dashboard.dart';

class HomeView extends StatelessWidget {
  final User user;

  const HomeView({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    switch (user.roleId) {
      case 1:
      case 2:
        return AdminDashboard(user: user);

      case 3:
        return ManagerDashboard(user: user);

      case 4:
        return EmployeeDashboard(user: user);

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
                'No dashboard is available for Role ID ${user.roleId}.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
    }
  }
}