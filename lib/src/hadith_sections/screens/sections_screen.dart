import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/sections_cubit.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class SectionsScreen extends StatefulWidget {
  static const String routeName = '/sections/:bookId';
  final String bookId;
  final String bookName;

  const SectionsScreen({
    super.key,
    required this.bookId,
    required this.bookName,
  });

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SectionsCubit>().loadSections(widget.bookId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookName),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search section...',
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(
                cs.surfaceContainerHighest,
              ),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 16),
              ),
              leading: const Icon(Icons.search_rounded),
              onChanged: (value) =>
                  context.read<SectionsCubit>().filterSections(value),
              onTap: () {
                // Focus the search bar
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<SectionsCubit, SectionsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          if (state.filteredSections.isEmpty) {
            return _buildEmptyState(theme, cs);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.filteredSections.length,
            itemBuilder: (context, index) {
              final section = state.filteredSections[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    section.sectionName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Hadith: ${section.startHadithNumber} - ${section.endHadithNumber} • Total: ${section.hadithCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  onTap: () {
                    context.push(
                      '/hadiths/${widget.bookId}/${section.id}?name=${Uri.encodeComponent(section.sectionName)}',
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: cs.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const Gap(16),
          Text(
            'No sections found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
