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

    try {
      final resourceRepo = RepositoryProvider.of<ResourceRepository>(context);
      final downloadService = RepositoryProvider.of<DownloadService>(context);

      final languages = await resourceRepo.getLanguagesAndResources(forceRemote: true);
      
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
          _errorMessage = 'Failed to load resources: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _startDownload(HadithResource resource) async {
    final downloadService = RepositoryProvider.of<DownloadService>(context);
    final prefs = RepositoryProvider.of<PreferencesService>(context);

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
              'Successfully downloaded ${resource.name}!',
              style: const TextStyle(color: AppTheme.darkCanvas, fontWeight: FontWeight.bold),
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
              'Download failed: ${e.toString()}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteResource(HadithResource resource) async {
    final downloadService = RepositoryProvider.of<DownloadService>(context);
    final prefs = RepositoryProvider.of<PreferencesService>(context);

    // Confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Delete Book', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete ${resource.name}? This will remove the offline database file from your device.',
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
            content: Text('Successfully deleted ${resource.name} offline files.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Deletion failed: ${e.toString()}'),
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
        final matchesQuery = res.name.toLowerCase().contains(query) ||
            res.book.toLowerCase().contains(query) ||
            lang.displayName.toLowerCase().contains(query);

        if (matchesQuery) {
          list.add(res);
        }
      }
    }
    return list;
  }

  String _getLanguageName(String code) {
    if (code == 'ara') return 'Arabic';
    if (code == 'ben') return 'Bengali';
    if (code == 'eng') return 'English';
    if (code == 'urd') return 'Urdu';
    return code.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final downloadedList = _getFilteredResources(downloadedOnly: true);
    final allList = _getFilteredResources(downloadedOnly: false);

    return Scaffold(
      backgroundColor: AppTheme.darkCanvas,
      appBar: AppBar(
        backgroundColor: AppTheme.darkSurface,
        elevation: 0,
        title: const Text(
          'Manage Resources',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryMint),
            onPressed: _loadMetadata,
          ),
          const Gap(8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryMint,
          labelColor: AppTheme.primaryMint,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: [
            Tab(text: 'Downloaded (${downloadedList.length})'),
            Tab(text: 'All Books (${allList.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryMint))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                        const Gap(16),
                        Text(_errorMessage!, style: const TextStyle(color: AppTheme.textSecondary), textAlign: TextAlign.center),
                        const Gap(16),
                        ElevatedButton(
                          onPressed: _loadMetadata,
                          child: const Text('Retry'),
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
                                color: AppTheme.darkSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF1E293B)),
                              ),
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Search books...',
                                  hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                  prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary, size: 18),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 14),
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
                              color: AppTheme.darkSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF1E293B)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedLangFilter,
                                dropdownColor: AppTheme.darkSurface,
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                                icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryMint, size: 18),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedLangFilter = value;
                                    });
                                  }
                                },
                                items: [
                                  const DropdownMenuItem(value: 'All', child: Text('All Languages')),
                                  ..._languages.map(
                                    (lang) => DropdownMenuItem(
                                      value: lang.code,
                                      child: Text(_getLanguageName(lang.code)),
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

  Widget _buildBookList(List<HadithResource> books, {required bool downloadedOnly}) {
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              downloadedOnly ? Icons.cloud_off_rounded : Icons.find_in_page_rounded,
              color: AppTheme.textSecondary.withValues(alpha: 0.4),
              size: 48,
            ),
            const Gap(14),
            Text(
              downloadedOnly ? 'No downloaded books found' : 'No books match search query',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDownloading
              ? AppTheme.primaryMint.withValues(alpha: 0.4)
              : const Color(0xFF1E293B),
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
                  color: isCompleted
                      ? AppTheme.primaryMint.withValues(alpha: 0.1)
                      : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: isCompleted ? AppTheme.primaryMint : AppTheme.textSecondary,
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
                      resource.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getLanguageName(resource.languageCode),
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
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
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
                      icon: const Icon(Icons.cloud_download_outlined, color: AppTheme.textSecondary, size: 20),
                      tooltip: 'Re-download / Update',
                      onPressed: () => _startDownload(resource),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      tooltip: 'Delete offline file',
                      onPressed: () => _deleteResource(resource),
                    ),
                  ],
                )
              else
                IconButton(
                  icon: const Icon(Icons.download_for_offline_rounded, color: AppTheme.primaryMint, size: 26),
                  tooltip: 'Download now',
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
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(color: AppTheme.primaryMint, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Gap(6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFF1E293B),
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
