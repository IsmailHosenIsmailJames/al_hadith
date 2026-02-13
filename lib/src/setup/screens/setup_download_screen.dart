import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../bloc/setup_bloc.dart';
import '../service/download_service.dart';
import '../service/file_service.dart';
import '../../apis/base_api.dart';

class SetupDownloadScreen extends StatefulWidget {
  const SetupDownloadScreen({super.key});

  @override
  State<SetupDownloadScreen> createState() => _SetupDownloadScreenState();
}

class _SetupDownloadScreenState extends State<SetupDownloadScreen> {
  final DownloadService _downloadService = DownloadService();
  final FileService _fileService = FileService();
  final CancelToken _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDownloadSequence();
    });
  }

  @override
  void dispose() {
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel();
    }
    super.dispose();
  }

  Future<void> _startDownloadSequence() async {
    final bloc = context.read<SetupBloc>();
    final resources = bloc.state.selectedResources;
    final dbDir = await _fileService.getDatabaseDir();

    try {
      for (int i = 0; i < resources.length; i++) {
        if (_cancelToken.isCancelled) return;

        final res = resources[i];
        final url = '$baseApi/${res.zipPath}';
        final savePath = '$dbDir/${res.book}.sqlite.zip';

        bloc.add(
          UpdateDownloadProgress(
            progress: 0.0,
            currentFile: res.name ?? 'Resource',
            totalFiles: resources.length,
            downloadedFiles: i,
          ),
        );

        await _downloadService.downloadFile(
          url: url,
          savePath: savePath,
          cancelToken: _cancelToken,
          onProgress: (p) {
            bloc.add(
              UpdateDownloadProgress(
                progress: p,
                currentFile: res.name ?? 'Resource',
                totalFiles: resources.length,
                downloadedFiles: i,
              ),
            );
          },
        );

        // Extract after each download
        await _fileService.extractZip(savePath, dbDir);
      }

      bloc.add(DownloadFinished());
      if (mounted) {
        // Navigate to blank home screen
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (e is! DioException || !CancelToken.isCancel(e)) {
        bloc.add(DownloadError(e.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: BlocBuilder<SetupBloc, SetupState>(
                builder: (context, state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GlassCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.status == SetupStatus.finished
                                  ? 'All Set!'
                                  : 'Downloading Resources',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.status == SetupStatus.finished
                                  ? 'Your Hadith collection is ready.'
                                  : 'Please wait while we prepare your collections.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 48),
                            _ProgressIndicator(
                              progress: state.downloadProgress,
                              label:
                                  state.currentDownloadingFile ?? 'Starting...',
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Files: ${state.downloadedFilesCount + 1}/${state.totalFilesToDownload}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                                Text(
                                  '${(state.downloadProgress * 100).toInt()}%',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      if (state.status != SetupStatus.finished)
                        TextButton(
                          onPressed: () {
                            _cancelToken.cancel();
                            context.read<SetupBloc>().add(CancelDownload());
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel and rethink',
                            style: GoogleFonts.inter(
                              color: Colors.red.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final double progress;
  final String label;

  const _ProgressIndicator({required this.progress, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
