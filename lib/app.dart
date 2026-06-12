import 'package:flutter/material.dart';

import 'features/auth/auth_gate.dart';
import 'theme/app_theme.dart';

class StyleLeagueApp extends StatelessWidget {
  const StyleLeagueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StyleLeague',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}