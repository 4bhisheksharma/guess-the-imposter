import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordEntry {
  const WordEntry({required this.word, required this.hint});

  final String word;
  final String hint;

  factory WordEntry.fromJson(Map<String, dynamic> json) {
    return WordEntry(
      word: json['word'] as String? ?? '',
      hint: json['hint'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'word': word,
        'hint': hint,
      };
}

class WordCategory {
  const WordCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.words,
    this.isCustom = false,
  });

  final String id;
  final String name;
  final String iconName;
  final List<WordEntry> words;
  final bool isCustom;

  int get wordCount => words.length;

  factory WordCategory.fromJson(Map<String, dynamic> json) {
    final wordsJson = json['words'] as List<dynamic>? ?? [];
    return WordCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      iconName: json['icon'] as String? ??
          json['iconName'] as String? ??
          'cube',
      words: wordsJson
          .map((w) => WordEntry.fromJson(w as Map<String, dynamic>))
          .toList(),
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': iconName,
        'isCustom': isCustom,
        'words': words.map((w) => w.toJson()).toList(),
      };
}

class WordService extends ChangeNotifier {
  WordService._();
  static final WordService instance = WordService._();

  static const String _customCategoriesKey = 'custom_word_categories';

  List<WordCategory> _builtinCategories = _fallbackCategories;
  List<WordCategory> _customCategories = [];
  bool _isLoaded = false;
  final Random _random = Random();

  bool get isLoaded => _isLoaded;

  /// All categories: built-in packs followed by custom packs
  List<WordCategory> get categories =>
      List.unmodifiable([..._builtinCategories, ..._customCategories]);

  /// Custom categories only
  List<WordCategory> get customCategories =>
      List.unmodifiable(_customCategories);

  int get totalWordCount {
    return categories.fold(0, (sum, cat) => sum + cat.words.length);
  }

  /// Loads categories and words from assets/data/words.json and SharedPreferences
  Future<void> loadWords() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/words.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final categoriesList = (data['categories'] as List<dynamic>? ?? [])
          .map((c) => WordCategory.fromJson(c as Map<String, dynamic>))
          .toList();

      if (categoriesList.isNotEmpty) {
        _builtinCategories = categoriesList;
      }
    } catch (_) {
      // Fallback in-memory set if bundle is unavailable during headless tests
      _builtinCategories = _fallbackCategories;
    }

    // Load custom categories from SharedPreferences
    await _loadCustomCategories();

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _loadCustomCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customJson = prefs.getStringList(_customCategoriesKey) ?? [];
      _customCategories = customJson.map((str) {
        final Map<String, dynamic> map = json.decode(str);
        return WordCategory.fromJson(map);
      }).toList();
    } catch (_) {
      // Ignored in test environments without plugin channels
    }
  }

  Future<void> _persistCustomCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list =
          _customCategories.map((c) => json.encode(c.toJson())).toList();
      await prefs.setStringList(_customCategoriesKey, list);
    } catch (_) {
      // Ignored in test environments without plugin channels
    }
  }

  /// Adds or updates a custom category
  Future<void> saveCustomCategory(WordCategory category) async {
    final updatedCategory = WordCategory(
      id: category.id.isEmpty
          ? 'custom_${DateTime.now().millisecondsSinceEpoch}'
          : category.id,
      name: category.name.trim(),
      iconName: category.iconName,
      words: category.words,
      isCustom: true,
    );

    final existingIndex =
        _customCategories.indexWhere((c) => c.id == updatedCategory.id);
    if (existingIndex >= 0) {
      _customCategories[existingIndex] = updatedCategory;
    } else {
      _customCategories.add(updatedCategory);
    }

    await _persistCustomCategories();
    notifyListeners();
  }

  /// Deletes a custom category
  Future<void> deleteCustomCategory(String categoryId) async {
    _customCategories.removeWhere((c) => c.id == categoryId);
    await _persistCustomCategories();
    notifyListeners();
  }

  /// Returns a random word and hint for the given category (or 'all' for mixed pool)
  WordEntry getRandomWord(String categoryId) {
    final allCats = categories;
    if (allCats.isEmpty) {
      return const WordEntry(word: 'Pizza', hint: 'Cheese');
    }

    if (categoryId == 'all') {
      final allWords = [
        for (final cat in allCats) ...cat.words,
      ];
      if (allWords.isEmpty) return const WordEntry(word: 'Sun', hint: 'Hot');
      return allWords[_random.nextInt(allWords.length)];
    }

    final category = allCats.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => allCats.first,
    );

    if (category.words.isEmpty) {
      return const WordEntry(word: 'Pizza', hint: 'Cheese');
    }

    return category.words[_random.nextInt(category.words.length)];
  }

  /// Returns plausible decoy words from the same category for the imposter guess mini-game
  List<String> getDecoyWords(String categoryId, String secretWord, int count) {
    final allCats = categories;
    WordCategory category = allCats.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => allCats.first,
    );

    final pool = <String>[];
    for (final entry in category.words) {
      if (entry.word.toLowerCase() != secretWord.toLowerCase()) {
        pool.add(entry.word);
      }
    }

    // If not enough decoys in selected category, sample from all categories
    if (pool.length < count) {
      for (final cat in allCats) {
        for (final entry in cat.words) {
          if (entry.word.toLowerCase() != secretWord.toLowerCase() &&
              !pool.contains(entry.word)) {
            pool.add(entry.word);
          }
        }
      }
    }

    pool.shuffle(_random);
    return pool.take(count).toList();
  }

  static final List<WordCategory> _fallbackCategories = [
    const WordCategory(
      id: 'food_drinks',
      name: 'Food & Drinks',
      iconName: 'utensils',
      words: [
        WordEntry(word: 'Pizza', hint: 'Cheese'),
        WordEntry(word: 'Coffee', hint: 'Caffeine'),
        WordEntry(word: 'Burger', hint: 'Patty'),
        WordEntry(word: 'Sushi', hint: 'Rice'),
        WordEntry(word: 'Pancake', hint: 'Syrup'),
      ],
    ),
    const WordCategory(
      id: 'animals_nature',
      name: 'Animals & Nature',
      iconName: 'paw',
      words: [
        WordEntry(word: 'Sun', hint: 'Hot'),
        WordEntry(word: 'Lion', hint: 'Roar'),
        WordEntry(word: 'Penguin', hint: 'Ice'),
        WordEntry(word: 'Eagle', hint: 'Sky'),
        WordEntry(word: 'Dolphin', hint: 'Ocean'),
      ],
    ),
    const WordCategory(
      id: 'simple_words',
      name: 'Simple Words',
      iconName: 'house',
      words: [
        WordEntry(word: 'Chair', hint: 'Sit'),
        WordEntry(word: 'Table', hint: 'Furniture'),
        WordEntry(word: 'Clock', hint: 'Time'),
        WordEntry(word: 'Mirror', hint: 'Reflect'),
        WordEntry(word: 'Book', hint: 'Pages'),
        WordEntry(word: 'Shoes', hint: 'Feet'),
      ],
    ),
  ];
}
