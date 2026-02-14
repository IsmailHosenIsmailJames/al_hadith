import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../home/screens/home_screen.dart';
import '../bloc/setup_cubit.dart';

class HadithResourceDownloadScreen extends StatefulWidget {
  static const String routeName = '/hadith_resource_download';
  const HadithResourceDownloadScreen({super.key});

  @override
  State<HadithResourceDownloadScreen> createState() =>
      _HadithResourceDownloadScreenState();
}

class _HadithResourceDownloadScreenState
    extends State<HadithResourceDownloadScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkAnimController;
  late Animation<double> _checkScale;
  bool _downloadStarted = false;

  @override
  void initState() {
    super.initState();
    _checkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _checkScale = CurvedAnimation(
      parent: _checkAnimController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _checkAnimController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_downloadStarted) {
      _downloadStarted = true;
      // Start download after the first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<SetupCubit>().startDownload();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<SetupCubit, SetupState>(
            listener: (context, state) {
              if (state.downloadComplete) {
                _checkAnimController.forward();
              }
            },
            builder: (context, state) {
              final items = state.downloadItems;
              final doneCount = items
                  .where((i) => i.status == DownloadItemStatus.done)
                  .length;
              final totalCount = items.length;
              final overallProgress = totalCount > 0
                  ? doneCount / totalCount
                  : 0.0;

              if (state.downloadComplete) {
                return _buildCompleteView(context, cs, theme, totalCount);
              }

              return Column(
                children: [
                  const SizedBox(height: 40),
                  // Header
                  Icon(
                    Icons.cloud_download_rounded,
                    size: 48,
                    color: cs.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Downloading Resources',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$doneCount of $totalCount completed',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Overall progress
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: overallProgress,
                            minHeight: 8,
                            backgroundColor: cs.primaryContainer.withValues(
                              alpha: 0.3,
                            ),
                            valueColor: AlwaysStoppedAnimation(cs.primary),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${(overallProgress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Per-item list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _DownloadItemTile(item: item);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteView(
    BuildContext context,
    ColorScheme cs,
    ThemeData theme,
    int totalCount,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _checkScale,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 64,
                color: cs.primary,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Setup Complete!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalCount resources ready',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => context.go(HomeScreen.routeName),
              icon: const Icon(Icons.home_rounded, size: 20),
              label: const Text(
                'Go to Home',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────

class _DownloadItemTile extends StatelessWidget {
  final DownloadItemState item;
  const _DownloadItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    IconData icon;
    Color iconColor;
    Widget? trailing;

    switch (item.status) {
      case DownloadItemStatus.pending:
        icon = Icons.hourglass_empty_rounded;
        iconColor = cs.onSurface.withValues(alpha: 0.3);
        break;
      case DownloadItemStatus.downloading:
        icon = Icons.cloud_download_rounded;
        iconColor = cs.primary;
        trailing = SizedBox(
          width: 44,
          child: Text(
            '${(item.progress * 100).toStringAsFixed(0)}%',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.primary,
            ),
          ),
        );
        break;
      case DownloadItemStatus.extracting:
        icon = Icons.unarchive_rounded;
        iconColor = Colors.orange;
        trailing = SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation(Colors.orange),
          ),
        );
        break;
      case DownloadItemStatus.done:
        icon = Icons.check_circle_rounded;
        iconColor = Colors.green;
        break;
      case DownloadItemStatus.error:
        icon = Icons.error_rounded;
        iconColor = cs.error;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: iconColor, size: 22),
        title: Text(
          item.resource.name,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          item.resource.book,
          style: TextStyle(
            fontSize: 11,
            color: cs.onSurface.withValues(alpha: 0.4),
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}
