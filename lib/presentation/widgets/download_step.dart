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

    final isWideWindow = MediaQuery.of(context).size.width > AppTheme.wideWidth;

    if (isWideWindow) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 320,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                OverallProgress(state: state),
                const Gap(16),
                Text(
                  AppLocalization.get('downloading_library', appLanguage),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const Gap(6),
                Text(
                  AppLocalization.get('download_desc', appLanguage),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Gap(20),
          Expanded(
            child: IndividualResourcesAndProgress(
              targetResources: targetResources,
              state: state,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Gap(8),
        OverallProgress(state: state),
        const Gap(16),
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
            fontSize: 12.5,
            color: textSecondary,
            height: 1.4,
          ),
        ),
        const Gap(16),
        Expanded(
          child: IndividualResourcesAndProgress(
            targetResources: targetResources,
            state: state,
          ),
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
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: ListView.separated(
        itemCount: targetResources.length,
        separatorBuilder: (context, index) => Divider(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          height: 14,
        ),
        itemBuilder: (context, index) {
          final res = targetResources[index];
          final progress = state.downloadProgress[res.book] ?? 0.0;
          final status = state.downloadStatus[res.book] ?? 'Pending';

          final isCompleted = status.contains('Completed');
          final isDownloading =
              status == 'Downloading...' || status == 'Extracting...';
          final isError = status == 'Error';

          Color statusColor = textSecondary;
          Widget statusIcon;

          if (isCompleted) {
            statusColor = AppTheme.primaryMint;
            statusIcon = Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.primaryMint.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppTheme.primaryMint,
                size: 14,
              ),
            );
          } else if (isDownloading) {
            statusColor = AppTheme.primaryMint;
            statusIcon = const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppTheme.primaryMint,
              ),
            );
          } else if (isError) {
            statusColor = Colors.redAccent;
            statusIcon = const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 20,
            );
          } else {
            statusIcon = Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
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

          return Row(
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
                          child: Text(
                            res.nameNative,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          localizedStatus,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Gap(3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          res.formattedZipSize,
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                        if (isDownloading)
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.primaryMint,
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
                          backgroundColor: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0),
                          color: AppTheme.primaryMint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
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
    final barBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    final percentInt = (state.overallProgress * 100).toInt();

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 136,
          height: 136,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleBgColor,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryMint.withValues(alpha: 0.12),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 124,
          height: 124,
          child: CircularProgressIndicator(
            value: state.overallProgress,
            strokeWidth: 8,
            backgroundColor: barBgColor,
            color: AppTheme.primaryMint,
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$percentInt%',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const Gap(2),
            Text(
              AppLocalization.get('complete', appLanguage),
              style: TextStyle(
                fontSize: 11.5,
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }
}
