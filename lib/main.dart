import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:al_hadith/firebase_options.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/core/router/app_router.dart';
import 'package:al_hadith/core/database/database_helper.dart';
import 'package:al_hadith/data/repositories/resource_repository.dart';
import 'package:al_hadith/data/repositories/hadith_repository.dart';
import 'package:al_hadith/data/services/download_service.dart';
import 'package:al_hadith/data/services/preferences_service.dart';
import 'package:al_hadith/data/services/history_service.dart';
import 'package:al_hadith/data/services/backup_service.dart';
import 'package:al_hadith/logic/setup/setup_cubit.dart';
import 'package:al_hadith/logic/hadiths/hadith_cubit.dart';
import 'package:al_hadith/logic/settings/settings_cubit.dart';
import 'package:al_hadith/logic/auth/auth_cubit.dart';

void main() async {
  // Ensure Flutter engine is fully bootstrapped
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences persistently
  final sharedPrefs = await SharedPreferences.getInstance();
  final prefsService = PreferencesService(sharedPrefs);
  final historyService = HistoryService(sharedPrefs);

  // Initialize services and repositories
  final dbHelper = DatabaseHelper();
  final resourceRepository = ResourceRepository();
  final hadithRepository = HadithRepository(dbHelper);
  final downloadService = DownloadService(prefsService);
  final appRouter = AppRouter(prefsService);

  // Firebase services
  final firebaseAuth = FirebaseAuth.instance;
  final firebaseDb = FirebaseDatabase.instance;
  final backupService = BackupService(
    db: firebaseDb,
    historyService: historyService,
    prefsService: prefsService,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PreferencesService>.value(value: prefsService),
        RepositoryProvider<HistoryService>.value(value: historyService),
        RepositoryProvider<ResourceRepository>.value(value: resourceRepository),
        RepositoryProvider<HadithRepository>.value(value: hadithRepository),
        RepositoryProvider<DownloadService>.value(value: downloadService),
        RepositoryProvider<BackupService>.value(value: backupService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SetupCubit>(
            create: (context) => SetupCubit(
              repository: resourceRepository,
              downloadService: downloadService,
              prefs: prefsService,
            ),
          ),
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              auth: firebaseAuth,
              backupService: backupService,
              prefs: prefsService,
            ),
          ),
          BlocProvider<HadithCubit>(
            create: (context) => HadithCubit(
              hadithRepository: hadithRepository,
              resourceRepository: resourceRepository,
              historyService: historyService,
              authCubit: context.read<AuthCubit>(),
            ),
          ),
          BlocProvider<SettingsCubit>(
            create: (context) => SettingsCubit(prefsService),
          ),
        ],
        child: MyApp(appRouter: appRouter),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;

  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Al Hadith',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter.router,
    );
  }
}
