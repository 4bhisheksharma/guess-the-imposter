import 'package:find_the_imposter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/word_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/bouncing_scale.dart';
import '../../../core/widgets/custom_button.dart';
import '../../settings/controllers/settings_controller.dart';
import '../controllers/game_controller.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({
    super.key,
    required this.controller,
    required this.settingsController,
  });

  final GameController controller;
  final SettingsController settingsController;

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  int _playerCount = AppConstants.defaultPlayersCount;
  int _imposterCount = AppConstants.defaultImpostersCount;
  String _selectedCategoryId = 'all';
  late bool _enableHints;

  @override
  void initState() {
    super.initState();
    _enableHints = widget.settingsController.enableImposterHints;
    WordService.instance.loadWords();
  }

  FaIconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'utensils':
        return FontAwesomeIcons.utensils;
      case 'paw':
        return FontAwesomeIcons.paw;
      case 'earthAmericas':
        return FontAwesomeIcons.earthAmericas;
      case 'film':
        return FontAwesomeIcons.film;
      case 'boxOpen':
        return FontAwesomeIcons.boxOpen;
      case 'briefcase':
        return FontAwesomeIcons.briefcase;
      default:
        return FontAwesomeIcons.dice;
    }
  }

  void _onStartGame() {
    final playerNames = List.generate(_playerCount, (i) => 'Player ${i + 1}');
    final wordEntry = WordService.instance.getRandomWord(_selectedCategoryId);

    String categoryName = 'All Categories';
    if (_selectedCategoryId != 'all') {
      final found = WordService.instance.categories.where(
        (c) => c.id == _selectedCategoryId,
      );
      if (found.isNotEmpty) {
        categoryName = found.first.name;
      }
    }

    widget.controller.startNewGame(
      playerNames: playerNames,
      imposterCount: _imposterCount,
      category: categoryName,
      secretWord: wordEntry.word,
      hint: wordEntry.hint,
      imposterHintEnabled: _enableHints,
    );

    Navigator.pushNamed(context, AppRoutes.roleReveal);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = WordService.instance.categories;
    final totalWords = WordService.instance.totalWordCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Setup'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Category Selection Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$totalWords total words',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Horizontal Category Pills
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // "All Categories" Combined Option
                          _buildCategoryCard(
                            id: 'all',
                            name: 'All Categories',
                            icon: FontAwesomeIcons.dice,
                            count: totalWords,
                            isSelected: _selectedCategoryId == 'all',
                          ),
                          ...categories.map((cat) {
                            return _buildCategoryCard(
                              id: cat.id,
                              name: cat.name,
                              icon: _getCategoryIcon(cat.iconName),
                              count: cat.wordCount,
                              isSelected: _selectedCategoryId == cat.id,
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Player Count
                    _buildCounterCard(
                      title: 'Players',
                      subtitle: 'Participants in this match',
                      icon: FontAwesomeIcons.users,
                      value: _playerCount,
                      minValue: AppConstants.minPlayers,
                      maxValue: AppConstants.maxPlayers,
                      onChanged: (val) {
                        setState(() {
                          _playerCount = val;
                          if (_imposterCount >= _playerCount) {
                            _imposterCount = _playerCount - 1;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    // Imposter Count
                    _buildCounterCard(
                      title: 'Imposters',
                      subtitle: 'Hidden deceivers',
                      icon: FontAwesomeIcons.userSecret,
                      value: _imposterCount,
                      minValue: AppConstants.minImposters,
                      maxValue: (_playerCount - 1).clamp(1, 5),
                      onChanged: (val) => setState(() => _imposterCount = val),
                    ),
                    const SizedBox(height: 14),

                    // Imposter Single-Word Hint Toggle Card
                    AppCard(
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _enableHints
                                  ? AppColors.primarySoft
                                  : (isDark
                                      ? AppColors.surfaceDarkElevated
                                      : AppColors.surfaceLightElevated),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: FaIcon(
                                FontAwesomeIcons.lightbulb,
                                size: 18,
                                color: _enableHints
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMutedLight),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Imposter Hint',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _enableHints
                                      ? 'Imposter receives a 1-word clue'
                                      : 'Hardcore mode (no hints)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _enableHints,
                            onChanged: (val) =>
                                setState(() => _enableHints = val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: 'Start Game',
                icon: FontAwesomeIcons.play,
                onPressed: _onStartGame,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String id,
    required String name,
    required FaIconData icon,
    required int count,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BouncingScale(
      onTap: () => setState(() => _selectedCategoryId = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        width: 124,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : (!isDark
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FaIcon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white70 : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterCard({
    required String title,
    required String subtitle,
    required FaIconData icon,
    required int value,
    required int minValue,
    required int maxValue,
    required ValueChanged<int> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDarkElevated
                      : AppColors.surfaceLightElevated,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              BouncingScale(
                onTap: value > minValue ? () => onChanged(value - 1) : null,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: value > minValue
                        ? AppColors.primarySoft
                        : (isDark
                            ? AppColors.surfaceDarkElevated
                            : AppColors.surfaceLightElevated),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.minus,
                      size: 12,
                      color: value > minValue
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              BouncingScale(
                onTap: value < maxValue ? () => onChanged(value + 1) : null,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: value < maxValue
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.surfaceDarkElevated
                            : AppColors.surfaceLightElevated),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.plus,
                      size: 12,
                      color: value < maxValue
                          ? Colors.white
                          : (isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
