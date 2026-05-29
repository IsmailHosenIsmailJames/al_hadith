import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
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
    bool isWideWindow = MediaQuery.of(context).size.width > AppTheme.wideWidth;
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
              return _buildSuccessScreen(context, appLanguage);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: isWideWindow ? 80.0 : 0.0),
                    child: Column(
                      children: [
                        if (!isWideWindow) _buildHeaderProgress(state, false, appLanguage),
                        if (!isWideWindow) const Gap(24),
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
                      child: _buildHeaderProgress(state, true, appLanguage),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Header progress/stepper widget
  Widget _buildHeaderProgress(SetupState state, bool isWideWindow, String appLanguage) {
    int activeIndex = 0;
    if (state.isSecondStep) activeIndex = 1;
    if (state.isDownloadingStep) activeIndex = 2;
    if (isWideWindow) {
      return Column(
        children: [
          _buildStepIndicator(0, AppLocalization.get('language', appLanguage), activeIndex >= 0),
          _buildLineConnector(activeIndex >= 1, isWideWindow),
          _buildStepIndicator(1, AppLocalization.get('resources', appLanguage), activeIndex >= 1),
          _buildLineConnector(activeIndex >= 2, isWideWindow),
          _buildStepIndicator(2, AppLocalization.get('install', appLanguage), activeIndex >= 2),
        ],
      ).animate().fadeIn(duration: 400.ms);
    } else {
      return Row(
        children: [
          _buildStepIndicator(0, AppLocalization.get('language', appLanguage), activeIndex >= 0),
          _buildLineConnector(activeIndex >= 1, isWideWindow),
          _buildStepIndicator(1, AppLocalization.get('resources', appLanguage), activeIndex >= 1),
          _buildLineConnector(activeIndex >= 2, isWideWindow),
          _buildStepIndicator(2, AppLocalization.get('install', appLanguage), activeIndex >= 2),
        ],
      ).animate().fadeIn(duration: 400.ms);
    }
  }

  Widget _buildStepIndicator(int index, String label, bool isCompleted) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final inactiveBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6);
    final inactiveBorderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final inactiveTextColor = isDark ? Colors.white : AppTheme.textDark;
    final tickColor = isDark ? AppTheme.darkCanvas : Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: 300.ms,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppTheme.primaryMint : inactiveBgColor,
            border: Border.all(
              color: isCompleted
                  ? AppTheme.primaryMint
                  : inactiveBorderColor,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: tickColor, size: 18)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: inactiveTextColor,
                    ),
                  ),
          ),
        ),
        const Gap(6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isCompleted ? AppTheme.primaryMint : textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLineConnector(bool isDone, bool isWideWindow) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final connectorColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);

    if (isWideWindow) {
      return Expanded(
        child: AnimatedContainer(
          duration: 300.ms,
          width: 2,
          color: isDone ? AppTheme.primaryMint : connectorColor,
        ),
      );
    } else {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: AnimatedContainer(
            duration: 300.ms,
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
    final outlineBorderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);

    if (state.isDownloadingStep) {
      // In downloading step: if we hit an error, let the user retry
      final hasError = state.downloadStatus.values.any(
        (status) => status == 'Error',
      );
      if (hasError) {
        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.read<SetupCubit>().startDownload(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shadowColor: Colors.redAccent.withValues(alpha: 0.3),
                  ),
                  child: Text(AppLocalization.get('retry_setup_download', appLanguage)),
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
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: [
          if (!isFirst) ...[
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => context.read<SetupCubit>().previousStep(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textPrimary,
                  side: BorderSide(color: outlineBorderColor, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(AppLocalization.get('back', appLanguage)),
              ),
            ),
            const Gap(16),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => context.read<SetupCubit>().nextStep(),
              child: Text(
                isFirst
                    ? AppLocalization.get('continue_to_resources', appLanguage)
                    : AppLocalization.get('download_offline_library', appLanguage, args: {'size': state.formattedTotalSize}),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Setup completion visual dashboard
  Widget _buildSuccessScreen(BuildContext context, String appLanguage) {
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glowing checkmark decoration
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryMint.withValues(alpha: 0.12),
              border: Border.all(color: AppTheme.primaryMint, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryMint.withValues(alpha: 0.2),
                  blurRadius: 32,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.done_all,
                color: AppTheme.primaryMint,
                size: 48,
              ),
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const Gap(32),

          Text(
            AppLocalization.get('library_ready', appLanguage),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

          const Gap(12),
          Text(
            AppLocalization.get('setup_success_desc', appLanguage),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
              height: 1.5,
            ),
          ).animate().fadeIn(duration: 450.ms, delay: 200.ms),

          const Gap(48),

          SizedBox(
            width: double.infinity,
            child:
                ElevatedButton(
                      onPressed: () {
                        // Navigate to main home view
                        context.go('/home');
                      },
                      child: Text(AppLocalization.get('enter_hadith_library', appLanguage)),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .custom(
                      duration: 1.5.seconds,
                      builder: (context, value, child) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryMint.withValues(
                                alpha: 0.15 + (value * 0.15),
                              ),
                              blurRadius: 10 + (value * 12),
                              spreadRadius: value * 3,
                            ),
                          ],
                        ),
                        child: child,
                      ),
                    ),
          ).animate().fadeIn(duration: 400.ms, delay: 350.ms),
        ],
      ),
    );
  }
}
