import 'package:flutter/material.dart';
import 'ui/splash/splash_view.dart';

void main() {
  runApp(const AlienHRApp());
}

class AlienHRApp extends StatelessWidget {
  const AlienHRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alien HR',
      debugShowCheckedModeBanner: false,
      home: const SplashView(),
    );
  }
}