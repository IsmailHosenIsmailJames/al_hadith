import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/setup_bloc.dart';
import '../repository/setup_repository.dart';
import 'setup_resource_selection_screen.dart';

class SetupLanguageSelectionScreen extends StatelessWidget {
  static const String routeName = '/setup-language-selection';
  const SetupLanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SetupBloc(SetupRepository())..add(LoadInitialData()),
      child: const _SetupLanguageSelectionView(),
    );
  }
}

class _SetupLanguageSelectionView extends StatelessWidget {
  const _SetupLanguageSelectionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              Text(
                'Welcome to Al Hadith',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Select your preferred language',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: BlocBuilder<SetupBloc, SetupState>(
                  builder: (context, state) {
                    if (state.status == SetupStatus.initial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final languages = SetupRepository().getAvailableLanguages(
                      state.allHadithInfo,
                    );

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: languages.length,
                      itemBuilder: (context, index) {
                        final langCode = languages[index];
                        final langName = SetupRepository().getLanguageName(
                          langCode,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _LanguageCard(
                            name: langName,
                            code: langCode,
                            onTap: () {
                              context.read<SetupBloc>().add(
                                SelectAppLanguage(langCode),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<SetupBloc>(),
                                    child: const SetupResourceSelectionScreen(),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String name;
  final String code;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.name,
    required this.code,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  code.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
