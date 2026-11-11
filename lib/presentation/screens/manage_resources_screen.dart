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
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
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
          _errorMessage = AppLocalization.get(
            'load_failed',
            appLanguage,
            args: {'error': e.toString()},
          );
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
              AppLocalization.get(
                'download_success',
                appLanguage,
                args: {'name': resource.name},
              ),
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
              AppLocalization.get(
                'download_failed',
                appLanguage,
                args: {'error': e.toString()},
              ),
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
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final dialogBg = isDark ? AppTheme.darkSurface : Colors.white;
    final appLanguage = context.read<SettingsCubit>().state.appLanguage;

    // Confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        title: Text(
          AppLocalization.get('delete_book', appLanguage),
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocalization.get(
            'delete_book_desc',
            appLanguage,
            args: {'name': resource.name},
          ),
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
            child: Text(
              AppLocalization.get('delete', appLanguage),
              style: const TextStyle(color: Colors.white),
            ),
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
              AppLocalization.get(
                'delete_success',
                appLanguage,
                args: {'name': resource.name},
              ),
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
              AppLocalization.get(
                'delete_failed',
                appLanguage,
                args: {'error': e.toString()},
              ),
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
    list.sort((a, b) {
      final rankA = HadithCubit.getBookPopularityRank(a.book);
      final rankB = HadithCubit.getBookPopularityRank(b.book);
      if (rankA != rankB) return rankA.compareTo(rankB);
      return b.hadithCount.compareTo(a.hadithCount);
    });
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
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final inputBgColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF1F5F9);

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
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.primaryMint,
              size: 22,
            ),
            tooltip: 'Refresh Metadata',
            onPressed: _loadMetadata,
          ),
          const Gap(4),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppTheme.wideWidth),
          child: _isLoading
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
                          child: Text(
                            AppLocalization.get(
                              'retry_setup_download',
                              appLanguage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Storage Overview Pulse Banner
                    _buildStorageOverviewCard(
                      downloadedList: downloadedList,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderDividerColor: borderDividerColor,
                    ),

                    // Segmented Capsule Tab Selector
                    _buildSegmentedTabSelector(
                      downloadedCount: downloadedList.length,
                      allCount: allList.length,
                      isDark: isDark,
                      borderDividerColor: borderDividerColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),

                    // Compact Search Bar (40px)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: inputBgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderDividerColor),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 13.5,
                          ),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: AppLocalization.get(
                              'search_books_hint',
                              appLanguage,
                            ),
                            hintStyle: TextStyle(
                              color: textSecondary,
                              fontSize: 12.5,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: textSecondary,
                              size: 17,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                    ),
                                    color: textSecondary,
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Horizontal Language Filter Chips
                    _buildLanguageChips(
                      isDark: isDark,
                      borderDividerColor: borderDividerColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const Gap(6),

                    // Tab View for Downloaded vs All Books
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
        ),
      ),
    );
  }

  Widget _buildStorageOverviewCard({
    required List<HadithResource> downloadedList,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderDividerColor,
  }) {
    final totalBytes = downloadedList.fold<int>(
      0,
      (sum, res) => sum + (res.fileSize > 0 ? res.fileSize : res.zipSize),
    );
    final totalMb = (totalBytes / (1024 * 1024)).toStringAsFixed(1);
    final totalHadiths = downloadedList.fold<int>(
      0,
      (sum, res) => sum + res.hadithCount,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF0F261F),
                  const Color(0xFF14202E),
                ]
              : [
                  const Color(0xFFE6F7F0),
                  const Color(0xFFF0FDF4),
                ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF1B4D3E) : const Color(0xFFA7F3D0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primaryMint.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.storage_rounded,
                color: AppTheme.primaryMint,
                size: 20,
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${downloadedList.length} Books Installed',
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryMint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$totalMb MB Storage',
                        style: const TextStyle(
                          color: AppTheme.primaryMint,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(2.5),
                Text(
                  totalHadiths > 0
                      ? '$totalHadiths Hadiths available offline with instant search'
                      : 'Download books below to read completely offline',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabSelector({
    required int downloadedCount,
    required int allCount,
    required bool isDark,
    required Color borderDividerColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderDividerColor, width: 0.8),
      ),
      child: Row(
        children: [
          _buildSegmentTabItem(
            index: 0,
            title: 'Downloaded',
            count: downloadedCount,
            icon: Icons.check_circle_outline_rounded,
            isSelected: _tabController.index == 0,
          ),
          _buildSegmentTabItem(
            index: 1,
            title: 'All Books',
            count: allCount,
            icon: Icons.library_books_outlined,
            isSelected: _tabController.index == 1,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentTabItem({
    required int index,
    required String title,
    required int count,
    required IconData icon,
    required bool isSelected,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _tabController.animateTo(index);
          });
        },
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryMint : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryMint.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color:
                    isSelected ? AppTheme.darkCanvas : AppTheme.textSecondary,
              ),
              const Gap(6),
              Text(
                '$title ($count)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color:
                      isSelected ? AppTheme.darkCanvas : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageChips({
    required bool isDark,
    required Color borderDividerColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildLangChip(
            code: 'All',
            label: '🌐 All',
            isSelected: _selectedLangFilter == 'All',
            isDark: isDark,
            borderDividerColor: borderDividerColor,
            textPrimary: textPrimary,
          ),
          ..._languages.map((lang) {
            final isSelected = _selectedLangFilter == lang.code;
            final label =
                '${lang.flagEmoji} ${lang.code == "eng" ? lang.displayName : lang.nativeName}';
            return _buildLangChip(
              code: lang.code,
              label: label,
              isSelected: isSelected,
              isDark: isDark,
              borderDividerColor: borderDividerColor,
              textPrimary: textPrimary,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLangChip({
    required String code,
    required String label,
    required bool isSelected,
    required bool isDark,
    required Color borderDividerColor,
    required Color textPrimary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLangFilter = code;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryMint
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primaryMint : borderDividerColor,
              width: 0.9,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.darkCanvas : textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookList(
    List<HadithResource> books, {
    required bool downloadedOnly,
  }) {
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
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
              size: 44,
            ),
            const Gap(12),
            Text(
              downloadedOnly
                  ? AppLocalization.get('no_downloaded_books', appLanguage)
                  : AppLocalization.get('no_books_match', appLanguage),
              style: TextStyle(color: textSecondary, fontSize: 13.5),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: books.length,
      itemBuilder: (context, idx) {
        final book = books[idx];
        return _buildBookCard(book)
            .animate()
            .fadeIn(duration: 200.ms, delay: (idx * 20).ms)
            .slideY(begin: 0.04, end: 0);
      },
    );
  }

  Widget _buildBookCard(HadithResource resource) {
    final status = _downloadStatus[resource.book] ?? 'Available';
    final progress = _downloadProgress[resource.book] ?? 0.0;
    final isDownloading = _isDownloading[resource.book] ?? false;
    final isCompleted = status == 'Completed';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final cardBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final badgeBgColor = isCompleted
        ? AppTheme.primaryMint.withValues(alpha: 0.12)
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9));
    final pillBgColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF3F4F6);
    final appLanguage = context.read<SettingsCubit>().state.appLanguage;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isDownloading
              ? AppTheme.primaryMint.withValues(alpha: 0.5)
              : borderDividerColor,
          width: isDownloading ? 1.5 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
              child: Row(
                children: [
                  // Icon badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        color:
                            isCompleted ? AppTheme.primaryMint : textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                  const Gap(11),
                  // Metadata
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                resource.nameNative,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Gap(6),
                            // Language flag badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: pillBgColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '${resource.langFlag} ${resource.languageCode == "eng" ? "EN" : resource.langNativeName}',
                                style: TextStyle(
                                  color: isCompleted
                                      ? AppTheme.primaryMint
                                      : textSecondary,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (resource.languageCode != "eng") ...[
                          const Gap(1.5),
                          Text(
                            resource.name,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const Gap(3),
                        Row(
                          children: [
                            Text(
                              resource.formattedZipSize,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (resource.hadithCount > 0) ...[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  '•',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Text(
                                '${resource.hadithCount} Hadiths',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                            const Gap(6),
                            if (isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryMint
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '✓ Installed',
                                  style: TextStyle(
                                    color: AppTheme.primaryMint,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  // Action buttons
                  if (isDownloading)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: AppTheme.primaryMint,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(6),
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryMint,
                            strokeWidth: 2,
                          ),
                        ),
                      ],
                    )
                  else if (isCompleted)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Redownload / Refresh button
                        InkWell(
                          onTap: () => _startDownload(resource),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.sync_rounded,
                              color: textSecondary,
                              size: 18,
                            ),
                          ),
                        ),
                        const Gap(2),
                        // Delete button
                        InkWell(
                          onTap: () => _deleteResource(resource),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    InkWell(
                      onTap: () => _startDownload(resource),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryMint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.download_rounded,
                              color: AppTheme.darkCanvas,
                              size: 14,
                            ),
                            const Gap(4),
                            Text(
                              AppLocalization.get('install', appLanguage),
                              style: const TextStyle(
                                color: AppTheme.darkCanvas,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isDownloading)
              LinearProgressIndicator(
                value: progress,
                backgroundColor: pillBgColor,
                color: AppTheme.primaryMint,
                minHeight: 2.5,
              ),
          ],
        ),
      ),
    );
  }
}
