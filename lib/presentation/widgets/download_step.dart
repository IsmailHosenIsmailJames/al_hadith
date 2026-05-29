import 'package:al_hadith/data/models/resource_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/core/localization/app_localization.dart';
import 'package:al_hadith/logic/setup/setup_state.dart';
import 'package:al_hadith/logic/settings/settings_cubit.dart';

class DownloadStep extends StatelessWidget {
  final SetupState state;

  const DownloadStep({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;
    final targetResources = state.languages
        .expand((lang) => lang.resources)
        .where((r) => state.selectedResources.contains(r.book))
        .toList();
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    bool isWideWindow = MediaQuery.of(context).size.width > AppTheme.wideWidth;

    return isWideWindow
        ? Row(
            children: [
              SizedBox(
                width: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    OverallProgress(state: state).animate().scale(
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),
                    const Gap(12),
                    Text(
                      AppLocalization.get('downloading_library', appLanguage),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      AppLocalization.get('download_desc', appLanguage),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Gap(10),

              IndividualResourcesAndProgress(
                targetResources: targetResources,
                state: state,
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(16),
              // Premium Circular Overall Progress
              OverallProgress(
                state: state,
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

              const Gap(24),
              Text(
                AppLocalization.get('downloading_library', appLanguage),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const Gap(8),
              Text(
                AppLocalization.get('download_desc', appLanguage),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                  height: 1.4,
                ),
              ),
              const Gap(28),

              // Progress List
              IndividualResourcesAndProgress(
                targetResources: targetResources,
                state: state,
              ),
            ],
          );
  }
}

class IndividualResourcesAndProgress extends StatelessWidget {
  const IndividualResourcesAndProgress({
    super.key,
    required this.targetResources,
    required this.state,
  });

  final List<HadithResource> targetResources;
  final SetupState state;

  @override
  Widget build(BuildContext context) {
    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final cardBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final inactiveCircleColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: ListView.builder(
          itemCount: targetResources.length,
          itemBuilder: (context, index) {
            final res = targetResources[index];
            final progress = state.downloadProgress[res.book] ?? 0.0;
            final status = state.downloadStatus[res.book] ?? 'Pending';

            final isCompleted = status.contains('Completed');
            final isDownloading =
                status == 'Downloading...' || status == 'Extracting...';
            final isError = status == 'Error';

            Color statusColor = textSecondary;
            Widget statusIcon = Icon(
              Icons.circle_outlined,
              color: inactiveCircleColor,
              size: 20,
            );

            if (isCompleted) {
              statusColor = AppTheme.primaryMint;
              statusIcon = const Icon(
                Icons.check_circle,
                color: AppTheme.primaryMint,
                size: 22,
              );
            } else if (isDownloading) {
              statusColor = AppTheme.secondaryIndigo;
              statusIcon = const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.secondaryIndigo,
                ),
              );
            } else if (isError) {
              statusColor = Colors.redAccent;
              statusIcon = const Icon(
                Icons.error,
                color: Colors.redAccent,
                size: 22,
              );
            }

            String localizedStatus = status;
            if (status == 'Pending') {
              localizedStatus = AppLocalization.get('pending', appLanguage);
            } else if (status == 'Downloading...') {
              localizedStatus = AppLocalization.get('downloading', appLanguage);
            } else if (status == 'Extracting...') {
              localizedStatus = AppLocalization.get('extracting', appLanguage);
            } else if (status == 'Completed') {
              localizedStatus = AppLocalization.get('completed', appLanguage);
            } else if (status == 'Completed (Skipped)') {
              localizedStatus = AppLocalization.get('completed_skipped', appLanguage);
            } else if (status == 'Error') {
              localizedStatus = AppLocalization.get('error', appLanguage);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  statusIcon,
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    res.nameNative,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Gap(2),
                                  Text(
                                    res.name,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              localizedStatus,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (isDownloading) ...[
                          const Gap(6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 4,
                              backgroundColor: borderColor,
                              color: AppTheme.secondaryIndigo,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class OverallProgress extends StatelessWidget {
  const OverallProgress({super.key, required this.state});

  final SetupState state;

  @override
  Widget build(BuildContext context) {
    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final circleBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final barBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleBgColor,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryMint.withValues(alpha: 0.05),
                blurRadius: 24,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 130,
          height: 130,
          child: CircularProgressIndicator(
            value: state.overallProgress,
            strokeWidth: 8,
            backgroundColor: barBgColor,
            color: AppTheme.primaryMint,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(state.overallProgress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            Text(
              AppLocalization.get('complete', appLanguage),
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
