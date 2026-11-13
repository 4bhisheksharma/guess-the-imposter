import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/services/word_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/bouncing_scale.dart';
import '../../../core/widgets/custom_button.dart';

class EditCategoryScreen extends StatefulWidget {
  const EditCategoryScreen({super.key, this.category});

  final WordCategory? category;

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  late final TextEditingController _nameController;
  late String _selectedIcon;
  late final List<Map<String, TextEditingController>> _wordControllers;

  final List<Map<String, dynamic>> _iconChoices = const [
    {'name': 'dice', 'icon': FontAwesomeIcons.dice},
    {'name': 'fire', 'icon': FontAwesomeIcons.fire},
    {'name': 'heart', 'icon': FontAwesomeIcons.heart},
    {'name': 'star', 'icon': FontAwesomeIcons.star},
    {'name': 'lightbulb', 'icon': FontAwesomeIcons.lightbulb},
    {'name': 'gamepad', 'icon': FontAwesomeIcons.gamepad},
    {'name': 'music', 'icon': FontAwesomeIcons.music},
    {'name': 'utensils', 'icon': FontAwesomeIcons.utensils},
    {'name': 'paw', 'icon': FontAwesomeIcons.paw},
    {'name': 'house', 'icon': FontAwesomeIcons.house},
    {'name': 'shapes', 'icon': FontAwesomeIcons.shapes},
    {'name': 'briefcase', 'icon': FontAwesomeIcons.briefcase},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedIcon = widget.category?.iconName ?? 'dice';

    _wordControllers = [];
    if (widget.category != null && widget.category!.words.isNotEmpty) {
      for (final entry in widget.category!.words) {
        _wordControllers.add({
          'word': TextEditingController(text: entry.word),
          'hint': TextEditingController(text: entry.hint),
        });
      }
    } else {
      // Start with 3 empty word entries by default
      for (int i = 0; i < 3; i++) {
        _wordControllers.add({
          'word': TextEditingController(),
          'hint': TextEditingController(),
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final pair in _wordControllers) {
      pair['word']?.dispose();
      pair['hint']?.dispose();
    }
    super.dispose();
  }

  void _addWordField() {
    HapticFeedback.lightImpact();
    setState(() {
      _wordControllers.add({
        'word': TextEditingController(),
        'hint': TextEditingController(),
      });
    });
  }

  void _removeWordField(int index) {
    if (_wordControllers.length <= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Categories must have at least 3 words'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      final removed = _wordControllers.removeAt(index);
      removed['word']?.dispose();
      removed['hint']?.dispose();
    });
  }

  Future<void> _onSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a category name'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final validWords = <WordEntry>[];
    for (final pair in _wordControllers) {
      final w = pair['word']!.text.trim();
      final h = pair['hint']!.text.trim();
      if (w.isNotEmpty) {
        validWords.add(WordEntry(word: w, hint: h.isEmpty ? 'Clue' : h));
      }
    }

    if (validWords.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter at least 3 words for this pack'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final newCategory = WordCategory(
      id: widget.category?.id ?? '',
      name: name,
      iconName: _selectedIcon,
      words: validWords,
      isCustom: true,
    );

    await WordService.instance.saveCustomCategory(newCategory);

    if (mounted) {
      Navigator.pop(context, newCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Word Pack' : 'Create Word Pack'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    children: [
                      // Pack Name Card
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pack Name',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              maxLength: 30,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'e.g. Inside Jokes, College Friends',
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMutedLight,
                                ),
                                counterStyle: TextStyle(
                                  color: isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMutedLight,
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? AppColors.surfaceDarkElevated
                                    : AppColors.surfaceLightElevated,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                      color: AppColors.primary, width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Icon Selection Card
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose Icon',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _iconChoices.map((item) {
                                final isSelected =
                                    _selectedIcon == item['name'];
                                final FaIconData iconData = item['icon'];

                                return BouncingScale(
                                  onTap: () => setState(
                                      () => _selectedIcon = item['name']),
                                  child: Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : (isDark
                                              ? AppColors.surfaceDarkElevated
                                              : AppColors.surfaceLightElevated),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : (isDark
                                                ? AppColors.borderDark
                                                : AppColors.borderLight),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Center(
                                      child: FaIcon(
                                        iconData,
                                        size: 18,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimaryLight),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Words & Hints Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Words & Hints (${_wordControllers.length})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            'Min 3 required',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // List of Word / Hint inputs
                      for (int i = 0; i < _wordControllers.length; i++) ...[
                        AppCard(
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: _wordControllers[i]['word'],
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Word (e.g. Coffee)',
                                    hintStyle: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.textMutedDark
                                          : AppColors.textMutedLight,
                                    ),
                                    isDense: true,
                                    filled: true,
                                    fillColor: isDark
                                        ? AppColors.surfaceDarkElevated
                                        : AppColors.surfaceLightElevated,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? AppColors.borderDark
                                            : AppColors.borderLight,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _wordControllers[i]['hint'],
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Hint (e.g. Morning)',
                                    hintStyle: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.textMutedDark
                                          : AppColors.textMutedLight,
                                    ),
                                    isDense: true,
                                    filled: true,
                                    fillColor: isDark
                                        ? AppColors.surfaceDarkElevated
                                        : AppColors.surfaceLightElevated,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? AppColors.borderDark
                                            : AppColors.borderLight,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: FaIcon(
                                  FontAwesomeIcons.trashCan,
                                  size: 14,
                                  color: isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textSecondaryLight,
                                ),
                                onPressed: () => _removeWordField(i),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Add word button
                      TextButton.icon(
                        onPressed: _addWordField,
                        icon: const FaIcon(FontAwesomeIcons.plus,
                            size: 13, color: AppColors.primary),
                        label: const Text(
                          'Add Another Word',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: CustomButton(
                    label: isEditing ? 'Save Changes' : 'Create Word Pack',
                    icon: FontAwesomeIcons.floppyDisk,
                    onPressed: _onSave,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

