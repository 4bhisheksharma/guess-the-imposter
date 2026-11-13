import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../../settings/controllers/settings_controller.dart';
import '../controllers/game_controller.dart';
import '../models/game_session.dart';
import '../models/player_model.dart';

class RoleRevealScreen extends StatefulWidget {
  const RoleRevealScreen({
    super.key,
    required this.controller,
    this.settingsController,
  });

  final GameController controller;
  final SettingsController? settingsController;

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen> {
  bool _isSecretVisible = false;
  bool _hasViewedSecret = false;

  bool get _isHoldMode => widget.settingsController?.holdToReveal ?? false;

  void _revealSecret() {
    if (_isSecretVisible && !_isHoldMode) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isSecretVisible = true;
      _hasViewedSecret = true;
    });
  }

  void _hideSecret() {
    if (!_isHoldMode) return;
    setState(() => _isSecretVisible = false);
  }

  void _onNext() {
    HapticFeedback.lightImpact();
    setState(() {
      _isSecretVisible = false;
      _hasViewedSecret = false;
    });
    widget.controller.advanceRoleReveal();

    if (widget.controller.session.phase == GamePhase.discussion) {
      Navigator.pushReplacementNamed(context, AppRoutes.discussion);
    }
  }

  Future<bool> _onWillPop() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shouldQuit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Leave Game?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'Are you sure you want to exit? Current game progress will be lost.',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Stay',
              style: TextStyle(
                color:
                    isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.controller.resetGame();
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.imposter,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Exit Game',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return shouldQuit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldQuit = await _onWillPop();
        if (shouldQuit && context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.home, (route) => false);
        }
      },
      child: ListenableBuilder(
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
              actions: [
                IconButton(
                  tooltip: 'Exit Game',
                  icon: FaIcon(
                    FontAwesomeIcons.arrowRightFromBracket,
                    size: 16,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  onPressed: () async {
                    final shouldQuit = await _onWillPop();
                    if (shouldQuit && context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, AppRoutes.home, (route) => false);
                    }
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Top Player Identity Card
                        _buildPlayerHeader(currentPlayer, isDark),
                        const SizedBox(height: 16),

                        // 2. Big Word Area Card (Prominent & Responsive)
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 500,
                                minHeight: 290,
                              ),
                              child: _buildSecretCard(
                                  currentPlayer, session, isDark),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 3. Next Action Button (active after role has been viewed)
                        CustomButton(
                          label: session.currentRevealIndex + 1 == totalPlayers
                              ? 'Start Discussion'
                              : 'Next Player',
                          icon: session.currentRevealIndex + 1 == totalPlayers
                              ? FontAwesomeIcons.play
                              : FontAwesomeIcons.arrowRight,
                          onPressed: (_isSecretVisible || _hasViewedSecret)
                              ? _onNext
                              : null,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerHeader(PlayerModel player, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primarySoftColor(isDark),
              shape: BoxShape.circle,
            ),
            child: const FaIcon(
              FontAwesomeIcons.user,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  'Pass device to this player only',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecretCard(
      PlayerModel player, GameSession session, bool isDark) {
    final borderColor = _isSecretVisible
        ? (player.isImposter ? AppColors.imposter : AppColors.primary)
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    final backgroundColor = _isSecretVisible
        ? (player.isImposter
            ? (isDark
                ? AppColors.imposter.withValues(alpha: 0.15)
                : const Color(0xFFFDEDEC))
            : (isDark
                ? AppColors.surfaceDarkElevated
                : AppColors.primarySoft))
        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

    return GestureDetector(
      onTapDown: _isHoldMode ? (_) => _revealSecret() : null,
      onTapUp: _isHoldMode ? (_) => _hideSecret() : null,
      onTapCancel: _isHoldMode ? () => _hideSecret() : null,
      child: AppCard(
        onTap: !_isHoldMode
            ? (_isSecretVisible ? null : _revealSecret)
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        borderColor: borderColor,
        backgroundColor: backgroundColor,
        borderRadius: 28,
        elevation: true,
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Prominent Reveal / Status Icon Container
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: _isSecretVisible
                        ? (player.isImposter
                            ? AppColors.imposter.withValues(alpha: 0.18)
                            : AppColors.primary.withValues(alpha: 0.18))
                        : (isDark
                            ? AppColors.surfaceDarkElevated
                            : AppColors.surfaceLightElevated),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isSecretVisible
                          ? (player.isImposter
                              ? AppColors.imposter.withValues(alpha: 0.4)
                              : AppColors.primary.withValues(alpha: 0.4))
                          : (isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: FaIcon(
                      _isSecretVisible
                          ? (player.isImposter
                              ? FontAwesomeIcons.userSecret
                              : FontAwesomeIcons.lightbulb)
                          : FontAwesomeIcons.eyeSlash,
                      size: 30,
                      color: _isSecretVisible
                          ? (player.isImposter
                              ? AppColors.imposter
                              : AppColors.primary)
                          : (isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (!_isSecretVisible) ...[
                  // Hidden State
                  Text(
                    _isHoldMode
                        ? 'Hold to Peek Secret'
                        : 'Tap to Reveal Secret',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDarkElevated
                          : AppColors.surfaceLightElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _isHoldMode
                          ? 'Release to hide role before passing'
                          : 'Make sure nobody else is looking!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ] else ...[
                  // Revealed State
                  if (player.isImposter) ...[
                    // IMPOSTER VIEW
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.imposter.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'SECRET ROLE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: AppColors.imposter,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'YOU ARE THE IMPOSTER!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.imposter,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (player.hint.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoftColor(isDark),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.lightbulb,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Hint: ${player.hint}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'No hints enabled. Listen and blend in carefully!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    const SizedBox(height: 14),
                    Text(
                      'Pretend you know the secret word during discussion.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ] else ...[
                    // CIVILIAN VIEW (BIG WORD AREA CARD)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'YOUR SECRET WORD',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Giant secret word display
                    SelectableText(
                      player.secretWord,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Text(
                        'Category: ${session.category}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Give subtle clues without revealing the word directly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
