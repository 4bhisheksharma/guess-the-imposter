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
    this.imposterCount = 1,
    this.currentRevealIndex = 0,
    this.phase = GamePhase.setup,
  });

  final List<PlayerModel> players;
  final String category;
  final String secretWord;
  final int imposterCount;
  final int currentRevealIndex;
  final GamePhase phase;

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
    int? imposterCount,
    int? currentRevealIndex,
    GamePhase? phase,
  }) {
    return GameSession(
      players: players ?? this.players,
      category: category ?? this.category,
      secretWord: secretWord ?? this.secretWord,
      imposterCount: imposterCount ?? this.imposterCount,
      currentRevealIndex: currentRevealIndex ?? this.currentRevealIndex,
      phase: phase ?? this.phase,
    );
  }
}
