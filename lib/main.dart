import 'package:al_hadith/src/core/locale/locale_cubit.dart';
import 'package:al_hadith/src/core/routes/app_router.dart';
import 'package:al_hadith/src/hadith_list/bloc/hadith_list_cubit.dart';
import 'package:al_hadith/src/hadith_sections/bloc/sections_cubit.dart';
import 'package:al_hadith/src/home/bloc/home_cubit.dart';
import 'package:al_hadith/src/home/screens/home_screen.dart';
import 'package:al_hadith/src/setup/bloc/setup_cubit.dart';
import 'package:al_hadith/src/core/theme/theme_cubit.dart';
import 'package:al_hadith/src/setup/screens/app_language_setup_screen.dart';
import 'package:al_hadith/src/setup/screens/hadith_resource_download_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final setupComplete = await HadithResourceDownloadScreen.isSetupComplete();
  final initialLocation = setupComplete
      ? HomeScreen.routeName
      : AppLanguageSetupScreen.routeName;

  runApp(MyApp(initialLocation: initialLocation));
}

class MyApp extends StatefulWidget {
  final String initialLocation;
  const MyApp({super.key, required this.initialLocation});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(widget.initialLocation);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (_) => SetupCubit()),
        BlocProvider(create: (_) => HomeCubit()),
        BlocProvider(create: (_) => SectionsCubit()),
        BlocProvider(create: (_) => HadithListCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Al Hadith',
                theme: themeState.themeData,
                routerConfig: _router,
                locale: locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: supportedLocales,
              );
            },
          );
        },
      ),
    );
  }
}
