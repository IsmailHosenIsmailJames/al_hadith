import 'package:al_hadith/src/routes/app_routes.dart';
import 'package:al_hadith/src/setup/screens/setup_language_selection_screen.dart';
import 'package:al_hadith/src/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp(initialRoute: SetupLanguageSelectionScreen.routeName));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Al Hadith',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: AppColors.primary)),
      routerConfig: AppRoutes.getAppRoutes(initialRoute),
    );
  }
}
