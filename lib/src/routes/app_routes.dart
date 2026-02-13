import 'package:al_hadith/src/setup/screens/setup_language_selection_screen.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static GoRouter getAppRoutes(String initialRoute) {
    return GoRouter(
      initialLocation: initialRoute,
      routes: [
        GoRoute(
          path: SetupLanguageSelectionScreen.routeName,
          builder: (context, state) => const SetupLanguageSelectionScreen(),
        ),
      ],
    );
  }
}
