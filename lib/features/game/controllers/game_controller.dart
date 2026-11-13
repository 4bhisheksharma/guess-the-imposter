import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../models/game_session.dart';
import '../models/player_model.dart';

/// Game controller managing state transitions, player roles, and imposter hints
class GameController extends ChangeNotifier {
  GameSession _session = const GameSession();
  List<String> _playerNames = List.generate(
    AppConstants.defaultPlayersCount,
    (i) => 'Player ${i + 1}',
  );

  GameSession get session => _session;
  List<String> get playerNames => List.unmodifiable(_playerNames);

  /// Updates or renames a player at the specified index
  void setPlayerName(int index, String newName) {
    if (index >= 0 && index < _playerNames.length) {
      final trimmed = newName.trim();
      _playerNames[index] = trimmed.isEmpty ? 'Player ${index + 1}' : trimmed;
      notifyListeners();
    }
  }

  /// Adjusts the player count while preserving any custom names entered
  void setPlayerCount(int count) {
    final clamped = count.clamp(AppConstants.minPlayers, AppConstants.maxPlayers);
    if (clamped > _playerNames.length) {
      for (int i = _playerNames.length; i < clamped; i++) {
        _playerNames.add('Player ${i + 1}');
      }
    } else if (clamped < _playerNames.length) {
      _playerNames = _playerNames.sublist(0, clamped);
    }
    notifyListeners();
  }

  /// Resets player names back to defaults ('Player 1', 'Player 2', etc.)
  void resetPlayerNames() {
    _playerNames = List.generate(
      _playerNames.length.clamp(AppConstants.minPlayers, AppConstants.maxPlayers),
      (i) => 'Player ${i + 1}',
    );
    notifyListeners();
  }

  /// Starts a new game session with cryptographically random assigned roles
  void startNewGame({
    required List<String> playerNames,
    required int imposterCount,
    required String category,
    required String secretWord,
    String hint = '',
    bool imposterHintEnabled = true,
    int discussionDurationSeconds = 180,
  }) {
    _playerNames = List.from(playerNames);
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
      discussionDurationSeconds: discussionDurationSeconds,
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
      lastEliminatedPlayerId: playerId,
      phase: GamePhase.gameOver,
    );
    notifyListeners();
  }

  /// Resets back to game setup while preserving remembered player names
  void resetGame() {
    _session = const GameSession();
    notifyListeners();
  }
}
