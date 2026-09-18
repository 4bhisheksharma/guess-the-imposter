import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/timer_helper.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({
    super.key,
    required this.remainingSeconds,
    this.totalSeconds = 180,
  });

  final int remainingSeconds;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final progress = (remainingSeconds / totalSeconds).clamp(0.0, 1.0);
    final isLowTime = remainingSeconds <= 30;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: AppColors.surfaceElevated,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isLowTime ? AppColors.imposter : AppColors.primary,
                ),
              ),
            ),
            Text(
              TimerHelper.formatDuration(remainingSeconds),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isLowTime ? AppColors.imposter : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
