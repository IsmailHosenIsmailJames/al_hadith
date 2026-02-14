import 'package:flutter/material.dart';

class AppLanguageSetupScreen extends StatefulWidget {
  static const String routeName = '/app_language_setup';
  const AppLanguageSetupScreen({super.key});

  @override
  State<AppLanguageSetupScreen> createState() => _AppLanguageSetupScreenState();
}

class _AppLanguageSetupScreenState extends State<AppLanguageSetupScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('App Language Setup')));
  }
}
