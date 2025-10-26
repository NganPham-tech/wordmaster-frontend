import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

import 'screens/main_scaffold.dart';
void main() {
  runApp(const WordMasterApp());
}

class WordMasterApp extends StatelessWidget {
  const WordMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WordMaster',
      theme: AppTheme.lightTheme,
      home: const MainScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}
