import 'player_model.dart';

enum GamePhase {
  setup,
  roleReveal,
  discussion,
  voting,
  imposterGuess,
  gameOver,
}

class GameSession {
  const GameSession({
    this.players = const [],
    this.category = 'General',
    this.categoryId = 'all',
    this.secretWord = '',
    this.hint = '',
    this.imposterHintEnabled = true,
    this.imposterCount = 1,
    this.currentRevealIndex = 0,
    this.phase = GamePhase.setup,
    this.discussionDurationSeconds = 180,
    this.lastEliminatedPlayerId,
    this.imposterGuessedWord = false,
    this.imposterGuessChoice,
    this.lastChanceWordOptions = const [],
    this.enableLastChanceGuess = false,
  });

  final List<PlayerModel> players;
  final String category;
  final String categoryId;
  final String secretWord;
  final String hint;
  final bool imposterHintEnabled;
  final int imposterCount;
  final int currentRevealIndex;
  final GamePhase phase;
  final int discussionDurationSeconds;
  final String? lastEliminatedPlayerId;
  final bool imposterGuessedWord;
  final String? imposterGuessChoice;
  final List<String> lastChanceWordOptions;
  final bool enableLastChanceGuess;

  PlayerModel? get currentRevealPlayer {
    if (currentRevealIndex < players.length) {
      return players[currentRevealIndex];
    }
    return null;
  }

  bool get allRolesRevealed => currentRevealIndex >= players.length;

  List<PlayerModel> get imposters =>
      players.where((p) => p.isImposter).toList();

  List<PlayerModel> get civilians =>
      players.where((p) => !p.isImposter).toList();

  PlayerModel? get lastEliminatedPlayer {
    if (lastEliminatedPlayerId == null) return null;
    try {
      return players.firstWhere((p) => p.id == lastEliminatedPlayerId);
    } catch (_) {
      return null;
    }
  }

  bool get allImpostersEliminated =>
      imposters.isNotEmpty && imposters.every((p) => p.isEliminated);

  /// Civilians win if all imposters are eliminated AND imposter did not guess the secret word
  bool get civiliansWon {
    if (imposterGuessedWord) return false;
    return allImpostersEliminated;
  }

  GameSession copyWith({
    List<PlayerModel>? players,
    String? category,
    String? categoryId,
    String? secretWord,
    String? hint,
    bool? imposterHintEnabled,
    int? imposterCount,
    int? currentRevealIndex,
    GamePhase? phase,
    int? discussionDurationSeconds,
    String? lastEliminatedPlayerId,
    bool? imposterGuessedWord,
    String? imposterGuessChoice,
    List<String>? lastChanceWordOptions,
    bool? enableLastChanceGuess,
  }) {
    return GameSession(
      players: players ?? this.players,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      secretWord: secretWord ?? this.secretWord,
      hint: hint ?? this.hint,
      imposterHintEnabled: imposterHintEnabled ?? this.imposterHintEnabled,
      imposterCount: imposterCount ?? this.imposterCount,
      currentRevealIndex: currentRevealIndex ?? this.currentRevealIndex,
      phase: phase ?? this.phase,
      discussionDurationSeconds:
          discussionDurationSeconds ?? this.discussionDurationSeconds,
      lastEliminatedPlayerId:
          lastEliminatedPlayerId ?? this.lastEliminatedPlayerId,
      imposterGuessedWord: imposterGuessedWord ?? this.imposterGuessedWord,
      imposterGuessChoice: imposterGuessChoice ?? this.imposterGuessChoice,
      lastChanceWordOptions:
          lastChanceWordOptions ?? this.lastChanceWordOptions,
      enableLastChanceGuess:
          enableLastChanceGuess ?? this.enableLastChanceGuess,
    );
  }
}
