import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/data/models/resource_model.dart';
import 'package:al_hadith/data/repositories/resource_repository.dart';
import 'package:al_hadith/data/services/download_service.dart';
import 'package:al_hadith/data/services/preferences_service.dart';
import 'package:al_hadith/logic/hadiths/hadith_cubit.dart';
import 'package:al_hadith/core/localization/app_localization.dart';
import 'package:al_hadith/logic/settings/settings_cubit.dart';

class ManageResourcesScreen extends StatefulWidget {
  const ManageResourcesScreen({super.key});

  @override
  State<ManageResourcesScreen> createState() => _ManageResourcesScreenState();
}

class _ManageResourcesScreenState extends State<ManageResourcesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<HadithLanguage> _languages = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Track download states dynamically per book key
  final Map<String, double> _downloadProgress = {};
  final Map<String, String> _downloadStatus = {};
  final Map<String, bool> _isDownloading = {};

  String _searchQuery = '';
  String _selectedLangFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMetadata();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMetadata() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final appLanguage = context.read<SettingsCubit>().state.appLanguage;

    try {
      final resourceRepo = RepositoryProvider.of<ResourceRepository>(context);
      final downloadService = RepositoryProvider.of<DownloadService>(context);

      final languages = await resourceRepo.getLanguagesAndResources(
        forceRemote: true,
      );

      // Cache current download statuses
      for (final lang in languages) {
        for (final res in lang.resources) {
          final isDownloaded = await downloadService.isDatabaseDownloaded(res);
          _downloadStatus[res.book] = isDownloaded ? 'Completed' : 'Available';
          _downloadProgress[res.book] = isDownloaded ? 1.0 : 0.0;
        }
      }

      if (mounted) {
        setState(() {
          _languages = languages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppLocalization.get('load_failed', appLanguage, args: {'error': e.toString()});
        });
      }
    }
  }

  Future<void> _startDownload(HadithResource resource) async {
    final downloadService = RepositoryProvider.of<DownloadService>(context);
    final prefs = RepositoryProvider.of<PreferencesService>(context);
    final appLanguage = context.read<SettingsCubit>().state.appLanguage;

    setState(() {
      _isDownloading[resource.book] = true;
      _downloadStatus[resource.book] = 'Starting...';
      _downloadProgress[resource.book] = 0.0;
    });

    try {
      await downloadService.downloadAndExtract(
        resource: resource,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _downloadProgress[resource.book] = progress;
            });
          }
        },
        onStatusChange: (status) {
          if (mounted) {
            setState(() {
              _downloadStatus[resource.book] = status;
            });
          }
        },
      );

      // Save selected resources dynamically to registry
      final selectedList = prefs.getDownloadedResources();
      await prefs.setSelectedResources(selectedList);

      if (mounted) {
        setState(() {
          _isDownloading[resource.book] = false;
          _downloadStatus[resource.book] = 'Completed';
          _downloadProgress[resource.book] = 1.0;
        });

        // Trigger dashboard reload dynamically
        context.read<HadithCubit>().loadDashboard();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.primaryMint,
            content: Text(
              AppLocalization.get('download_success', appLanguage, args: {'name': resource.name}),
              style: const TextStyle(
                color: AppTheme.darkCanvas,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading[resource.book] = false;
          _downloadStatus[resource.book] = 'Error';
          _downloadProgress[resource.book] = 0.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              AppLocalization.get('download_failed', appLanguage, args: {'error': e.toString()}),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteResource(HadithResource resource) async {
    final downloadService = RepositoryProvider.of<DownloadService>(context);
    final prefs = RepositoryProvider.of<PreferencesService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final dialogBg = isDark ? AppTheme.darkSurface : Colors.white;
    final appLanguage = context.read<SettingsCubit>().state.appLanguage;

    // Confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        title: Text(
          AppLocalization.get('delete_book', appLanguage),
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppLocalization.get('delete_book_desc', appLanguage, args: {'name': resource.name}),
          style: TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              AppLocalization.get('cancel', appLanguage),
              style: TextStyle(color: textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalization.get('delete', appLanguage), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await downloadService.deleteDatabase(resource.book);

      // Reload selections
      final selectedList = prefs.getDownloadedResources();
      await prefs.setSelectedResources(selectedList);

      if (mounted) {
        setState(() {
          _downloadStatus[resource.book] = 'Available';
          _downloadProgress[resource.book] = 0.0;
        });

        // Trigger dashboard reload dynamically
        context.read<HadithCubit>().loadDashboard();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.primaryMint,
            content: Text(
              AppLocalization.get('delete_success', appLanguage, args: {'name': resource.name}),
              style: const TextStyle(
                color: AppTheme.darkCanvas,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              AppLocalization.get('delete_failed', appLanguage, args: {'error': e.toString()}),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    }
  }

  List<HadithResource> _getFilteredResources({required bool downloadedOnly}) {
    final List<HadithResource> list = [];
    for (final lang in _languages) {
      if (_selectedLangFilter != 'All' && lang.code != _selectedLangFilter) {
        continue;
      }
      for (final res in lang.resources) {
        final isDownloaded = _downloadStatus[res.book] == 'Completed';
        if (downloadedOnly && !isDownloaded) {
          continue;
        }

        // Apply search filter
        final query = _searchQuery.toLowerCase();
        final matchesQuery =
            res.name.toLowerCase().contains(query) ||
            res.book.toLowerCase().contains(query) ||
            res.book.toLowerCase().contains(query) ||
            lang.displayName.toLowerCase().contains(query) ||
            lang.nativeName.toLowerCase().contains(query);

        if (matchesQuery) {
          list.add(res);
        }
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;
    final downloadedList = _getFilteredResources(downloadedOnly: true);
    final allList = _getFilteredResources(downloadedOnly: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvasColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final borderDividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final inputBgColor = isDark ? AppTheme.darkSurface : const Color(0xFFF3F4F6);
    final dropdownBgColor = isDark ? AppTheme.darkSurface : Colors.white;

    return Scaffold(
      backgroundColor: canvasColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        title: Text(
          AppLocalization.getTabName('manage_resources', appLanguage),
          style: TextStyle(
            color: textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.primaryMint,
            ),
            onPressed: _loadMetadata,
          ),
          const Gap(8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryMint,
          labelColor: AppTheme.primaryMint,
          unselectedLabelColor: textSecondary,
          tabs: [
            Tab(text: AppLocalization.get('downloaded_tab_title', appLanguage, args: {'count': '${downloadedList.length}'})),
            Tab(text: AppLocalization.get('all_books_tab_title', appLanguage, args: {'count': '${allList.length}'})),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryMint),
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 48,
                    ),
                    const Gap(16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(16),
                    ElevatedButton(
                      onPressed: _loadMetadata,
                      child: Text(AppLocalization.get('retry_setup_download', appLanguage)),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Search & Language filter row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: inputBgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderDividerColor),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                            ),
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: AppLocalization.get('search_books_hint', appLanguage),
                              hintStyle: TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: textSecondary,
                                size: 18,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Gap(12),
                      // Language selector pill
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: inputBgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderDividerColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLangFilter,
                            dropdownColor: dropdownBgColor,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppTheme.primaryMint,
                              size: 18,
                            ),
                            onChanged: (value) {
                              if (value != null) {
                                  setState(() {
                                    _selectedLangFilter = value;
                                  });
                                }
                              },
                              items: [
                                DropdownMenuItem(
                                  value: 'All',
                                  child: Text(AppLocalization.get('all_languages', appLanguage), style: TextStyle(color: textPrimary)),
                                ),
                              ..._languages.map(
                                (lang) => DropdownMenuItem(
                                  value: lang.code,
                                  child: Text(
                                    lang.code == "eng"
                                        ? lang.displayName
                                        : "${lang.nativeName} (${lang.displayName})",
                                    style: TextStyle(color: textPrimary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBookList(downloadedList, downloadedOnly: true),
                      _buildBookList(allList, downloadedOnly: false),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBookList(
    List<HadithResource> books, {
    required bool downloadedOnly,
  }) {
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final appLanguage = context.read<SettingsCubit>().state.appLanguage;

    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              downloadedOnly
                  ? Icons.cloud_off_rounded
                  : Icons.find_in_page_rounded,
              color: textSecondary.withValues(alpha: 0.4),
              size: 48,
            ),
            const Gap(14),
            Text(
              downloadedOnly
                  ? AppLocalization.get('no_downloaded_books', appLanguage)
                  : AppLocalization.get('no_books_match', appLanguage),
              style: TextStyle(
                color: textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: books.length,
      itemBuilder: (context, idx) {
        final book = books[idx];
        return _buildBookCard(book)
            .animate()
            .fadeIn(duration: 250.ms, delay: (idx * 30).ms)
            .slideY(begin: 0.05, end: 0);
      },
    );
  }

  Widget _buildBookCard(HadithResource resource) {
    final status = _downloadStatus[resource.book] ?? 'Available';
    final progress = _downloadProgress[resource.book] ?? 0.0;
    final isDownloading = _isDownloading[resource.book] ?? false;
    final isCompleted = status == 'Completed';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final borderDividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final cardBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final badgeBgColor = isCompleted
        ? AppTheme.primaryMint.withValues(alpha: 0.1)
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB));
    final pillBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6);
    final appLanguage = context.read<SettingsCubit>().state.appLanguage;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDownloading
              ? AppTheme.primaryMint.withValues(alpha: 0.4)
              : borderDividerColor,
          width: isDownloading ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Badge
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: isCompleted
                        ? AppTheme.primaryMint
                        : textSecondary,
                    size: 20,
                  ),
                ),
              ),
              const Gap(12),
              // Metadata details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.nameNative,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(2),
                    if (resource.languageCode != "eng")
                      Text(
                        resource.name,
                        style: TextStyle(
                          fontSize: 10,
                          color: textSecondary,
                        ),
                      ),
                    const Gap(4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: pillBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            resource.languageCode == "eng"
                                ? resource.langDisplayName
                                : "${resource.langNativeName} (${resource.langDisplayName})",
                            style: const TextStyle(
                              color: AppTheme.primaryMint,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Gap(8),
                        Text(
                          resource.formattedZipSize,
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action Buttons
              if (isDownloading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryMint,
                    strokeWidth: 2.5,
                  ),
                )
              else if (isCompleted)
                Row(
                  children: [
                    // Update / Refresh action
                    IconButton(
                      icon: Icon(
                        Icons.cloud_download_outlined,
                        color: textSecondary,
                        size: 20,
                      ),
                      tooltip: AppLocalization.get('retry_setup_download', appLanguage),
                      onPressed: () => _startDownload(resource),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      tooltip: AppLocalization.get('delete', appLanguage),
                      onPressed: () => _deleteResource(resource),
                    ),
                  ],
                )
              else
                IconButton(
                  icon: const Icon(
                    Icons.download_for_offline_rounded,
                    color: AppTheme.primaryMint,
                    size: 26,
                  ),
                  tooltip: AppLocalization.get('install', appLanguage),
                  onPressed: () => _startDownload(resource),
                ),
            ],
          ),
          if (isDownloading) ...[
            const Gap(14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: AppTheme.primaryMint,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Gap(6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: pillBgColor,
                color: AppTheme.primaryMint,
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
