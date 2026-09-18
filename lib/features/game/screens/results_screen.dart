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
    final imposters = session.imposters;
    final eliminatedImposter = imposters.any((p) => p.isEliminated);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Over'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Result Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: eliminatedImposter
                      ? (isDark
                          ? AppColors.civilian.withValues(alpha: 0.15)
                          : const Color(0xFFE8F8F0))
                      : (isDark
                          ? AppColors.imposter.withValues(alpha: 0.15)
                          : const Color(0xFFFDEDEC)),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: eliminatedImposter
                        ? AppColors.civilian
                        : AppColors.imposter,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: eliminatedImposter
                            ? AppColors.civilian.withValues(alpha: 0.2)
                            : AppColors.imposter.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: FaIcon(
                          eliminatedImposter
                              ? FontAwesomeIcons.trophy
                              : FontAwesomeIcons.userSecret,
                          size: 24,
                          color: eliminatedImposter
                              ? AppColors.civilian
                              : AppColors.imposter,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      eliminatedImposter
                          ? 'Civilians Win!'
                          : 'Imposter Wins!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Word: ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          session.secretWord,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (session.hint.isNotEmpty && session.imposterHintEnabled) ...[
                      const SizedBox(height: 4),
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
              const SizedBox(height: 18),
              const Text(
                'Players & Roles',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: session.players.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 10),
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
        ),
      ),
    );
  }
}
