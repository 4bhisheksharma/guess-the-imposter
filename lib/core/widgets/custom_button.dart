import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_colors.dart';
import 'bouncing_scale.dart';

/// Reusable warm minimal button with spring micro-interaction
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.height = 54.0,
    this.borderRadius = 20.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final FaIconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = backgroundColor ?? AppColors.primary;
    final defaultTextColor = textColor ?? Colors.white;

    final content = Container(
      height: height,
      decoration: BoxDecoration(
        color: onPressed == null
            ? defaultBg.withValues(alpha: 0.5)
            : defaultBg,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: onPressed != null && backgroundColor == null
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    FaIcon(icon, size: 16, color: defaultTextColor),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: defaultTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );

    return BouncingScale(
      onTap: isLoading ? null : onPressed,
      child: content,
    );
  }
}
