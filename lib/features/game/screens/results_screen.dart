import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/game_controller.dart';
import '../widgets/player_card.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final session = controller.session;
    final lastEliminated = session.lastEliminatedPlayer;
    final civiliansWon = session.civiliansWon;

    final resultColor = civiliansWon ? AppColors.civilian : AppColors.imposter;
    final resultBg = civiliansWon
        ? (isDark
            ? AppColors.civilian.withValues(alpha: 0.15)
            : const Color(0xFFE8F8F0))
        : (isDark
            ? AppColors.imposter.withValues(alpha: 0.15)
            : const Color(0xFFFDEDEC));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.resetGame();
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.home, (route) => false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Game Over'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Result Summary Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: resultBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: resultColor,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: resultColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: FaIcon(
                                civiliansWon
                                    ? FontAwesomeIcons.trophy
                                    : FontAwesomeIcons.userSecret,
                                size: 24,
                                color: resultColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            civiliansWon
                                ? 'Civilians Win!'
                                : 'Imposter Wins!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          if (lastEliminated != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.surfaceDark
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                ),
                              ),
                              child: Text(
                                '${lastEliminated.name} was eliminated (${lastEliminated.isImposter ? 'Imposter' : 'Civilian'})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: lastEliminated.isImposter
                                      ? AppColors.imposter
                                      : (isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Secret Word: ',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                              Text(
                                session.secretWord,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          if (session.hint.isNotEmpty &&
                              session.imposterHintEnabled) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.lightbulb,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Imposter Hint: "${session.hint}"',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Players & Roles',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          'All roles revealed',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: session.players.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final player = session.players[index];
                          return PlayerCard(
                            player: player,
                            revealRole: true,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      label: 'Play Again',
                      icon: FontAwesomeIcons.rotateRight,
                      onPressed: () {
                        controller.resetGame();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.gameSetup,
                          (route) => route.isFirst,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      label: 'Main Menu',
                      icon: FontAwesomeIcons.house,
                      backgroundColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      textColor: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      borderColor:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                      onPressed: () {
                        controller.resetGame();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.home,
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
