import 'package:go_router/go_router.dart';
import '../setup/screens/setup_language_selection_screen.dart';
import '../home/screens/home_screen.dart';

class AppRoutes {
  static GoRouter getAppRoutes(String initialRoute) {
    return GoRouter(
      initialLocation: initialRoute,
      routes: [
        GoRoute(
          path: SetupLanguageSelectionScreen.routeName,
          builder: (context, state) => const SetupLanguageSelectionScreen(),
        ),
        GoRoute(
          path: HomeScreen.routeName,
          builder: (context, state) => const HomeScreen(),
        ),
        // Placeholder for root path
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      ],
    );
  }
}
