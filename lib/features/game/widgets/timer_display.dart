import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/timer_helper.dart';

class TimerDisplay extends StatefulWidget {
  const TimerDisplay({
    super.key,
    required this.remainingSeconds,
    this.totalSeconds = 180,
  });

  final int remainingSeconds;
  final int totalSeconds;

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (widget.remainingSeconds / widget.totalSeconds).clamp(0.0, 1.0);
    final isLowTime = widget.remainingSeconds <= 30;

    final display = Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: isDark
                ? AppColors.surfaceDarkElevated
                : AppColors.surfaceLightElevated,
            valueColor: AlwaysStoppedAnimation<Color>(
              isLowTime ? AppColors.imposter : AppColors.primary,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.clock,
              size: 16,
              color: isLowTime
                  ? AppColors.imposter
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 6),
            Text(
              TimerHelper.formatDuration(widget.remainingSeconds),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isLowTime
                    ? AppColors.imposter
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
              ),
            ),
          ],
        ),
      ],
    );

    if (isLowTime) {
      return ScaleTransition(
        scale: _pulseAnimation,
        child: display,
      );
    }

    return display;
  }
}
