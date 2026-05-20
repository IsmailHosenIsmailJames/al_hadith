import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/logic/setup/setup_state.dart';

class DownloadStep extends StatelessWidget {
  final SetupState state;

  const DownloadStep({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final targetResources = state.languages
        .expand((lang) => lang.resources)
        .where((r) => state.selectedResources.contains(r.book))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Gap(16),
        // Premium Circular Overall Progress
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.darkSurface,
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
                backgroundColor: const Color(0xFF1E293B),
                color: AppTheme.primaryMint,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(state.overallProgress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Text(
                  'Complete',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        
        const Gap(24),
        const Text(
          'Downloading Library',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const Gap(8),
        const Text(
          'Setting up offline SQLite databases and Full-Text Search. Please do not close the app.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            height: 1.4,
          ),
        ),
        const Gap(28),
        
        // Progress List
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: ListView.builder(
              itemCount: targetResources.length,
              itemBuilder: (context, index) {
                final res = targetResources[index];
                final progress = state.downloadProgress[res.book] ?? 0.0;
                final status = state.downloadStatus[res.book] ?? 'Pending';
                
                final isCompleted = status.contains('Completed');
                final isDownloading = status == 'Downloading...' || status == 'Extracting...';
                final isError = status == 'Error';

                Color statusColor = AppTheme.textSecondary;
                Widget statusIcon = const Icon(Icons.circle_outlined, color: Color(0xFF334155), size: 20);

                if (isCompleted) {
                  statusColor = AppTheme.primaryMint;
                  statusIcon = const Icon(Icons.check_circle, color: AppTheme.primaryMint, size: 22);
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
                  statusIcon = const Icon(Icons.error, color: Colors.redAccent, size: 22);
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
                                  child: Text(
                                    res.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppTheme.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  status,
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
                                  backgroundColor: const Color(0xFF1E293B),
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
        ),
      ],
    );
  }
}
