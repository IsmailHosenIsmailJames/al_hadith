import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/logic/setup/setup_cubit.dart';
import 'package:al_hadith/logic/setup/setup_state.dart';
import 'package:al_hadith/core/localization/app_localization.dart';
import 'package:al_hadith/logic/settings/settings_cubit.dart';
import 'package:al_hadith/presentation/widgets/language_step.dart';
import 'package:al_hadith/presentation/widgets/resource_step.dart';
import 'package:al_hadith/presentation/widgets/download_step.dart';

class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch initial load event
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SetupCubit>().loadInitialMetadata();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;
    final isWideWindow = MediaQuery.of(context).size.width > AppTheme.wideWidth;
    final canvasColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: canvasColor,
      body: SafeArea(
        child: BlocConsumer<SetupCubit, SetupState>(
          listener: (context, state) {
            // Handle error messages with premium Snackbar
            if (state.errorMessage != null) {
              String displayError = state.errorMessage!;
              if (displayError == 'Please select a language to proceed.') {
                displayError = AppLocalization.get('select_language_err', appLanguage);
              } else if (displayError == 'Please select at least one resource.') {
                displayError = AppLocalization.get('select_resource_err', appLanguage);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    displayError,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading && state.languages.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryMint),
              );
            }

            // Render Success State when complete
            if (state.isCompletedStep) {
              return _buildSuccessScreen(context, state, appLanguage);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 14.0,
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: isWideWindow ? 90.0 : 0.0),
                    child: Column(
                      children: [
                        if (!isWideWindow) _buildSacredStepperCapsule(state, false, appLanguage),
                        if (!isWideWindow) const Gap(16),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: 300.ms,
                            child: _buildCurrentStep(state),
                          ),
                        ),
                        _buildBottomNavBar(context, state, appLanguage),
                      ],
                    ),
                  ),
                  if (isWideWindow)
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildSacredStepperCapsule(state, true, appLanguage),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Sacred Stepper Header: Floating capsule with distinct Completed / Active / Upcoming states
  Widget _buildSacredStepperCapsule(SetupState state, bool isWideWindow, String appLanguage) {
    int activeIndex = 0;
    if (state.isSecondStep) activeIndex = 1;
    if (state.isDownloadingStep) activeIndex = 2;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final capsuleBg = isDark ? AppTheme.darkSurface : Colors.white;
    final capsuleBorder = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    final steps = [
      {'label': AppLocalization.get('language', appLanguage), 'icon': Icons.language_rounded},
      {'label': AppLocalization.get('resources', appLanguage), 'icon': Icons.menu_book_rounded},
      {'label': AppLocalization.get('install', appLanguage), 'icon': Icons.cloud_download_rounded},
    ];

    if (isWideWindow) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        decoration: BoxDecoration(
          color: capsuleBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: capsuleBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < steps.length; i++) ...[
              _buildStepPill(
                index: i,
                label: steps[i]['label'] as String,
                icon: steps[i]['icon'] as IconData,
                isCompleted: activeIndex > i,
                isActive: activeIndex == i,
              ),
              if (i < steps.length - 1)
                _buildLineConnector(isDone: activeIndex > i, isWideWindow: true),
            ],
          ],
        ),
      ).animate().fadeIn(duration: 350.ms);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: capsuleBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: capsuleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _buildStepPill(
              index: i,
              label: steps[i]['label'] as String,
              icon: steps[i]['icon'] as IconData,
              isCompleted: activeIndex > i,
              isActive: activeIndex == i,
            ),
            if (i < steps.length - 1)
              _buildLineConnector(isDone: activeIndex > i, isWideWindow: false),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 350.ms);
  }

  Widget _buildStepPill({
    required int index,
    required String label,
    required IconData icon,
    required bool isCompleted,
    required bool isActive,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final tickColor = isDark ? AppTheme.darkCanvas : Colors.white;

    Color circleBg;
    Color circleBorder;
    Widget iconWidget;

    if (isCompleted) {
      circleBg = AppTheme.primaryMint;
      circleBorder = AppTheme.primaryMint;
      iconWidget = Icon(Icons.check_rounded, color: tickColor, size: 16);
    } else if (isActive) {
      circleBg = AppTheme.primaryMint.withValues(alpha: 0.15);
      circleBorder = AppTheme.primaryMint;
      iconWidget = Icon(icon, color: AppTheme.primaryMint, size: 16);
    } else {
      circleBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
      circleBorder = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
      iconWidget = Icon(
        icon,
        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        size: 15,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: 250.ms,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleBg,
            border: Border.all(color: circleBorder, width: isActive ? 1.8 : 1.2),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primaryMint.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(child: iconWidget),
        ),
        const Gap(4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            color: isActive
                ? AppTheme.primaryMint
                : (isCompleted
                    ? (isDark ? Colors.white : AppTheme.textDark)
                    : textSecondary),
            fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLineConnector({required bool isDone, required bool isWideWindow}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final connectorColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    if (isWideWindow) {
      return Container(
        width: 2,
        height: 24,
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: isDone ? AppTheme.primaryMint : connectorColor,
      );
    } else {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14.0, left: 6.0, right: 6.0),
          child: AnimatedContainer(
            duration: 250.ms,
            height: 2,
            color: isDone ? AppTheme.primaryMint : connectorColor,
          ),
        ),
      );
    }
  }

  // Current active step view selector
  Widget _buildCurrentStep(SetupState state) {
    switch (state.step) {
      case SetupStep.languageSelection:
        return LanguageStep(
          key: const ValueKey('lang_step'),
          state: state,
          onSelected: (lang) {
            context.read<SetupCubit>().selectLanguage(lang);
            context.read<SettingsCubit>().updateLanguageImplicitly(lang.code);
          },
        );
      case SetupStep.resourceSelection:
        return ResourceStep(
          key: const ValueKey('resource_step'),
          state: state,
          onToggle: (bookKey) =>
              context.read<SetupCubit>().toggleResourceSelection(bookKey),
          onSelectRecommended: () =>
              context.read<SetupCubit>().selectRecommendedResources(),
          onSelectAll: () =>
              context.read<SetupCubit>().selectAllResources(),
          onClearAll: () =>
              context.read<SetupCubit>().clearAllResources(),
        );
      case SetupStep.downloading:
        return DownloadStep(key: const ValueKey('download_step'), state: state);
      case SetupStep.completed:
        return const SizedBox.shrink();
    }
  }

  // Bottom action buttons
  Widget _buildBottomNavBar(BuildContext context, SetupState state, String appLanguage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final outlineBorderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    if (state.isDownloadingStep) {
      // In downloading step: if we hit an error, let the user retry
      final hasError = state.downloadStatus.values.any(
        (status) => status == 'Error',
      );
      if (hasError) {
        return Padding(
          padding: const EdgeInsets.only(top: 14.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.read<SetupCubit>().startDownload(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shadowColor: Colors.redAccent.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(AppLocalization.get('retry_setup_download', appLanguage)),
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink(); // No navigation keys during download to prevent wizard break
    }

    final isFirst = state.isFirstStep;

    return Padding(
      padding: const EdgeInsets.only(top: 14.0),
      child: Row(
        children: [
          if (!isFirst) ...[
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: () => context.read<SetupCubit>().previousStep(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textPrimary,
                  side: BorderSide(color: outlineBorderColor, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 17),
                label: Text(
                  AppLocalization.get('back', appLanguage),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Gap(12),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => context.read<SetupCubit>().nextStep(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(
                isFirst ? Icons.arrow_forward_rounded : Icons.cloud_download_rounded,
                size: 18,
              ),
              label: Text(
                isFirst
                    ? AppLocalization.get('continue_to_resources', appLanguage)
                    : AppLocalization.get('download_offline_library', appLanguage, args: {'size': state.formattedTotalSize}),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Setup completion visual dashboard & celebration launchpad
  Widget _buildSuccessScreen(BuildContext context, SetupState state, String appLanguage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final cardBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    final selectedBooksCount = state.selectedResources.length;

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Gap(20),

            // Glowing checkmark decoration
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryMint.withValues(alpha: 0.12),
                border: Border.all(color: AppTheme.primaryMint, width: 2.2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryMint.withValues(alpha: 0.25),
                    blurRadius: 36,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.verified_rounded,
                  color: AppTheme.primaryMint,
                  size: 52,
                ),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

            const Gap(24),

            Text(
              AppLocalization.get('library_ready', appLanguage),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                letterSpacing: 0.2,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            const Gap(8),
            Text(
              AppLocalization.get('setup_success_desc', appLanguage),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: textSecondary,
                height: 1.45,
              ),
            ).animate().fadeIn(duration: 450.ms, delay: 180.ms),

            const Gap(24),

            // Installed Library Summary Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryMetric(
                    icon: Icons.menu_book_rounded,
                    value: '$selectedBooksCount',
                    label: 'Books Ready',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: borderColor,
                  ),
                  _buildSummaryMetric(
                    icon: Icons.search_rounded,
                    value: 'Instant',
                    label: 'Offline Search',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: borderColor,
                  ),
                  _buildSummaryMetric(
                    icon: Icons.offline_pin_rounded,
                    value: '100%',
                    label: 'No Internet',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 450.ms, delay: 240.ms),

            const Gap(24),

            // Sacred Prophetic Hadith Quote on Knowledge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          AppTheme.primaryMint.withValues(alpha: 0.1),
                          AppTheme.darkSurfaceCard,
                        ]
                      : [
                          const Color(0xFFE8FAF5),
                          Colors.white,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryMint.withValues(alpha: 0.25),
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الْجَنَّةِ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryMint,
                      height: 1.6,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    '"Whoever travels a path in search of sacred knowledge, Allah will make easy for him a path to Paradise."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12.5,
                      color: textPrimary,
                      height: 1.35,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    '— Sahih Muslim',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 450.ms, delay: 300.ms),

            const Gap(32),

            // Pulsing Primary CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.menu_book_rounded, size: 20),
                label: Text(
                  AppLocalization.get('enter_hadith_library', appLanguage),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
              .custom(
                duration: 1.6.seconds,
                builder: (context, value, child) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryMint.withValues(
                          alpha: 0.15 + (value * 0.18),
                        ),
                        blurRadius: 10 + (value * 14),
                        spreadRadius: value * 3,
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 360.ms),

            const Gap(20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric({
    required IconData icon,
    required String value,
    required String label,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.primaryMint, size: 20),
        const Gap(4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: textSecondary,
          ),
        ),
      ],
    );
  }
}
