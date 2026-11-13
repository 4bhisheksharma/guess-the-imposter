import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/services/word_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/bouncing_scale.dart';
import '../../../core/widgets/custom_button.dart';
import 'edit_category_screen.dart';

class CustomCategoriesScreen extends StatelessWidget {
  const CustomCategoriesScreen({super.key});

  FaIconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fire':
        return FontAwesomeIcons.fire;
      case 'heart':
        return FontAwesomeIcons.heart;
      case 'star':
        return FontAwesomeIcons.star;
      case 'lightbulb':
        return FontAwesomeIcons.lightbulb;
      case 'gamepad':
        return FontAwesomeIcons.gamepad;
      case 'music':
        return FontAwesomeIcons.music;
      case 'utensils':
        return FontAwesomeIcons.utensils;
      case 'paw':
        return FontAwesomeIcons.paw;
      case 'house':
        return FontAwesomeIcons.house;
      case 'shapes':
        return FontAwesomeIcons.shapes;
      case 'briefcase':
        return FontAwesomeIcons.briefcase;
      default:
        return FontAwesomeIcons.dice;
    }
  }

  void _confirmDelete(BuildContext context, WordCategory category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Delete "${category.name}"?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'This will permanently remove this word pack and all its ${category.wordCount} words.',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color:
                    isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              await WordService.instance.deleteCustomCategory(category.id);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.imposter,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: WordService.instance,
      builder: (context, _) {
        final customCats = WordService.instance.customCategories;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Custom Word Packs'),
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (customCats.isEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoftColor(isDark),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.folderPlus,
                                      size: 32,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'No Custom Packs Yet',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32),
                                  child: Text(
                                    'Create your own packs for inside jokes, party themes, or specific topics!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: customCats.length,
                            separatorBuilder: (_, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final cat = customCats[index];
                              return AppCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.primarySoftColor(isDark),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: FaIcon(
                                          _getIconData(cat.iconName),
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cat.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? AppColors.textPrimaryDark
                                                  : AppColors.textPrimaryLight,
                                            ),
                                          ),
                                          Text(
                                            '${cat.wordCount} words',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? AppColors.textSecondaryDark
                                                  : AppColors
                                                      .textSecondaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Edit Pack',
                                      icon: FaIcon(
                                        FontAwesomeIcons.pen,
                                        size: 14,
                                        color: isDark
                                            ? AppColors.textMutedDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditCategoryScreen(
                                                category: cat),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      tooltip: 'Delete Pack',
                                      icon: const FaIcon(
                                        FontAwesomeIcons.trashCan,
                                        size: 14,
                                        color: AppColors.imposter,
                                      ),
                                      onPressed: () =>
                                          _confirmDelete(context, cat),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'Create Word Pack',
                        icon: FontAwesomeIcons.plus,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditCategoryScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

