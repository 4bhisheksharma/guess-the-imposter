import 'player_model.dart';

enum GamePhase {
  setup,
  roleReveal,
  discussion,
  voting,
  gameOver,
}

class GameSession {
  const GameSession({
    this.players = const [],
    this.category = 'General',
    this.secretWord = '',
    this.hint = '',
    this.imposterHintEnabled = true,
    this.imposterCount = 1,
    this.currentRevealIndex = 0,
    this.phase = GamePhase.setup,
    this.discussionDurationSeconds = 180,
  });

  final List<PlayerModel> players;
  final String category;
  final String secretWord;
  final String hint;
  final bool imposterHintEnabled;
  final int imposterCount;
  final int currentRevealIndex;
  final GamePhase phase;
  final int discussionDurationSeconds;

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

  GameSession copyWith({
    List<PlayerModel>? players,
    String? category,
    String? secretWord,
    String? hint,
    bool? imposterHintEnabled,
    int? imposterCount,
    int? currentRevealIndex,
    GamePhase? phase,
    int? discussionDurationSeconds,
  }) {
    return GameSession(
      players: players ?? this.players,
      category: category ?? this.category,
      secretWord: secretWord ?? this.secretWord,
      hint: hint ?? this.hint,
      imposterHintEnabled: imposterHintEnabled ?? this.imposterHintEnabled,
      imposterCount: imposterCount ?? this.imposterCount,
      currentRevealIndex: currentRevealIndex ?? this.currentRevealIndex,
      phase: phase ?? this.phase,
      discussionDurationSeconds:
          discussionDurationSeconds ?? this.discussionDurationSeconds,
    );
  }
}
