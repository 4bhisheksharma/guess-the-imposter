import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../app/theme/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    if (isSelected) {
      borderColor = AppColors.primary;
    } else if (revealRole) {
      borderColor = player.isImposter ? AppColors.imposter : AppColors.civilian;
    }

    final cardBg = isSelected
        ? AppColors.primarySoft
        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

    return AppCard(
      onTap: onTap,
      borderColor: borderColor,
      backgroundColor: player.isEliminated
          ? (isDark ? AppColors.surfaceDark.withValues(alpha: 0.4) : Colors.grey.shade200)
          : cardBg,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: revealRole
                  ? (player.isImposter
                      ? AppColors.imposter.withValues(alpha: 0.15)
                      : AppColors.civilian.withValues(alpha: 0.15))
                  : (isSelected
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.surfaceDarkElevated
                          : AppColors.surfaceLightElevated)),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                player.isEliminated
                    ? FontAwesomeIcons.xmark
                    : (revealRole && player.isImposter
                        ? FontAwesomeIcons.userSecret
                        : FontAwesomeIcons.user),
                size: 16,
                color: revealRole
                    ? (player.isImposter ? AppColors.imposter : AppColors.civilian)
                    : (isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight)),
              ),
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
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          if (isSelected)
            const FaIcon(
              FontAwesomeIcons.solidCircleCheck,
              color: AppColors.primary,
              size: 20,
            ),
        ],
      ),
    );
  }
}
