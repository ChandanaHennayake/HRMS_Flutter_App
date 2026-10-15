import 'package:flutter/material.dart';

import 'core/network/api_client.dart';
import 'core/network/connectivity_service.dart';
import 'ui/auth/auth_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ConnectivityService().initialize();

  runApp(const AlienHrApp());
}

class AlienHrApp extends StatelessWidget {
  const AlienHrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: ApiClient.navigatorKey,
      scaffoldMessengerKey: ConnectivityService.messengerKey,
      title: 'AlienHR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C2FCE),
        ),
      ),
      home: const AuthGate(),
    );
  }
}