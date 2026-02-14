import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/hadith_list_cubit.dart';
import '../../core/database/hadith_dao.dart';
import 'package:gap/gap.dart';

class HadithListScreen extends StatefulWidget {
  static const String routeName = '/hadiths/:bookId/:sectionId';
  final String bookId;
  final int sectionId;
  final String sectionName;

  const HadithListScreen({
    super.key,
    required this.bookId,
    required this.sectionId,
    required this.sectionName,
  });

  @override
  State<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends State<HadithListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<HadithListCubit>().loadHadiths(
      widget.bookId,
      widget.sectionId,
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<HadithListCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.sectionName)),
      body: BlocBuilder<HadithListCubit, HadithListState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          if (state.hadiths.isEmpty) {
            return const Center(
              child: Text('No Hadiths found in this section.'),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: state.hadiths.length + (state.hasReachedMax ? 0 : 1),
            itemBuilder: (context, index) {
              if (index >= state.hadiths.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final item = state.hadiths[index];
              return _HadithCard(item: item);
            },
          );
        },
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  final HadithWithGrades item;

  const _HadithCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with number
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'HADITH #${item.hadith.hadithNumber}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Hadith Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              item.hadith.hadithText,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                letterSpacing: 0.2,
                fontSize: 15,
              ),
            ),
          ),

          const Gap(20),

          // Grades section
          if (item.grades.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    child: Text(
                      'GRADES',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: item.grades
                          .map(
                            (g) => _GradeChip(
                              grade: g.grade,
                              scholarName: g.scholarName,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GradeChip extends StatelessWidget {
  final String grade;
  final String scholarName;

  const _GradeChip({required this.grade, required this.scholarName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Simple color logic based on grade
    Color gradeColor = cs.primary;
    if (grade.toLowerCase().contains('sahih')) gradeColor = Colors.green;
    if (grade.toLowerCase().contains('daif')) gradeColor = Colors.red;
    if (grade.toLowerCase().contains('hasan')) gradeColor = Colors.orange;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            grade,
            style: theme.textTheme.labelLarge?.copyWith(
              color: gradeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            scholarName,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
