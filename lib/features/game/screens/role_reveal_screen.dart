import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/game_controller.dart';
import '../models/game_session.dart';
import '../models/player_model.dart';

class RoleRevealScreen extends StatefulWidget {
  const RoleRevealScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen> {
  bool _isSecretVisible = false;

  void _onNext() {
    setState(() => _isSecretVisible = false);
    widget.controller.advanceRoleReveal();

    if (widget.controller.session.phase == GamePhase.discussion) {
      Navigator.pushReplacementNamed(context, AppRoutes.discussion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final session = widget.controller.session;
        final currentPlayer = session.currentRevealPlayer;

        if (currentPlayer == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final playerNumber = session.currentRevealIndex + 1;
        final totalPlayers = session.players.length;

        return Scaffold(
          appBar: AppBar(
            title: Text('Player $playerNumber of $totalPlayers'),
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        currentPlayer.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pass the device to this player',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _isSecretVisible = !_isSecretVisible),
                    child: AppCard(
                      padding: const EdgeInsets.all(32),
                      backgroundColor: _isSecretVisible
                          ? (currentPlayer.isImposter
                              ? AppColors.imposter.withValues(alpha: 0.15)
                              : AppColors.primary.withValues(alpha: 0.15))
                          : AppColors.surfaceDark,
                      borderColor: _isSecretVisible
                          ? (currentPlayer.isImposter
                              ? AppColors.imposter
                              : AppColors.primary)
                          : AppColors.border,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isSecretVisible
                                ? Icons.visibility
                                : Icons.visibility_off_outlined,
                            size: 48,
                            color: _isSecretVisible
                                ? (currentPlayer.isImposter
                                    ? AppColors.imposter
                                    : AppColors.primary)
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isSecretVisible
                                ? (currentPlayer.isImposter
                                    ? 'YOU ARE THE IMPOSTER!'
                                    : currentPlayer.secretWord)
                                : 'Tap to reveal secret word',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _isSecretVisible ? 22 : 16,
                              fontWeight: FontWeight.bold,
                              color: _isSecretVisible
                                  ? (_currentPlayerColor(currentPlayer))
                                  : AppColors.textSecondary,
                            ),
                          ),
                          if (_isSecretVisible && !currentPlayer.isImposter) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Category: ${session.category}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  CustomButton(
                    label: session.currentRevealIndex + 1 == totalPlayers
                        ? 'Start Discussion'
                        : 'Next Player',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _onNext,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _currentPlayerColor(PlayerModel player) {
    return player.isImposter ? AppColors.imposter : AppColors.civilian;
  }
}
