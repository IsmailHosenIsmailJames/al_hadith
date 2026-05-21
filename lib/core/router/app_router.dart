import 'package:go_router/go_router.dart';
import 'package:al_hadith/data/services/preferences_service.dart';
import 'package:al_hadith/presentation/screens/setup_wizard_screen.dart';
import 'package:al_hadith/presentation/screens/home_screen.dart';
import 'package:al_hadith/presentation/screens/book_sections_screen.dart';
import 'package:al_hadith/presentation/screens/hadith_read_placeholder_screen.dart';
import 'package:al_hadith/presentation/screens/hadith_search_screen.dart';
import 'package:al_hadith/presentation/screens/settings_screen.dart';
import 'package:al_hadith/presentation/screens/manage_resources_screen.dart';

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
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const HadithSearchScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/resources',
        name: 'resources',
        builder: (context, state) => const ManageResourcesScreen(),
      ),
      GoRoute(
        path: '/book/:bookKey',
        name: 'book_sections',
        builder: (context, state) {
          final bookKey = state.pathParameters['bookKey'] ?? '';
          return BookSectionsScreen(bookKey: bookKey);
        },
      ),
      GoRoute(
        path: '/book/:bookKey/hadith/:hadithNum',
        name: 'hadith_read',
        builder: (context, state) {
          final bookKey = state.pathParameters['bookKey'] ?? '';
          final hadithNumStr = state.pathParameters['hadithNum'] ?? '1';
          final hadithNum = int.tryParse(hadithNumStr) ?? 1;
          
          final params = state.uri.queryParameters;
          final parsedSectionId = params['sectionId'] != null ? int.tryParse(params['sectionId']!) : null;
          final sectionName = params['sectionName'] ?? '';
          
          return HadithReadPlaceholderScreen(
            bookKey: bookKey,
            initialHadithNumber: hadithNum,
            initialSectionId: parsedSectionId,
            sectionName: sectionName,
          );
        },
      ),
    ],
  );
}
