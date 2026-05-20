import 'package:go_router/go_router.dart';
import 'package:al_hadith/data/services/preferences_service.dart';
import 'package:al_hadith/presentation/screens/setup_wizard_screen.dart';
import 'package:al_hadith/presentation/screens/home_screen.dart';

class AppRouter {
  final PreferencesService _prefs;

  AppRouter(this._prefs);

  late final GoRouter router = GoRouter(
    initialLocation: _prefs.isSetupCompleted() ? '/home' : '/setup',
    routes: [
      GoRoute(
        path: '/setup',
        name: 'setup',
        builder: (context, state) => const SetupWizardScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
