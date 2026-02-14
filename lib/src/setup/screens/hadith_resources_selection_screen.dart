import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/setup_cubit.dart';
import '../models/hadith_info_model.dart';
import 'hadith_resource_download_screen.dart';

class HadithResourcesSelectionScreen extends StatelessWidget {
  static const String routeName = '/hadith_resources_selection';
  const HadithResourcesSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocBuilder<SetupCubit, SetupState>(
      builder: (context, state) {
        final langCodes = state.allResources.keys.toList()..sort();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Select Hadith Resources'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: Column(
            children: [
              // Resource list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 100,
                    left: 8,
                    right: 8,
                  ),
                  itemCount: langCodes.length,
                  itemBuilder: (context, index) {
                    final langCode = langCodes[index];
                    final langInfo = LanguageInfo.fromCode3(langCode);
                    final resources = state.allResources[langCode]!;
                    final selectedCount = state.selectedCountForLanguage(
                      langCode,
                    );
                    final allSelected = selectedCount == resources.length;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: selectedCount > 0
                                ? cs.primary.withValues(alpha: 0.4)
                                : cs.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Theme(
                          data: theme.copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            initiallyExpanded:
                                langCode == state.selectedAppLanguage,
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: Text(
                              langInfo.flag,
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(
                              langInfo.nativeName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  langInfo.englishName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (selectedCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$selectedCount selected',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: cs.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            children: [
                              // Select/Deselect all
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Row(
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        if (allSelected) {
                                          context
                                              .read<SetupCubit>()
                                              .deselectAllForLanguage(langCode);
                                        } else {
                                          context
                                              .read<SetupCubit>()
                                              .selectAllForLanguage(langCode);
                                        }
                                      },
                                      icon: Icon(
                                        allSelected
                                            ? Icons.deselect_rounded
                                            : Icons.select_all_rounded,
                                        size: 18,
                                      ),
                                      label: Text(
                                        allSelected
                                            ? 'Deselect All'
                                            : 'Select All',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Resource items
                              ...resources.map((r) {
                                final isChecked = state.selectedBooks.contains(
                                  r.book,
                                );
                                return CheckboxListTile(
                                  value: isChecked,
                                  onChanged: (_) => context
                                      .read<SetupCubit>()
                                      .toggleResource(r.book),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  title: Text(
                                    r.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${r.hadithCount} hadith  •  ${r.sectionCount} sections  •  ${_formatBytes(r.zipSize)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: cs.onSurface.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Bottom bar with size summary & confirm button
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.dividerColor)),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Size info row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SizeChip(
                      icon: Icons.cloud_download_outlined,
                      label: 'Download',
                      value: _formatBytes(state.totalDownloadSize),
                      color: cs.primary,
                    ),
                    _SizeChip(
                      icon: Icons.storage_outlined,
                      label: 'Storage',
                      value: _formatBytes(state.totalStorageSize),
                      color: cs.secondary,
                    ),
                    _SizeChip(
                      icon: Icons.library_books_outlined,
                      label: 'Books',
                      value: '${state.selectedBooks.length}',
                      color: cs.tertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Confirm button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: state.selectedBooks.isEmpty
                        ? null
                        : () {
                            context.go(HadithResourceDownloadScreen.routeName);
                          },
                    icon: const Icon(Icons.download_rounded, size: 20),
                    label: const Text(
                      'Confirm & Download',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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
          ),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────────────────

class _SizeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SizeChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
