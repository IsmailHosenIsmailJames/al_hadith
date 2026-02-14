import 'package:al_hadith/src/home/screens/home_screen.dart';
import 'package:al_hadith/src/setup/screens/app_language_setup_screen.dart';
import 'package:al_hadith/src/setup/screens/hadith_resource_download_screen.dart';
import 'package:al_hadith/src/setup/screens/hadith_resources_selection_screen.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter(String initialLocation) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(
      path: HomeScreen.routeName,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppLanguageSetupScreen.routeName,
      builder: (context, state) => const AppLanguageSetupScreen(),
    ),
    GoRoute(
      path: HadithResourcesSelectionScreen.routeName,
      builder: (context, state) => const HadithResourcesSelectionScreen(),
    ),
    GoRoute(
      path: HadithResourceDownloadScreen.routeName,
      builder: (context, state) => const HadithResourceDownloadScreen(),
    ),
  ],
);
