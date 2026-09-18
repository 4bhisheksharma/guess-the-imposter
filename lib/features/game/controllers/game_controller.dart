import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/game_session.dart';
import '../models/player_model.dart';

/// Game controller managing state transitions, player roles, and imposter hints
class GameController extends ChangeNotifier {
  GameSession _session = const GameSession();

  GameSession get session => _session;

  /// Starts a new game session with cryptographically random assigned roles
  void startNewGame({
    required List<String> playerNames,
    required int imposterCount,
    required String category,
    required String secretWord,
    String hint = '',
    bool imposterHintEnabled = true,
  }) {
    final random = Random.secure();
    final totalPlayers = playerNames.length;
    final clampedImposters = imposterCount.clamp(1, totalPlayers - 1);

    // Shuffle player indices securely to guarantee true randomness
    final shuffledIndices = List<int>.generate(totalPlayers, (i) => i)..shuffle(random);
    final imposterIndices = shuffledIndices.take(clampedImposters).toSet();

    final players = List.generate(totalPlayers, (index) {
      final isImposter = imposterIndices.contains(index);
      return PlayerModel(
        id: 'player_$index',
        name: playerNames[index],
        role: isImposter ? PlayerRole.imposter : PlayerRole.civilian,
        secretWord: isImposter ? 'IMPOSTER' : secretWord,
        hint: isImposter && imposterHintEnabled ? hint : '',
      );
    });

    _session = GameSession(
      players: players,
      category: category,
      secretWord: secretWord,
      hint: hint,
      imposterHintEnabled: imposterHintEnabled,
      imposterCount: clampedImposters,
      currentRevealIndex: 0,
      phase: GamePhase.roleReveal,
    );

    notifyListeners();
  }

  /// Advances to the next player's secret role reveal
  void advanceRoleReveal() {
    if (_session.currentRevealIndex + 1 < _session.players.length) {
      _session = _session.copyWith(
        currentRevealIndex: _session.currentRevealIndex + 1,
      );
    } else {
      _session = _session.copyWith(
        phase: GamePhase.discussion,
      );
    }
    notifyListeners();
  }

  /// Transitions from discussion to voting phase
  void startVoting() {
    _session = _session.copyWith(phase: GamePhase.voting);
    notifyListeners();
  }

  /// Eliminates a player and checks for victory conditions
  void eliminatePlayer(String playerId) {
    final updatedPlayers = _session.players.map((p) {
      if (p.id == playerId) {
        return p.copyWith(isEliminated: true);
      }
      return p;
    }).toList();

    _session = _session.copyWith(
      players: updatedPlayers,
      phase: GamePhase.gameOver,
    );
    notifyListeners();
  }

  /// Resets back to game setup
  void resetGame() {
    _session = const GameSession();
    notifyListeners();
  }
}
