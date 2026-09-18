import 'package:find_the_imposter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../app/routes.dart';
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

  void _toggleSecret() {
    HapticFeedback.selectionClick();
    setState(() => _isSecretVisible = !_isSecretVisible);
  }

  void _onNext() {
    HapticFeedback.lightImpact();
    setState(() => _isSecretVisible = false);
    widget.controller.advanceRoleReveal();

    if (widget.controller.session.phase == GamePhase.discussion) {
      Navigator.pushReplacementNamed(context, AppRoutes.discussion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Player Header
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDarkElevated
                              : AppColors.surfaceLightElevated,
                          shape: BoxShape.circle,
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.user,
                          size: 28,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        currentPlayer.name,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pass device to this player only',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),

                  // Secret Reveal Card
                  AppCard(
                    onTap: _toggleSecret,
                    padding: const EdgeInsets.all(28),
                    borderColor: _isSecretVisible
                        ? (currentPlayer.isImposter
                            ? AppColors.imposter
                            : AppColors.primary)
                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    backgroundColor: _isSecretVisible
                        ? (currentPlayer.isImposter
                            ? (isDark
                                ? AppColors.imposter.withValues(alpha: 0.15)
                                : const Color(0xFFFDEDEC))
                            : AppColors.primarySoft)
                        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _isSecretVisible
                                  ? (_currentPlayerColor(currentPlayer)
                                      .withValues(alpha: 0.15))
                                  : (isDark
                                      ? AppColors.surfaceDarkElevated
                                      : AppColors.surfaceLightElevated),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: FaIcon(
                                _isSecretVisible
                                    ? (_isImposter(currentPlayer)
                                        ? FontAwesomeIcons.userSecret
                                        : FontAwesomeIcons.lightbulb)
                                    : FontAwesomeIcons.eyeSlash,
                                size: 24,
                                color: _isSecretVisible
                                    ? _currentPlayerColor(currentPlayer)
                                    : (isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMutedLight),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (!_isSecretVisible) ...[
                            Text(
                              'Tap to Reveal Secret',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Make sure nobody else is looking!',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ] else ...[
                            if (currentPlayer.isImposter) ...[
                              const Text(
                                'YOU ARE THE IMPOSTER!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.imposter,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 14),
                              if (currentPlayer.hint.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const FaIcon(
                                        FontAwesomeIcons.lightbulb,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Hint: ${currentPlayer.hint}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Text(
                                  'No hints enabled. Blend in carefully!',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                            ] else ...[
                              Text(
                                currentPlayer.secretWord,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceDarkElevated
                                      : AppColors.surfaceLightElevated,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Category: ${session.category}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Next Action Button
                  CustomButton(
                    label: session.currentRevealIndex + 1 == totalPlayers
                        ? 'Start Discussion'
                        : 'Next Player',
                    icon: session.currentRevealIndex + 1 == totalPlayers
                        ? FontAwesomeIcons.play
                        : FontAwesomeIcons.arrowRight,
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

  bool _isImposter(PlayerModel player) => player.isImposter;

  Color _currentPlayerColor(PlayerModel player) {
    return player.isImposter ? AppColors.imposter : AppColors.primary;
  }
}
