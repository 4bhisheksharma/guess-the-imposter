import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

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
}

class WordCategory {
  const WordCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.words,
  });

  final String id;
  final String name;
  final String iconName;
  final List<WordEntry> words;

  int get wordCount => words.length;

  factory WordCategory.fromJson(Map<String, dynamic> json) {
    final wordsJson = json['words'] as List<dynamic>? ?? [];
    return WordCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      iconName: json['icon'] as String? ?? 'cube',
      words: wordsJson.map((w) => WordEntry.fromJson(w as Map<String, dynamic>)).toList(),
    );
  }
}

class WordService {
  WordService._();
  static final WordService instance = WordService._();

  List<WordCategory> _categories = [];
  bool _isLoaded = false;
  final Random _random = Random();

  bool get isLoaded => _isLoaded;
  List<WordCategory> get categories => List.unmodifiable(_categories);

  int get totalWordCount {
    return _categories.fold(0, (sum, cat) => sum + cat.words.length);
  }

  /// Loads categories and words from assets/data/words.json
  Future<void> loadWords() async {
    if (_isLoaded && _categories.isNotEmpty) return;

    try {
      final jsonString = await rootBundle.loadString('assets/data/words.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final categoriesList = (data['categories'] as List<dynamic>? ?? [])
          .map((c) => WordCategory.fromJson(c as Map<String, dynamic>))
          .toList();

      _categories = categoriesList;
      _isLoaded = true;
    } catch (_) {
      // Fallback in-memory set if bundle is unavailable during headless tests
      _categories = _fallbackCategories;
      _isLoaded = true;
    }
  }

  /// Returns a random word and hint for the given category (or 'all' for mixed pool)
  WordEntry getRandomWord(String categoryId) {
    if (_categories.isEmpty) {
      return const WordEntry(word: 'Pizza', hint: 'Cheese');
    }

    if (categoryId == 'all') {
      final allWords = [
        for (final cat in _categories) ...cat.words,
      ];
      if (allWords.isEmpty) return const WordEntry(word: 'Sun', hint: 'Hot');
      return allWords[_random.nextInt(allWords.length)];
    }

    final category = _categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => _categories.first,
    );

    if (category.words.isEmpty) {
      return const WordEntry(word: 'Pizza', hint: 'Cheese');
    }

    return category.words[_random.nextInt(category.words.length)];
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
  ];
}
