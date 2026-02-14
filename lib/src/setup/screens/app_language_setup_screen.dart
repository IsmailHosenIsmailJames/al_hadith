import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale/locale_cubit.dart';
import '../bloc/setup_cubit.dart';
import '../models/hadith_info_model.dart';
import 'hadith_resources_selection_screen.dart';

class AppLanguageSetupScreen extends StatefulWidget {
  static const String routeName = '/app_language_setup';
  const AppLanguageSetupScreen({super.key});

  @override
  State<AppLanguageSetupScreen> createState() => _AppLanguageSetupScreenState();
}

class _AppLanguageSetupScreenState extends State<AppLanguageSetupScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedCode3;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    // Pre-select language matching the current locale
    final currentLocale = context.read<LocaleCubit>().state;
    final match = LanguageInfo.all.where(
      (l) => l.localeCode == currentLocale.languageCode,
    );
    if (match.isNotEmpty) {
      _selectedCode3 = match.first.code3;
    }

    // Load resources
    context.read<SetupCubit>().loadResources();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),
                // Header icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.translate_rounded,
                    size: 32,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Choose Your Language',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select the language for the app interface',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),

                // Language grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: size.width > 600 ? 3 : 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: LanguageInfo.all.length,
                    itemBuilder: (context, index) {
                      final lang = LanguageInfo.all[index];
                      final isSelected = _selectedCode3 == lang.code3;
                      return _LanguageCard(
                        lang: lang,
                        isSelected: isSelected,
                        onTap: () =>
                            setState(() => _selectedCode3 = lang.code3),
                      );
                    },
                  ),
                ),

                // Continue button
                Padding(
                  padding: const EdgeInsets.only(bottom: 32, top: 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _selectedCode3 == null ? null : _onContinue,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onContinue() {
    final langInfo = LanguageInfo.fromCode3(_selectedCode3!);

    // Change app locale
    context.read<LocaleCubit>().changeLocale(Locale(langInfo.localeCode));

    // Set language in setup cubit & pre-select resources
    context.read<SetupCubit>().selectAppLanguage(_selectedCode3!);

    // Navigate
    context.go(HadithResourcesSelectionScreen.routeName);
  }
}

// ────────────────────────────────────────────────────────────
// Language Card Widget
// ────────────────────────────────────────────────────────────

class _LanguageCard extends StatelessWidget {
  final LanguageInfo lang;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.lang,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: isSelected
          ? cs.primaryContainer.withValues(alpha: 0.25)
          : cs.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? cs.primary
                  : cs.outline.withValues(alpha: 0.3),
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(lang.flag, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                lang.nativeName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? cs.primary : cs.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                lang.englishName,
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
