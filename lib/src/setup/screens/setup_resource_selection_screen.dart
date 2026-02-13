import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/setup_bloc.dart';
import '../models/hadith_info.dart';
import 'setup_download_screen.dart';

class SetupResourceSelectionScreen extends StatelessWidget {
  const SetupResourceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SetupResourceSelectionView();
  }
}

class _SetupResourceSelectionView extends StatelessWidget {
  const _SetupResourceSelectionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Resources',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<SetupBloc, SetupState>(
              builder: (context, state) {
                final resources =
                    state.allHadithInfo[state.selectedLanguage] ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: resources.length,
                  itemBuilder: (context, index) {
                    final res = resources[index];
                    final isSelected = state.selectedResources.any(
                      (r) => r.book == res.book,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ResourceCard(
                        resource: res,
                        isSelected: isSelected,
                        onTap: () {
                          context.read<SetupBloc>().add(
                            ToggleResourceSelection(res),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _BottomSummarySection(),
        ],
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final HadithInfo resource;
  final bool isSelected;
  final VoidCallback onTap;

  const _ResourceCard({
    required this.resource,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.name ?? 'Unknown Collection',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${resource.hadithCount} Hadiths • ${(resource.zipSize! / (1024 * 1024)).toStringAsFixed(1)} MB',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: isSelected,
              onChanged: (_) => onTap(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSummarySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupBloc, SetupState>(
      builder: (context, state) {
        if (state.selectedResources.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SummaryItem(
                      label: 'Download Size',
                      value:
                          '${state.totalDownloadSizeMB.toStringAsFixed(1)} MB',
                    ),
                    _SummaryItem(
                      label: 'Required Storage',
                      value:
                          '${state.totalRequiredStorageMB.toStringAsFixed(1)} MB',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<SetupBloc>().add(StartDownload());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<SetupBloc>(),
                            child: const SetupDownloadScreen(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Download Resources',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
