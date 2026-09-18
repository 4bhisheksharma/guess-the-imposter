import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../models/player_model.dart';

class PlayerCard extends StatelessWidget {
  const PlayerCard({
    super.key,
    required this.player,
    this.onTap,
    this.isSelected = false,
    this.revealRole = false,
  });

  final PlayerModel player;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool revealRole;

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.border;
    if (isSelected) {
      borderColor = AppColors.primary;
    } else if (revealRole) {
      borderColor = player.isImposter ? AppColors.imposter : AppColors.civilian;
    }

    return AppCard(
      onTap: onTap,
      borderColor: borderColor,
      backgroundColor: player.isEliminated
          ? AppColors.surfaceDark.withValues(alpha: 0.5)
          : AppColors.surfaceDark,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: revealRole
                ? (player.isImposter ? AppColors.imposter : AppColors.civilian)
                : AppColors.surfaceElevated,
            child: Icon(
              player.isEliminated
                  ? Icons.close
                  : (revealRole && player.isImposter
                      ? Icons.theater_comedy
                      : Icons.person),
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: player.isEliminated
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (revealRole)
                  Text(
                    player.isImposter ? 'Imposter' : 'Civilian',
                    style: TextStyle(
                      fontSize: 13,
                      color: player.isImposter
                          ? AppColors.imposter
                          : AppColors.civilian,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle, color: AppColors.primary),
        ],
      ),
    );
  }
}
