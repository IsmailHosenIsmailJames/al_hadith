import 'package:al_hadith/src/hadith_list/screens/hadith_list_screen.dart';
import 'package:al_hadith/src/hadith_sections/screens/sections_screen.dart';
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
    GoRoute(
      path: '/sections/:bookId',
      builder: (context, state) {
        final bookId = state.pathParameters['bookId']!;
        final bookName = state.uri.queryParameters['name'] ?? 'Book';
        return SectionsScreen(bookId: bookId, bookName: bookName);
      },
    ),
    GoRoute(
      path: '/hadiths/:bookId/:sectionId',
      builder: (context, state) {
        final bookId = state.pathParameters['bookId']!;
        final sectionId = int.parse(state.pathParameters['sectionId']!);
        final sectionName = state.uri.queryParameters['name'] ?? 'Section';
        return HadithListScreen(
          bookId: bookId,
          sectionId: sectionId,
          sectionName: sectionName,
        );
      },
    ),
  ],
);
