import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../setup/models/hadith_info_model.dart';
import '../bloc/home_cubit.dart';
import '../widgets/collection_card.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadDownloadedBooks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Al Hadith',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onPrimary,
          ),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.search_rounded),
        //     tooltip: 'Search Hadiths',
        //   ),
        // ],
      ),
      // drawer: const AppDrawer(),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          if (state.downloadedBooks.isEmpty) {
            return _buildEmptyState(theme, cs);
          }

          final groupedBooks = state.booksByLanguage;
          final languages = groupedBooks.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final langCode = languages[index];
              final books = groupedBooks[langCode]!;
              final langInfo = LanguageInfo.fromCode3(langCode);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 4.0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          langInfo.flag,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const Gap(8),
                        Text(
                          langInfo.englishName.toUpperCase(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...books.map(
                    (book) => CollectionCard(
                      book: book,
                      onTap: () {
                        context.push(
                          '/sections/${book.book}?name=${Uri.encodeComponent(book.name)}',
                        );
                      },
                    ),
                  ),
                  const Gap(8),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_rounded,
              size: 80,
              color: cs.primary.withValues(alpha: 0.2),
            ),
            const Gap(16),
            Text(
              'No Books Downloaded',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              'Please go to setup and download some Hadith collections to start reading.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
