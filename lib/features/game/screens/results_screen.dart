import 'package:flutter/material.dart';
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: eliminatedImposter
                      ? AppColors.civilian.withValues(alpha: 0.15)
                      : AppColors.imposter.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: eliminatedImposter
                        ? AppColors.civilian
                        : AppColors.imposter,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      eliminatedImposter
                          ? Icons.emoji_events_rounded
                          : Icons.theater_comedy,
                      size: 54,
                      color: eliminatedImposter
                          ? AppColors.civilian
                          : AppColors.imposter,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      eliminatedImposter
                          ? 'Civilians Win!'
                          : 'Imposter Wins!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Secret word was: ${session.secretWord}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Players & Roles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                icon: Icons.replay_rounded,
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
                backgroundColor: AppColors.surfaceDark,
                textColor: AppColors.textPrimary,
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
