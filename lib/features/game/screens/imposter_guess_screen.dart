import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/bouncing_scale.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/game_controller.dart';

class ImposterGuessScreen extends StatefulWidget {
  const ImposterGuessScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<ImposterGuessScreen> createState() => _ImposterGuessScreenState();
}

class _ImposterGuessScreenState extends State<ImposterGuessScreen> {
  String? _selectedGuess;
  bool _hasSubmitted = false;

  void _onSelectOption(String word) {
    if (_hasSubmitted) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _selectedGuess = word;
      _hasSubmitted = true;
    });
    widget.controller.submitImposterGuess(word);
  }

  void _onFinish() {
    Navigator.pushReplacementNamed(context, AppRoutes.results);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final session = widget.controller.session;
    final imposter = session.lastEliminatedPlayer;
    final imposterName = imposter?.name ?? 'Imposter';
    final options = session.lastChanceWordOptions;
    final isCorrect = session.imposterGuessedWord;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Last Chance Guess'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            // Header badge
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: _hasSubmitted
                                    ? (isCorrect
                                        ? AppColors.primary
                                            .withValues(alpha: 0.18)
                                        : AppColors.imposter
                                            .withValues(alpha: 0.18))
                                    : AppColors.primarySoftColor(isDark),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _hasSubmitted
                                      ? (isCorrect
                                          ? AppColors.primary
                                          : AppColors.imposter)
                                      : AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: FaIcon(
                                  _hasSubmitted
                                      ? (isCorrect
                                          ? FontAwesomeIcons.trophy
                                          : FontAwesomeIcons.xmark)
                                      : FontAwesomeIcons.userSecret,
                                  size: 28,
                                  color: _hasSubmitted
                                      ? (isCorrect
                                          ? AppColors.primary
                                          : AppColors.imposter)
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '$imposterName, You Were Caught!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.imposter.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'STEAL THE VICTORY',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  color: AppColors.imposter,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _hasSubmitted
                                  ? (isCorrect
                                      ? 'You guessed the secret word correctly! Imposter steals the match!'
                                      : 'Wrong guess! Civilians prevail!')
                                  : 'What was the secret word? Pick your guess below to steal the win!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Word Options Cards
                            if (!_hasSubmitted) ...[
                              for (final word in options) ...[
                                BouncingScale(
                                  onTap: () => _onSelectOption(word),
                                  child: AppCard(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 16),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    borderColor: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          word,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimaryLight,
                                          ),
                                        ),
                                        FaIcon(
                                          FontAwesomeIcons.circleQuestion,
                                          size: 16,
                                          color: isDark
                                              ? AppColors.textMutedDark
                                              : AppColors.textSecondaryLight,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ] else ...[
                              // Reveal Result Card
                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: isCorrect
                                      ? (isDark
                                          ? AppColors.primary
                                              .withValues(alpha: 0.15)
                                          : AppColors.primarySoft)
                                      : (isDark
                                          ? AppColors.imposter
                                              .withValues(alpha: 0.15)
                                          : const Color(0xFFFDEDEC)),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isCorrect
                                        ? AppColors.primary
                                        : AppColors.imposter,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      isCorrect
                                          ? 'MASTER BLUFF!'
                                          : 'WRONG GUESS',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isCorrect
                                            ? AppColors.primary
                                            : AppColors.imposter,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Your Guess: "$_selectedGuess"',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Actual Word: "${session.secretWord}"',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Action Button
                        if (_hasSubmitted)
                          CustomButton(
                            label: 'See Final Results',
                            icon: FontAwesomeIcons.arrowRight,
                            onPressed: _onFinish,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

