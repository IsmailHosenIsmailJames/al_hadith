import 'package:al_hadith/database/app_database.dart';
import 'package:al_hadith/screens/navs/navs.dart';
import 'package:al_hadith/theme/app_colors.dart';
import 'package:flutter/material.dart';

final AppDatabase db = AppDatabase();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
      ),
      themeMode: ThemeMode.light,
      home: Navs(),
    );
  }
}
