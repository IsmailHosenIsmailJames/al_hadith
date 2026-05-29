import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/data/models/resource_model.dart';
import 'package:al_hadith/logic/setup/setup_state.dart';

class LanguageStep extends StatelessWidget {
  final SetupState state;
  final Function(HadithLanguage) onSelected;

  const LanguageStep({
    super.key,
    required this.state,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.languages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryMint),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final cardBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final inactiveBorderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final tickColor = isDark ? AppTheme.darkCanvas : Colors.white;

    bool isWideWindow = MediaQuery.of(context).size.width > AppTheme.wideWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Language',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
        const Gap(6),
        Text(
              'Choose your preferred translation language. You can download and manage resources for other languages later.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textSecondary,
                height: 1.4,
              ),
            )
            .animate()
            .fadeIn(duration: 450.ms, delay: 100.ms)
            .slideY(begin: 0.1, end: 0),
        Gap(isWideWindow ? 12 : 24),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWideWindow ? 4 : 2,
              childAspectRatio: 1.15,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: state.languages.length,
            itemBuilder: (context, index) {
              final lang = state.languages[index];
              final isSelected = state.selectedLanguage?.code == lang.code;

              return GestureDetector(
                    onTap: () => onSelected(lang),
                    child: AnimatedContainer(
                      duration: 250.ms,
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryMint.withValues(alpha: 0.08)
                            : cardBgColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryMint
                              : inactiveBorderColor,
                          width: isSelected ? 2.0 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryMint.withValues(
                                    alpha: 0.15,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  lang.flagEmoji,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const Gap(10),
                                Text(
                                  lang.displayName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Gap(2),
                                if (lang.code != "eng")
                                  Text(
                                    lang.nativeName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.primaryMint,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: tickColor,
                                  size: 14,
                                ),
                              ).animate().scale(duration: 200.ms),
                            ),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: (index * 40).ms)
                  .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                  );
            },
          ),
        ),
      ],
    );
  }
}
